//
//  KPCartEditorViewController.m
//  KindredPrints-iOS-SDK
//
//  Created by Alex Austin on 1/31/14.
//
//

#import "KPCartEditorViewController.h"
#import "ImagePreviewCell.h"
#import "ProductPreviewCell.h"
#import "BackgroundGradientHelper.h"
#import "InterfacePreferenceHelper.h"
#import "UserPreferenceHelper.h"
#import "OrderManager.h"
#import "Mixpanel.h"

@interface KPCartEditorViewController () <UITableViewDataSource, ImagePreviewDelegate, ProductPreviewDelegate, UITableViewDelegate>

@property (strong, nonatomic) ImagePreviewCell *pCell;
@property (nonatomic) NSInteger selectedRow;
@property (nonatomic) BOOL lowRes;

@property (strong, nonatomic) Mixpanel *mixpanel;


@end

@implementation KPCartEditorViewController


- (Mixpanel *)mixpanel {
    if (!_mixpanel) _mixpanel = [Mixpanel sharedInstance];
    return _mixpanel;
}


- (id)initWithNibName:(NSString *)nibNameOrNil andImage:(OrderImage *)image {
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.image = image;
        self.selectedRow = -1;
        [self.tableView setBackgroundColor:[UIColor clearColor]];
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, self.navigationController.navigationBar.frame.size.height+2*[InterfacePreferenceHelper getOrderTotalRowHeight], 0)];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.view setBackgroundColor:[UIColor clearColor]];
        
        for (PrintableSize *product in image.printProducts) {
            if (product.sDPI < product.sWarnDPI) {
                self.lowRes = YES;
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.tableView];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGSize viewableWindow = CGSizeMake(mainBounds.size.width, mainBounds.size.height-self.navigationController.navigationBar.frame.size.height);
    self.tableView.frame = CGRectMake(0, 0, viewableWindow.width, viewableWindow.height);
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        [self.tableView setScrollEnabled:NO];
    }
}

#pragma mark TABLE VIEW DELEGATE

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.image.printProducts count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0)
        return [InterfacePreferenceHelper getPicturePreviewSize] + 2*[InterfacePreferenceHelper getCartHeaderSize];
    else
        return ROW_HEIGHT_PERCENT*[InterfacePreferenceHelper getPictureThumbSize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        self.pCell = [tableView dequeueReusableCellWithIdentifier:IMAGE_PREVIEW_CELL];
        if (!self.pCell) {
            self.pCell = [ImagePreviewCell alloc];
            self.pCell.delegate = self;
            self.pCell = [self.pCell initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IMAGE_PREVIEW_CELL andPhoto:self.image.image atIndex:self.index];
        }
        if (self.lowRes) {
            [self.pCell showWaringIcon];
        }
        cell = self.pCell;
    } else {
        ProductPreviewCell *pCell = [tableView dequeueReusableCellWithIdentifier:PRODUCT_PREVIEW_CELL];
        if (!pCell) {
            pCell = [[ProductPreviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PRODUCT_PREVIEW_CELL andPhoto:self.image.image withSize:[self.image.printProducts objectAtIndex:indexPath.row-1]];
            pCell.delegate = self;
        } else
            [pCell updateDisplayForImage:self.image.image andSize:[self.image.printProducts objectAtIndex:indexPath.row-1]];
        cell = pCell;
    }
    
    return cell;
}

-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

#pragma mark IMAGE PREVIEW DELEGATE

- (void)userRequestedDelete {
    [self.delegate userRequestedDeleteOfCurrentPage:self.index];
    
}

- (void)userRequestedGoForwardAPage {
    if (self.delegate) [self.delegate userRequestedGoForwardAPage];
}

- (void)userRequestedGoBackAPage {
    if (self.delegate) [self.delegate userRequestedGoBackAPage];
}
#pragma mark PRODUCT PREVIEW DELEGATE

- (void)updateProductWithSize:(PrintableSize *)size andDeltaPrice:(NSInteger)deltaPrice{
    NSMutableArray *productList = [self.image.printProducts mutableCopy];
    
    [self.mixpanel track:@"cart_changed_quantities"];
    
    for (int i = 0; i < [productList count]; i++) {
        PrintableSize *currSize = [productList objectAtIndex:i];
        if ([currSize.sid isEqualToString:size.sid]) {
            [productList replaceObjectAtIndex:i withObject:size];
            break;
        }
    }
    
    [self.delegate userChangedQuantityByDeltaPrice:deltaPrice];
    [[OrderManager getInstance] imageWasUpdatedWithSizes:self.image.image andSizes:productList];
}


@end
