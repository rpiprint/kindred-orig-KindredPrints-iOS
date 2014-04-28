//
//  KPOrderSummaryViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/13/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPOrderSummaryViewController.h"
#import "InterfacePreferenceHelper.h"
#import "UserPreferenceHelper.h"
#import "KindredServerInterface.h"
#import "CheckoutCompletePurchaseCell.h"
#import "CheckoutCouponEditCell.h"
#import "CheckoutCreditCardCell.h"
#import "CheckoutLineItemCell.h"
#import "LoadingStatusView.h"
#import "BaseAddress.h"
#import "UserObject.h"
#import "SelectedOrderImage.h"
#import "RoundedTextButton.h"
#import "OrderProcessingHelper.h"
#import "KPOrderCompleteViewController.h"
#import "ShippingPicker.h"
#import "DevPreferenceHelper.h"
#import "KPCartPageViewController.h"
#import "KPCardEditorViewController.h"
#import "OrderManager.h"
#import "Mixpanel.h"

static NSString *ORDER_ROW_BLANK = @"order_row_blank";

@interface KPOrderSummaryViewController () <UITableViewDataSource, UITableViewDataSource, CheckoutCompletePurchaseDelegate, CheckoutCreditCardDelegate, CheckoutLineItemDelegate, ServerInterfaceDelegate, OrderProcessingDelegate, ShippingPickerDelegate, CouponApplyDelegate, LoadingStatusViewDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) ShippingPicker *shippingPicker;

@property (strong, nonatomic) KindredServerInterface *kInterface;
@property (strong, nonatomic) UserObject *currUser;
@property (strong, nonatomic) NSArray *selectedAddresses;

@property (weak, nonatomic) IBOutlet UILabel *txtLabel;
@property (weak, nonatomic) IBOutlet RoundedTextButton *cmdEditOrder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) LoadingStatusView *progBarView;
@property (strong, nonatomic) OrderProcessingHelper *orderProcessing;
@property (strong, nonatomic) NSArray *lineItems;
@property (nonatomic) BOOL orderInProcess;

@property (nonatomic) NSInteger totalFixedRows;
@property (nonatomic) NSInteger offsetCouponEntry;
@property (nonatomic) NSInteger offsetCreditCard;
@property (nonatomic) NSInteger offsetCompletePurchase;
@property (strong, nonatomic) Mixpanel *mixpanel;

@end

@implementation KPOrderSummaryViewController

- (KindredServerInterface *)kInterface {
    if (!_kInterface) {
        _kInterface = [[KindredServerInterface alloc] init];
        _kInterface.delegate = self;
    }
    return _kInterface;
}
- (UserObject *)currUser {
    if (!_currUser) {
        _currUser = [UserPreferenceHelper getUserObject];
    }
    return _currUser;
}

- (Mixpanel *)mixpanel {
    if (!_mixpanel) _mixpanel = [Mixpanel sharedInstance];
    return _mixpanel;
}

- (NSArray *)selectedAddresses {
    if (!_selectedAddresses)
        _selectedAddresses = [UserPreferenceHelper getSelectedAddresses];
    return _selectedAddresses;
}
- (OrderProcessingHelper *)orderProcessing {
    if (!_orderProcessing) {
        _orderProcessing = [[OrderProcessingHelper alloc] init];
        _orderProcessing.delegate = self;
    }
    return _orderProcessing;
}

- (LoadingStatusView *)progBarView {
    if (!_progBarView) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        _progBarView = [[LoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
        _progBarView.delegate = self;
        [self.view addSubview:_progBarView];
    }
    return _progBarView;
}

- (NSArray *)lineItems {
    if (!_lineItems) {
        _lineItems = [UserPreferenceHelper getOrderLineItems];
    }
    return _lineItems;
}

- (void) initCustomView {
    [self.view bringSubviewToFront:self.txtLabel];
    [self.view bringSubviewToFront:self.cmdEditOrder];
    [self.view bringSubviewToFront:self.tableView];
    
    self.orderInProcess = NO;
    
    CGRect editFrame = self.cmdEditOrder.frame;
    editFrame.origin.x = editFrame.origin.x - [InterfacePreferenceHelper getCheckoutPadding];
    self.cmdEditOrder.frame = editFrame;
    [self.cmdEditOrder drawButtonWithStrokeColor:[UIColor whiteColor] withBaseFillColor:[UIColor clearColor] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"EDIT PRINTS" andFontSize:OrderViewFontSize];

    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.shippingPicker = [[ShippingPicker alloc] initWithFrame:CGRectMake(0, screenBounds.size.height, screenBounds.size.width, 0)];
    self.shippingPicker.pickerDelegate = self;
    [self.view addSubview:self.shippingPicker];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    [self.mixpanel track:@"order_summary_page_view"];
}

- (void) updateRowOffsets {
    if (self.currUser.uPaymentSaved) {
        self.totalFixedRows = 6;
        self.offsetCouponEntry = -5;
        self.offsetCreditCard = -3;
        self.offsetCompletePurchase = -1;
    } else {
        self.totalFixedRows = 4;
        self.offsetCouponEntry = -3;
        self.offsetCreditCard = 1;
        self.offsetCompletePurchase = -1;
    }
}

- (void) initNavBar {
    [self initNavBarWithTitle:@"ORDER SUMMARY" andNextTitle:@"DONE"];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.progBarView setState:KP_STATUS_STATE_PROCESSING];
    [self.progBarView updateStatusCellWithMessage:@"loading order details.." andProgress:0.0];
    [self.progBarView show];
    
    if (!self.currUser.uPaymentSaved) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
        [self initPaymentData];
    } else {
        [self updateRowOffsets];
        [self.tableView reloadData];
    }
    
    [self.refreshControl beginRefreshing];
    [self.orderProcessing initiateOrderCreateOrUpdateSequence];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShowNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
    self.orderInProcess = NO;
    self.selectedAddresses = nil;
}

- (void) handleRefresh:(UIRefreshControl *)refreshControl {
    [self.refreshControl beginRefreshing];
    [UserPreferenceHelper setOrderIsSame:NO];
    [self.orderProcessing initiateOrderCreateOrUpdateSequence];
    [self initPaymentData];
}

- (void) initPaymentData {
    NSDictionary *post = [[NSDictionary alloc]
                          initWithObjects:@[self.currUser.uAuthKey]
                          forKeys:@[@"auth_key"]];
    [self.kInterface getUserPaymentDetails:post userId:self.currUser.uId];
}

- (IBAction)cmdEditOrderClick:(id)sender {
    KPCartPageViewController *cartVC = [[KPCartPageViewController alloc] initWithNibName:@"KPCartPageViewController" bundle:nil];
    cartVC.isRootController = NO;
    [self.navigationController pushViewController:cartVC animated:YES];
}

- (void)cmdNextClick {
    [self initiateCompletePurchase];
}

- (void)initiateCompletePurchase {
    if (self.currUser.uPaymentSaved) {
        [self.progBarView setState:KP_STATUS_STATE_PROCESSING];
        [self.progBarView updateStatusCellWithMessage:@"initiating payment sequence.." andProgress:0.0];
        [self.progBarView show];
        self.orderInProcess = YES;
        [self.orderProcessing initiateCheckoutSequence];
    } else {
        self.currUser = nil;
        KPCardEditorViewController *cartVC = [[KPCardEditorViewController alloc] initWithNibName:@"KPCardEditorViewController" bundle:nil];
        cartVC.completePurchase = YES;
        [self.navigationController pushViewController:cartVC animated:YES];
    }
}



#pragma mark Table View Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.lineItems count] + self.totalFixedRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowCount = [self.lineItems count] + self.totalFixedRows;

    if (indexPath.row < [self.lineItems count])
        return [InterfacePreferenceHelper getCheckoutRowHeight];
    else if (indexPath.row == rowCount + self.offsetCreditCard ||
             indexPath.row == rowCount + self.offsetCouponEntry) {
        return [InterfacePreferenceHelper getCheckoutRowHeight];
    } else if (indexPath.row == rowCount + self.offsetCompletePurchase) {
        return [InterfacePreferenceHelper getCheckoutSpecialRowHeight];
    } else {
        return [InterfacePreferenceHelper getCheckoutBlankRowHeight];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSInteger rowCount = [self.lineItems count] + self.totalFixedRows;
    
    if (indexPath.row < [self.lineItems count]) {
        CheckoutLineItemCell *sCell = [self.tableView dequeueReusableCellWithIdentifier:CHECK_LINE_CELL_IDENTIFIER];
        if (!sCell) {
            sCell = [[CheckoutLineItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHECK_LINE_CELL_IDENTIFIER andWidth:self.tableView.frame.size.width];
            sCell.delegate = self;
        }
        [sCell updateCellForLineItem:[self.lineItems objectAtIndex:indexPath.row]];
        
        cell = sCell;
    } else if (indexPath.row == rowCount + self.offsetCreditCard) {
        CheckoutCreditCardCell *sCell = [self.tableView dequeueReusableCellWithIdentifier:CHECK_CREDIT_CELL_IDENTIFIER];
        if(!sCell) {
            sCell = [[CheckoutCreditCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHECK_CREDIT_CELL_IDENTIFIER andWidth:self.tableView.frame.size.width];
            sCell.delegate = self;
        }
        [sCell updateDisplay];
        cell = sCell;
    } else if (indexPath.row == rowCount + self.offsetCompletePurchase) {
        CheckoutCompletePurchaseCell *sCell = [self.tableView dequeueReusableCellWithIdentifier:CHECK_PURCHASE_CELL_IDENTIFIER];
        if(!sCell) {
            sCell = [[CheckoutCompletePurchaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHECK_PURCHASE_CELL_IDENTIFIER andWidth:self.tableView.frame.size.width];
            sCell.delegate = self;
        }
        
        cell = sCell;
    } else if (indexPath.row == rowCount + self.offsetCouponEntry) {
        CheckoutCouponEditCell *sCell = [self.tableView dequeueReusableCellWithIdentifier:CHECK_COUPON_CELL_IDENTIFIER];
        if(!sCell) {
            sCell = [[CheckoutCouponEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CHECK_COUPON_CELL_IDENTIFIER andWidth:self.tableView.frame.size.width];
            sCell.delegate = self;
        }
        
        cell = sCell;
    } else {
        UITableViewCell *sCell = [self.tableView dequeueReusableCellWithIdentifier:ORDER_ROW_BLANK];
        if (!sCell) {
            sCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_ROW_BLANK];
            [sCell setBackgroundColor:[UIColor clearColor]];
        }
        cell = sCell;
    }
    return cell;
}


#pragma mark Server Interface Delegate

- (void) serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];
        NSString *identTag = [returnedData objectForKey:kpServerIdentTag];
        if ([requestTag isEqualToString:REQ_TAG_GET_USER_PAYMENT]) {
            if (status == 200) {
                self.currUser.uPaymentSaved = [[returnedData objectForKey:@"payment_status"] boolValue];
                self.currUser.uCreditType = [returnedData objectForKey:@"card_type"];
                self.currUser.uLastFour = [returnedData objectForKey:@"last_four"];
                [UserPreferenceHelper setUserObject:self.currUser];
                [self updateRowOffsets];
                [self.tableView reloadData];
            }
            [self.refreshControl endRefreshing];
        } else if ([requestTag isEqualToString:REQ_TAG_APPLY_COUPON]) {
            NSString *couponMessage = @"";
            if (status == 200) {
                [UserPreferenceHelper setOrderIsSame:NO];
                [self.orderProcessing initiateOrderCreateOrUpdateSequence];
                couponMessage = [identTag stringByAppendingString:@" has been applied!"];
            } else {
                couponMessage = [returnedData objectForKey:@"message"];
                [self.tableView reloadData];
            }
            [self.progBarView hide];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Your Coupon" message:couponMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
        } else if ([requestTag isEqualToString:REQ_TAG_GET_SHIP_QUOTE]) {
            if (status == 200) {
                for (BaseAddress *address in self.selectedAddresses) {
                    if ([address.aId isEqualToString:identTag]) {
                        [self.shippingPicker showWithQuotes:[returnedData objectForKey:@"quotes"] andSelection:address.aShipMethod forAddress:address.aId];
                        [self animateUp];
                        break;
                    }
                }
            }
            [self.progBarView hide];
        }
    }
}

#pragma mark Complete Purchase Cell Delegate

- (void)userRequestedCheckout {
    [self initiateCompletePurchase];
}

#pragma mark Edit Credit Card

- (void)userRequestedCreditCardEdit {
    [self.mixpanel track:@"order_summary_edit_card"];

    self.currUser = nil;
    KPCardEditorViewController *cartVC = [[KPCardEditorViewController alloc] initWithNibName:@"KPCardEditorViewController" bundle:nil];
    cartVC.completePurchase = NO;
    [self.navigationController pushViewController:cartVC animated:YES];
}

#pragma mark Apply Coupon Delegate

- (void) userRequestedApplyCoupon:(NSString *)couponId {
    [self.mixpanel track:@"order_summary_apply_coupon"];
    
    [self.progBarView setState:KP_STATUS_STATE_PROCESSING];
    [self.progBarView updateStatusCellWithMessage:@"checking coupon code.." andProgress:0.0];
    [self.progBarView show];
    
    NSDictionary *post = [[NSDictionary alloc]
                          initWithObjects:@[couponId]
                          forKeys:@[@"coupon"]];
    [self.kInterface applyCouponToOrder:post andOrderId:[UserPreferenceHelper getOrderId] andCouponId:couponId];
}

#pragma mark Edit Shipping Delegate

- (void)pickedShipping:(NSString *)shippingType forAddressId:(NSString *)addressId {
    [self animateDown];
    for (BaseAddress *address in self.selectedAddresses) {
        if ([address.aId isEqualToString:addressId]) {
            address.aShipMethod = shippingType;
            [UserPreferenceHelper setSelectedShippingAddresses:[self.selectedAddresses mutableCopy]];
            [UserPreferenceHelper setOrderIsSame:NO];
            [self.progBarView setState:KP_STATUS_STATE_PROCESSING];
            [self.progBarView updateStatusCellWithMessage:@"updating order with new shipping method.." andProgress:0.0];
            [self.progBarView show];
            [self.orderProcessing initiateOrderCreateOrUpdateSequence];
            break;
        }
    }
}

- (void)userRequestedChangeShippingWithAddressId:(NSString *)aid {
    [self.mixpanel track:@"order_summary_edit_shipping"];
    [self.progBarView setState:KP_STATUS_STATE_PROCESSING];
    [self.progBarView updateStatusCellWithMessage:@"quoting shipping prices.." andProgress:0.0];
    [self.progBarView show];

    [self.kInterface getShipQuotes:[UserPreferenceHelper getOrderId] addressId:aid];
}

- (void)animateUp {
    [UIView beginAnimations:@"showhide" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect posRect = self.shippingPicker.frame;
    posRect.origin.y = screenBounds.size.height-self.shippingPicker.frame.size.height-self.navigationController.navigationBar.frame.size.height;
    self.shippingPicker.frame = posRect;
    
    [UIView commitAnimations];
}

- (void)animateDown {
    [UIView beginAnimations:@"showhide" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect posRect = self.shippingPicker.frame;
    posRect.origin.y = screenBounds.size.height-self.navigationController.navigationBar.frame.size.height;
    self.shippingPicker.frame = posRect;
    
    [UIView commitAnimations];
}

#pragma mark Keyboard Methods
- (void)keyboardDidShowNotification:(NSNotification*)notification {
    if (LOG) NSLog(@"keyboard did show");
    [self.tableView setContentOffset:CGPointMake(0,  [self.lineItems count]*[InterfacePreferenceHelper getCheckoutRowHeight]) animated:YES];
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
    if (LOG) NSLog(@"keyboard did hide");
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark Order Processing Delegate

- (void)orderProcessingUpdateProgress:(CGFloat)progress withStatus:(NSString *)message {
    [self.progBarView updateStatusCellWithMessage:message andProgress:progress];
}
- (void)orderFailedToProcess:(NSString *)error {
    [self.progBarView updateStatusCellWithMessage:error andProgress:1.0];
    [self.progBarView setState:KP_STATUS_STATE_RETRY];
}
- (void)orderCreatedAndReturnedLineItems:(NSArray *)lineItems {
    self.orderInProcess = NO;
    [self.progBarView updateStatusCellWithMessage:@"Success!" andProgress:1.0];
    [self.progBarView hide];
    
    self.lineItems = lineItems;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
    [self.mixpanel track:@"order_summary_finished_loading"];
    
    [self.tableView setContentSize:CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height*2)];

}
- (void)paymentProcessed {
    [self.progBarView updateStatusCellWithMessage:@"Success!" andProgress:1.0];
    [self.progBarView hide];
    KPOrderCompleteViewController *orderFinishedVC = [[KPOrderCompleteViewController alloc] initWithNibName:@"KPOrderCompleteViewController" bundle:nil];
    [self.navigationController setViewControllers:@[orderFinishedVC] animated:YES];
}

#pragma mark Loading Status Delegate

- (void)clickedButtonAtState:(NSInteger)state {
    if (state == KP_STATUS_STATE_RETRY) {
        [self.progBarView setState:KP_STATUS_STATE_PROCESSING];
        [self.progBarView updateStatusCellWithMessage:@"loading order details.." andProgress:0.0];
        [self.progBarView show];
        [self.refreshControl beginRefreshing];
        [self.orderProcessing initiateOrderCreateOrUpdateSequence];
    }
}

@end
