//
//  KPShippingViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/7/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPShippingViewController.h"
#import "KPShippingEditViewController.h"
#import "KindredServerInterface.h"
#import "InterfacePreferenceHelper.h"
#import "UserPreferenceHelper.h"
#import "DevPreferenceHelper.h"
#import "NavButton.h"
#import "NavTitleBar.h"
#import "ShippingAddressCell.h"
#import "ShippingAddAddressCell.h"
#import "BaseAddress.h"
#import "UserObject.h"
#import "KPOrderSummaryViewController.h"
#import "ImageUploadHelper.h"

@interface KPShippingViewController () <ServerInterfaceDelegate, UITableViewDataSource, UITableViewDelegate, ShippingAddressDelegate>

@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *txtTitle;

@property (strong, nonatomic) UserObject *currUser;

@property (strong, nonatomic) NSArray *prevSelectedAddresses;
@property (strong, nonatomic) NSMutableArray *selectedAddresses;
@property (strong, nonatomic) NSMutableArray *addresses;

@property (strong, nonatomic) KindredServerInterface *kInterface;
@property (strong, nonatomic) ImageUploadHelper *uploadHelper;


@end

@implementation KPShippingViewController

static CGFloat TABLE_PADDING = 10;

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

- (NSMutableArray *)addresses {
    if (!_addresses) {
        _addresses = [UserPreferenceHelper getAllAddresses];
    }
    return _addresses;
}

- (NSMutableArray *)selectedAddresses {
    if (!_selectedAddresses) _selectedAddresses = [UserPreferenceHelper getSelectedAddresses];
    return _selectedAddresses;
}

- (void) initCustomView {
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view bringSubviewToFront:self.txtTitle];
    [self.view bringSubviewToFront:self.tableView];
    
    [[ImageUploadHelper getInstance] validateAllOrdersInit];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    
    CGSize viewableWindow = CGSizeMake(mainBounds.size.width, mainBounds.size.height-self.navigationController.navigationBar.frame.size.height-self.txtTitle.frame.origin.y*1.5-self.txtTitle.frame.size.height);
    
    self.tableView.frame = CGRectMake(TABLE_PADDING, self.tableView.frame.origin.y, self.tableView.frame.size.width, viewableWindow.height);
    
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    
    self.selectedAddresses = [UserPreferenceHelper getSelectedAddresses];
    self.prevSelectedAddresses = [self.selectedAddresses copy];
    if ([DevPreferenceHelper needDownloadAddresses]) {
        [self.refreshControl beginRefreshing];
        [self initAddressListReload];
    } else {
        self.addresses = [UserPreferenceHelper getAllAddresses];
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
}

- (void) handleRefresh:(UIRefreshControl *)refreshControl {
    [self.refreshControl beginRefreshing];
    [self initAddressListReload];
}

- (void) initAddressListReload {
    NSDictionary *post = [[NSDictionary alloc]
                          initWithObjects:@[self.currUser.uAuthKey]
                          forKeys:@[@"auth_key"]];
    
    [self.kInterface downloadAllAddresses:post userId:self.currUser.uId];
}

- (void) initNavBar {
    [self initNavBarWithTitle:@"CHOOSE DESTINATION" andNextTitle:@"NEXT"];
}

- (BOOL) isAddressSelected:(BaseAddress *)address {
    for (BaseAddress * selAddress in self.selectedAddresses) {
        if ([selAddress.aId isEqualToString:address.aId])
            return YES;
    }
    return NO;
}

- (void)cmdNextClick {
    [self checkIfAddressesChanged];
    [UserPreferenceHelper setSelectedShippingAddresses:self.selectedAddresses];
    KPOrderSummaryViewController *orderSummary = [[KPOrderSummaryViewController alloc] initWithNibName:@"KPOrderSummaryViewController" bundle:nil];
    [self.navigationController pushViewController:orderSummary animated:YES];
}

- (void)cmdBackClick {
    [self checkIfAddressesChanged];
    [UserPreferenceHelper setSelectedShippingAddresses:self.selectedAddresses];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) checkIfAddressesChanged {
    if ([self.prevSelectedAddresses count] == [self.selectedAddresses count]) {
        for (BaseAddress *address in self.prevSelectedAddresses) {
            BOOL found = NO;
            for (BaseAddress *newAddress in self.selectedAddresses) {
                if ([newAddress.aId isEqualToString:address.aId]) {
                    found = YES;
                    break;
                }
            }
            
            if (!found) {
                [UserPreferenceHelper setOrderIsSame:NO];
                break;
            }
        }
    } else {
        [UserPreferenceHelper setOrderIsSame:NO];
    }
}

- (void) selectAddress:(BaseAddress *)address {
    [self deselectAddress:address];
    [self.selectedAddresses addObject:address];
}

- (void) deselectAddress:(BaseAddress *)address {
    for (int i = 0; i < [self.selectedAddresses count]; i++) {
        BaseAddress *currAddress = [self.selectedAddresses objectAtIndex:i];
        if ([currAddress.aId isEqualToString:address.aId]) {
            [self.selectedAddresses removeObjectAtIndex:i];
            break;
        }
    }
}

#pragma mark UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.addresses count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [InterfacePreferenceHelper getAddressRowHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did select row at %ld", (long)indexPath.row);
    if (indexPath.row == 0) {
        KPShippingEditViewController *shippingEntryVC = [KPShippingEditViewController alloc];
        shippingEntryVC = [shippingEntryVC initWithNibName:@"KPShippingEditViewController" bundle:nil];
        [self.navigationController pushViewController:shippingEntryVC animated:YES];
    } else {
        [self selectAddress:[self.addresses objectAtIndex:indexPath.row-1]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did deselect row at %ld", (long)indexPath.row);
    if (indexPath.row > 0)
        [self deselectAddress:[self.addresses objectAtIndex:indexPath.row-1]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        ShippingAddAddressCell *sCell = [self.tableView dequeueReusableCellWithIdentifier:ADD_ADDRESS_CELL_IDENTIFIER];
        
        if (!sCell)
            sCell = [[ShippingAddAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ADD_ADDRESS_CELL_IDENTIFIER andWidth:self.tableView.frame.size.width];
        
        cell = sCell;
    } else {
        BaseAddress *address = [self.addresses objectAtIndex:indexPath.row-1];
        
        ShippingAddressCell *sCell = [self.tableView dequeueReusableCellWithIdentifier:ADDRESS_CELL_IDENTIFIER];
        if(!sCell) {
            sCell = [[ShippingAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ADDRESS_CELL_IDENTIFIER andAddress:address andWidth:self.tableView.frame.size.width];
            sCell.delegate = self;
        }
        [sCell updateViewWithAddress:address];
    
        if ([self isAddressSelected:address])
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        else
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        cell = sCell;
    }
    return cell;
}

#pragma mark Address Edit Delegate

- (void)userRequestedEditOfAddress:(BaseAddress *)address {
    KPShippingEditViewController *shippingEntryVC = [KPShippingEditViewController alloc];
    shippingEntryVC.currAddress = address;
    shippingEntryVC = [shippingEntryVC initWithNibName:@"KPShippingEditViewController" bundle:nil];
    [self.navigationController pushViewController:shippingEntryVC animated:YES];
}

- (void)userChangedSelection:(BOOL)selected andAddress:(BaseAddress *)address {
    if (selected)
        [self selectAddress:address];
    else
        [self deselectAddress:address];
}

#pragma mark Server Interface Delegate

- (void) serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];
        
        if ([requestTag isEqualToString:REQ_TAG_GET_ADDRESSES]) {
            if (status == 200) {
                NSArray *serverAddresses = [returnedData objectForKey:@"addresses"];
                NSMutableArray *prevAddreses = [self.addresses mutableCopy];
                [self.addresses removeAllObjects];
                for (NSDictionary *address in serverAddresses) {
                    BaseAddress *newAddress = [[BaseAddress alloc]
                                               initWithId:[address objectForKey:@"address_id"]
                                               name:[address objectForKey:@"name"]
                                               street:[address objectForKey:@"street1"]
                                               city:[address objectForKey:@"city"]
                                               state:[address objectForKey:@"state"]
                                               zip:[address objectForKey:@"zip"]
                                               country:[address objectForKey:@"country"]
                                               email:[address objectForKey:@"email"]
                                               phone:[address objectForKey:@"number"]];
                    
                    for (int i = 0; i < [prevAddreses count]; i++) {
                        BaseAddress *addr = [prevAddreses objectAtIndex:i];
                        if ([addr.aId isEqualToString:newAddress.aId]) {
                            newAddress.aShipMethod = addr.aShipMethod;
                            break;
                        }
                    }
                    [self.addresses addObject:newAddress];
                    
                    for (int i = 0; i < [self.selectedAddresses count]; i++) {
                        BaseAddress *selAddr = [self.selectedAddresses objectAtIndex:i];
                        if ([selAddr.aId isEqualToString:newAddress.aId]) {
                            newAddress.aShipMethod = selAddr.aShipMethod;
                            [self.selectedAddresses replaceObjectAtIndex:i withObject:newAddress];
                            break;
                        }
                    }
                }
                
                for (int i = 0; i < [self.selectedAddresses count]; i++) {
                    BaseAddress *selAddr = [self.selectedAddresses objectAtIndex:i];
                    BOOL found = false;
                    for (BaseAddress *addr in self.addresses) {
                        if ([addr.aId isEqualToString:selAddr.aId]) {
                            found = true;
                            break;
                        }
                    }
                    if (!found) {
                        [self.selectedAddresses removeObjectAtIndex:i];
                        i = MAX(0, i--);
                    }
                }
                
                if (![self.selectedAddresses count] && [self.addresses count])
                    [self.selectedAddresses addObject:[self.addresses firstObject]];
                
                [UserPreferenceHelper setSelectedShippingAddresses:self.selectedAddresses];
                [UserPreferenceHelper setAllShippingAddresses:self.addresses];
                [DevPreferenceHelper resetAddressDownloadStatus];
                [self.tableView reloadData];
            }
            [self.refreshControl endRefreshing];
        }
    }
}

@end
