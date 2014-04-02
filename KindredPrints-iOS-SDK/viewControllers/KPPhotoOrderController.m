//
//  KPPhotoOrderViewController.m
//  KindredPrints-iOS-SDK
//
//  Created by Alex Austin on 1/31/14.
//
//

#import "KPPhotoOrderController.h"
#import "KPCartPageViewController.h"
#import "KPLoadingScreenViewController.h"
#import "UserPreferenceHelper.h"
#import "DevPreferenceHelper.h"
#import "ImageManager.h"
#import "BaseImage.h"
#import "OrderImage.h"
#import "KindredServerInterface.h"
#import "OrderManager.h"
#import "KPMEMImage.h"
#import "KPURLImage.h"

@interface KPPhotoOrderController() <ServerInterfaceDelegate, ImageManagerDelegate, OrderManagerDelegate>

@property (strong, nonatomic) NSArray *incomingImages;
@property (strong, nonatomic) ImageManager *imManager;
@property (strong, nonatomic) KPLoadingScreenViewController *loadingVC;
@property (strong, nonatomic) KindredServerInterface *ksInterface;
@property (nonatomic) NSInteger outstandingConfigNecessary;
@property (nonatomic) NSInteger returnedConfigNecessary;

@property (strong, nonatomic) OrderManager *orderManager;

@end

@implementation KPPhotoOrderController

- (ImageManager *)imManager {
    if (!_imManager) {
        _imManager = [ImageManager GetInstance];
        _imManager.delegate = self;
    }
    return _imManager;
}
- (KindredServerInterface *)ksInterface {
    if (!_ksInterface) {
        _ksInterface = [[KindredServerInterface alloc] init];
        _ksInterface.delegate = self;
    }
    return _ksInterface;
}

- (OrderManager *)orderManager {
    if (!_orderManager) {
        _orderManager = [OrderManager getInstance];
    }
    return _orderManager;
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (void)setReturnedConfigNecessary:(NSInteger)returnedConfigNecessary {
    _returnedConfigNecessary = returnedConfigNecessary;
    if (self.loadingVC && self.outstandingConfigNecessary) [self.loadingVC.progView setProgress:((CGFloat)returnedConfigNecessary)/((CGFloat)self.outstandingConfigNecessary) animated:YES];
}

- (KPPhotoOrderController *) initWithKey:(NSString *)key {
    [DevPreferenceHelper setAppKey:key];
    return [self baseInit:@[]];
}

- (KPPhotoOrderController *) initWithKey:(NSString *)key andImages:(NSArray *)images {
    [DevPreferenceHelper setAppKey:key];
    return [self baseInit:images];
}
- (void) addImages:(NSArray *)images {
    BOOL configDone = [self checkConfigDownloaded];
    
    self.incomingImages = images;
    
    if (configDone) {
        [self processNewImages];
    } else {
        [self launchAsyncConfig];
    }
}
- (void) setBorderDisabled:(BOOL)disabled {
    [InterfacePreferenceHelper setBorderDisabled:disabled];
}

- (void) preRegisterUserWithEmail:(NSString *)email {
    [self preRegisterUserWithEmail:email andName:@"a Kindred user"];
}
- (void) preRegisterUserWithEmail:(NSString *)email andName:(NSString *)name {
    UserObject *newUser = [UserPreferenceHelper getUserObject];
    if ([newUser.uId isEqualToString:USER_VALUE_NONE]) {
        newUser = [[UserObject alloc] initWithId:USER_VALUE_NONE andName:name andEmail:email andAuthKey:USER_VALUE_NONE andPaymentSaved:NO];
        [UserPreferenceHelper setUserObject:newUser];
        
        NSMutableDictionary *userPost = [[NSMutableDictionary alloc] init];
        [userPost setObject:name forKey:@"name"];
        [userPost setObject:email forKey:@"email"];
        [userPost setObject:@"ios" forKey:@"os"];
        [userPost setObject:[NSNumber numberWithBool:YES] forKey:@"sdk"];
        [userPost setObject:[NSNumber numberWithBool:NO] forKey:@"send_welcome"];
        [self.ksInterface createUser:userPost];
    }
}
-(KPPhotoOrderController *)baseInit:(NSArray *)images {
    BOOL configDone = [self checkConfigDownloaded];
    self.incomingImages = images;
    if (configDone) {
        [self processNewImages];
        [self moveToNextViewIfReady];
        return [self initCart];
    }
    else return [self initLoading];
}

- (KPPhotoOrderController *)initCart {
    KPCartPageViewController *cartVC = [[KPCartPageViewController alloc] initWithNibName:@"KPCartPageViewController" bundle:nil];
    cartVC.isRootController = YES;
    self = [self initWithRootViewController:cartVC];
    [self initNavBar];
    return self;
}

- (void) initNavBar {
    [self.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setHidden:YES];
    
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [self.navigationBar setBarTintColor:[InterfacePreferenceHelper getColor:ColorNavBar]];
    } else {
        [self.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setBackgroundColor:[InterfacePreferenceHelper getColor:ColorNavBar]];
    }
}

- (KPPhotoOrderController *)initLoading {
    self.loadingVC = [[KPLoadingScreenViewController alloc] initWithNibName:@"KPLoadingScreenViewController" bundle:nil];
    self = [self initWithRootViewController:self.loadingVC];
    [self initNavBar];

    [self launchAsyncConfig];
    
    return self;
}

- (BOOL) checkConfigDownloaded {
    self.outstandingConfigNecessary = 0;
    self.returnedConfigNecessary = 0;
    
    if ([DevPreferenceHelper needDownloadSizes])
        self.outstandingConfigNecessary++;
    if ([DevPreferenceHelper needDownloadCountries])
        self.outstandingConfigNecessary++;
    if ([DevPreferenceHelper needPartnerInfo])
        self.outstandingConfigNecessary++;
    
    return self.outstandingConfigNecessary == 0;
}

- (void) launchAsyncConfig {
    dispatch_queue_t loaderQ = dispatch_queue_create("kp_download_queue", NULL);
    dispatch_async(loaderQ, ^{
        if ([DevPreferenceHelper needDownloadSizes])
            [self.ksInterface getCurrentImageSizes];
        if ([DevPreferenceHelper needDownloadCountries])
            [self.ksInterface getCountryList];
        if ([DevPreferenceHelper needPartnerInfo])
            [self.ksInterface getPartnerDetails];
    });
}

- (void)processNewImages {
    for (id image in self.incomingImages) {
        BaseImage *bImage;
        OrderImage *oImage;
        if ([image isKindOfClass:[KPMEMImage class]]) {
            KPMEMImage *memImage = (KPMEMImage *)image;
            bImage = [[BaseImage alloc] initWithImage];
            oImage = [[OrderImage alloc] initWithImage:bImage andSize:CGSizeMake((memImage.image).size.width, (memImage.image).size.height)];
            [self.orderManager addOrderImage:oImage];
            [self.imManager cacheOrigImageFromMemory:bImage withImage:memImage.image];
        } else if ([image isKindOfClass:[KPURLImage class]]) {
            KPURLImage *urlImage = (KPURLImage *)image;
            bImage = [[BaseImage alloc] initWithUrl:urlImage.originalUrl andThumbUrl:urlImage.previewUrl];
            oImage = [[OrderImage alloc] initWithOutSize:bImage];
            [self.orderManager addOrderImage:oImage];
            [self.imManager startPrefetchingOrigImageToCache:bImage];
        } 
    }
    self.incomingImages = [[NSArray alloc] init];
}

- (void) moveToNextViewIfReady {
    if (self.outstandingConfigNecessary == self.returnedConfigNecessary) {
        KPCartPageViewController *cartVC = [[KPCartPageViewController alloc] initWithNibName:@"KPCartPageViewController" bundle:nil];
        cartVC.isRootController = YES;
        [self setViewControllers:@[cartVC] animated:YES];
    }
}

#pragma mark SERVER DELEGATE
- (void)serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];

        if ([requestTag isEqualToString:REQ_TAG_GET_COUNTRIES]) {
            self.returnedConfigNecessary++;
            if (status == 200) {
                NSArray *countryList = [returnedData objectForKey:@"countries"];
                NSMutableArray *filteredList = [[NSMutableArray alloc] init];
                for (int i = 0; i < [countryList count]; i++) {
                    if (![[countryList objectAtIndex:i] isEqualToString:@""]) {
                        [filteredList addObject:[countryList objectAtIndex:i]];
                    }
                }

                [DevPreferenceHelper setCountries:filteredList];
                [DevPreferenceHelper resetDownloadCountryStatus];
            }
            [self moveToNextViewIfReady];
        } else if ([requestTag isEqualToString:REQ_TAG_GET_IMAGE_SIZES]) {
            self.returnedConfigNecessary++;
            NSMutableArray *newProducts = [[NSMutableArray alloc] init];
            if (status == 200) {
                NSArray *serverProducts = [returnedData objectForKey:@"prices"];
                for (NSDictionary *product in serverProducts) {
                    PrintableSize *pSize = [[PrintableSize alloc] initWithDictionary:product];
                    [newProducts addObject:pSize];
                }
                [DevPreferenceHelper setCurrentSizes:newProducts];
                [self processNewImages];
                [self.orderManager updateAllOrdersWithNewSizes];
                
                [DevPreferenceHelper resetSizeDownloadStatus];
                [self moveToNextViewIfReady];
            }
        } else if ([requestTag isEqualToString:REQ_TAG_REGISTER]) {
            if (status == 200) {
                NSString *userId = [returnedData objectForKey:@"user_id"];
                NSString *name = [returnedData objectForKey:@"name"];
                NSString *email = [returnedData objectForKey:@"email"];
                NSString *authKey = [returnedData objectForKey:@"auth_key"];
                
                UserObject *userObj = [[UserObject alloc] initWithId:userId andName:name andEmail:email andAuthKey:authKey andPaymentSaved:NO];
                [UserPreferenceHelper setUserObject:userObj];
            }
        } else if ([requestTag isEqualToString:REQ_TAG_GET_PARTNER]) {
            self.returnedConfigNecessary++;

            if (status == 200) {
                NSDictionary *partnerObj = [returnedData objectForKey:@"partner"];
                [DevPreferenceHelper setPartnerLogoUrl:[partnerObj objectForKey:@"logo"]];
                [DevPreferenceHelper setPartnerName:[partnerObj objectForKey:@"name"]];
                [DevPreferenceHelper resetPartnerDownloadStatus];
            }
            [self moveToNextViewIfReady];
        }
    }
}

#pragma mark IMAGE MANAGER DELEGATE

- (void)imageCachedNotice:(NSString *)pid {
    self.returnedConfigNecessary++;
    [self moveToNextViewIfReady];
}

@end
