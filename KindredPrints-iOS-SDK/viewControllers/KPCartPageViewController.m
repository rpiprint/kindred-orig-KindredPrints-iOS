//
//  KPCartPageViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/2/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPPhotoOrderController.h"
#import "KPCartPageViewController.h"
#import "KPCartEditorViewController.h"
#import "KPLoginViewController.h"
#import "KPShippingViewController.h"
#import "KPShippingEditViewController.h"
#import "InterfacePreferenceHelper.h"
#import "OrderTotalView.h"
#import "UserObject.h"
#import "UserPreferenceHelper.h"
#import "ImageUploadHelper.h"
#import "SelectedOrderImage.h"
#import "KPCartPageModel.h"
#import "NavButton.h"
#import "NavTitleBar.h"
#import "OrderManager.h"
#import "Mixpanel.h"

@interface KPCartPageViewController () <UIPageViewControllerDelegate, KPCartModelDelegate, OrderManagerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) KPCartPageModel *pageModel;
@property (strong, nonatomic) OrderTotalView *orderTotalView;
@property (nonatomic) NSUInteger currIndex;

@property (strong, nonatomic) OrderManager *orderManager;

@property (strong, nonatomic) Mixpanel *mixpanel;

@end

@implementation KPCartPageViewController

static NSInteger TAG_EMPTY_CART = 1;
static NSInteger TAG_WARNING_NEXT = 2;
static NSInteger TAG_WARNING_BACK = 3;

- (Mixpanel *)mixpanel {
    if (!_mixpanel) _mixpanel = [Mixpanel sharedInstance];
    return _mixpanel;
}

- (KPCartPageModel *)pageModel {
    if (!_pageModel) {
        _pageModel = [[KPCartPageModel alloc] init];
        _pageModel.delegate = self;
    }
    return _pageModel;
}

- (void) initCustomView {
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.delegate = self;
    
    self.orderManager = [OrderManager getInstance];

}

- (void) initNavBar {
    [self initNavBarWithTitle:@"CHOOSE QUANTITIES" andNextTitle:@"NEXT"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    UIViewController *startingViewController = [self.pageModel viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    self.pageViewController.dataSource = self.pageModel;
    
    self.orderManager.delegate = self;
    
    [self adjustNavBarForOrderCount];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
    CGRect pageViewRect = self.view.bounds;
    self.pageViewController.view.frame = pageViewRect;
    
    [self.pageViewController didMoveToParentViewController:self];
    // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
    self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
    
    if (self.orderTotalView) [self.orderTotalView removeFromSuperview];
    
    [self.mixpanel track:@"cart_page_view"];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat statusBarHeight = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    } else {
        statusBarHeight = [InterfacePreferenceHelper getStatusBarHeight];
    }
    self.orderTotalView = [[OrderTotalView alloc] initWithFrame:CGRectMake(0, screenBounds.size.height-self.navigationController.navigationBar.frame.size.height-statusBarHeight, self.pageViewController.view.frame.size.width, [InterfacePreferenceHelper getOrderTotalRowHeight])];
    [self.pageViewController.view addSubview:self.orderTotalView];
    
    [self.mixpanel track:@"cart_photo_count" properties:[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:[self.orderManager countOfOrders]]] forKeys:@[@"photo_count"]]];
    
    [self.pageModel initOrderTotal];
}

- (void) adjustNavBarForOrderCount {
    if (![self.orderManager countOfOrders]) {
        [self initNavBarWithTitle:@"" andNextTitle:@""];
        [self.cmdNext setDisabled];
    } else {
        [self initNavBar];
        [self.cmdNext setEnabled];
    }
}

- (void)cmdNextClick {
    BOOL dpiPass = [self saveAndPrepareOrders];
        
    if ([self.orderManager countOfSelectedOrders] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Must Choose Prints" message:@"You must pick at least 1 print to proceed to checkout!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }

    if (!dpiPass) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning: Low Resolution" message:@"One of the prints you chose has a low resolution. The resulting print might look grainy or blurry. Do you want to continue?" delegate:self cancelButtonTitle:@"Change It" otherButtonTitles:@"Continue", nil];
        alertView.delegate = self;
        alertView.tag = TAG_WARNING_NEXT;
        [alertView show];
    } else {
        [self moveNext];
    }
}

- (void) moveNext {
    UserObject *userObj = [UserPreferenceHelper getUserObject];
    if (userObj.uAuthKey && ![userObj.uAuthKey isEqualToString:USER_VALUE_NONE]) {
        if ([[UserPreferenceHelper getAllAddresses] count]) {
            KPShippingViewController *shippingVC = [[KPShippingViewController alloc] initWithNibName:@"KPShippingViewController" bundle:nil];
            [self.navigationController pushViewController:shippingVC animated:YES];
        } else {
            KPShippingEditViewController *editShippingVC = [[KPShippingEditViewController alloc] initWithNibName:@"KPShippingEditViewController" bundle:nil];
            [self.navigationController pushViewController:editShippingVC animated:YES];
        }
    } else {
        KPLoginViewController *loginVC = [[KPLoginViewController alloc] initWithNibName:@"KPLoginViewController" bundle:nil];
        [self.navigationController pushViewController:loginVC animated:YES];
    }
}

- (void) moveBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cmdBackClick {
    BOOL dpiPass = [self saveAndPrepareOrders];
    
    if (self.isRootController) {
        KPPhotoOrderController *navController = (KPPhotoOrderController *)self.navigationController;
        if (navController.orderDelegate) [navController.orderDelegate userDidClickCancel:navController];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if ([self.orderManager countOfSelectedOrders] == 0) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Must Choose Prints" message:@"You must pick at least 1 print to proceed to checkout! Or choose Exit to leave the cart." delegate:self cancelButtonTitle:@"Choose Prints" otherButtonTitles:@"Exit", nil];
            alertView.delegate = self;
            alertView.tag = TAG_EMPTY_CART;
            [alertView show];
        } else {
            if (!dpiPass) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning: Low Resolution" message:@"One of the prints you chose has a low resolution. The resulting print might look grainy or blurry. Do you want to continue?" delegate:self cancelButtonTitle:@"Change It" otherButtonTitles:@"Continue", nil];
                alertView.delegate = self;
                alertView.tag = TAG_WARNING_BACK;
                [alertView show];

            } else {
                [self moveBack];
            }
        }
    }
}

- (void) moveToFirstWarningPage {
    int selIndex = -1;
    NSArray *orderList = [UserPreferenceHelper getCartOrders];
    for (int i = 0; i < [orderList count]; i++) {
        OrderImage *order = [orderList objectAtIndex:i];
        for (PrintableSize *product in order.printProducts) {
            if (product.sQuantity && product.sDPI < product.sWarnDPI) {
                selIndex = i;
                break;
            }
        }
        if (selIndex >= 0)
            break;
    }
    if (selIndex >= 0) {
        UIViewController *startingViewController = [self.pageModel viewControllerAtIndex:selIndex];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
    }
}

- (BOOL) saveAndPrepareOrders {
    NSArray *allCartOrder = [self.orderManager getOrderImages];
    NSArray *prevSelectedOrders = [self.orderManager getSelectedOrderImages];
    
    BOOL DPIpass = YES;
    
    NSInteger countOfNewOrders = 0;
    NSInteger countOfUnchanged = 0;
    
    NSMutableArray *selectedOrders = [[NSMutableArray alloc] init];
    for (OrderImage *order in allCartOrder) {
        for (PrintableSize * product in order.printProducts) {
            if (product.sQuantity > 0) {
                SelectedOrderImage *sOrder = [[SelectedOrderImage alloc] initWithImage:order.image andProduct:product];
                
                for (SelectedOrderImage *prevSelected in prevSelectedOrders) {
                    if ([prevSelected.oImage.pid isEqualToString:order.image.pid] && [prevSelected.oProduct.sid isEqualToString:product.sid]) {
                        sOrder.oServerId = prevSelected.oServerId;
                        sOrder.oServerInit = prevSelected.oServerInit;
                        sOrder.oLineItemServerInit = prevSelected.oLineItemServerInit;
                        sOrder.oLineItemServerId = prevSelected.oLineItemServerId;
                        if (prevSelected.oProduct.sQuantity != product.sQuantity) {
                            sOrder.oLineItemServerInit = NO;
                        } else {
                            countOfUnchanged = countOfUnchanged + 1;
                        }
                    }
                }
                
                if (product.sDPI < product.sWarnDPI) {
                    DPIpass = NO;
                }
                countOfNewOrders = countOfNewOrders + 1;
                [selectedOrders addObject:sOrder];
            }
        }
    }
   
    [self.mixpanel track:@"cart_click_next" properties:[[NSDictionary alloc] initWithObjects:@[[NSNumber numberWithInteger:[selectedOrders count]]] forKeys:@[@"print_count"]]];
    
    [self.orderManager setSelectedOrderImages:selectedOrders];

    if (countOfNewOrders != countOfUnchanged) {
        [UserPreferenceHelper setOrderIsSame:NO];
    }
    
    [[ImageUploadHelper getInstance] validateAllOrdersInit];
    
    return DPIpass;
}

- (void) refreshProductListOfCurrentViews {
    NSArray *currVCs = [self.pageViewController viewControllers];
    
    for (KPCartEditorViewController *vc in currVCs) {
        vc.image = [self.pageModel orderImageAtIndex:[self.pageModel indexOfViewController:vc]];
        [vc.tableView reloadData];
    }
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    if (completed) {
        self.currIndex = [self.pageModel indexOfViewController:[pageViewController.viewControllers objectAtIndex:0]];
    }
}

#pragma mark PAGE MODEL DELEGATE

- (void)refreshView {
    // should check if the existing product list changed before resetting view controllers
    if (self.currIndex > [self.pageModel maxPages]-1)
        self.currIndex = MAX(0, [self.pageModel maxPages]-1);
    
    UIViewController *startingViewController = [self.pageModel viewControllerAtIndex:self.currIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (void)updateOrderTotal:(NSInteger)orderTotal {
    [self.view bringSubviewToFront:self.orderTotalView];
    self.orderTotalView.orderTotal = orderTotal;
}

- (BOOL)needRefreshView:(BaseImage *)image {
    for (int i = MAX(0, ((int)self.currIndex)-2); i < MIN([self.orderManager countOfOrders], self.currIndex+3); i++) {
        OrderImage *oImage = [self.orderManager getOrderForIndex:i];
        if ([image.pid isEqualToString:oImage.image.pid]) {
            return YES;
        }
    }
    return NO;
}

- (void)userRequestedGoForwardAPage {
    if (self.currIndex >= [self.pageModel maxPages]-1)
        return;
    self.currIndex++;
    UIViewController *startingViewController = [self.pageModel viewControllerAtIndex:self.currIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:NULL];
}
- (void)userRequestedGoBackAPage {
    if (self.currIndex <= 0)
        return;
    self.currIndex--;
    UIViewController *startingViewController = [self.pageModel viewControllerAtIndex:self.currIndex];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:NULL];
}

#pragma mark ORDER UPDATE DELEGATE

- (void)ordersHaveAllBeenUpdated {
    [self refreshView];
    [self.pageModel initOrderTotal];
    [self adjustNavBarForOrderCount];
}
- (void)ordersHaveBeenUpdatedWithSizes:(BaseImage *)image {
    if ([self needRefreshView:image])
        [self refreshView];
    
    [self.pageModel initOrderTotal];
    [self adjustNavBarForOrderCount];
}
- (void)ordersHaveBeenServerInit:(BaseImage *)image {
    if ([self needRefreshView:image])
        [self refreshView];
}
- (void)ordersHaveBeenUploaded:(BaseImage *)image {
    if ([self needRefreshView:image])
        [self refreshView];
}

#pragma mark Alert View Delegate
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_EMPTY_CART) {
        if(buttonIndex == 1) {
            KPPhotoOrderController *navController = (KPPhotoOrderController *)self.navigationController;
            [navController.orderDelegate userDidClickCancel:navController];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (alertView.tag == TAG_WARNING_NEXT) {
        if (buttonIndex == 1) {
            [self moveNext];
        } else {
            [self moveToFirstWarningPage];
        }
    } else if (alertView.tag == TAG_WARNING_BACK) {
        if (buttonIndex == 1) {
            [self moveBack];
        } else {
            [self moveToFirstWarningPage];
        }
    }
}


@end
