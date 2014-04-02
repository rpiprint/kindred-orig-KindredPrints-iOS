//
//  KPPhotoOrderViewController.h
//  KindredPrints-iOS-SDK
//
//  Created by Alex Austin on 1/31/14.
//
//

#import <UIKit/UIKit.h>

@class KPPhotoOrderController;

@protocol KPPhotoOrderControllerDelegate <NSObject>

@optional
- (void)userDidCompleteOrder:(KPPhotoOrderController *)orderController;
- (void)userDidClickCancel:(KPPhotoOrderController *)orderController;
@end

@interface KPPhotoOrderController : UINavigationController


/* Initializing function:
 * Call this to get a reference to an initialized prints order view controller.
 * Then call presentViewController with the reference in order to launch viewer.
 * Pass an array of UIImages or http URL strings to add them to the cart
 */
- (KPPhotoOrderController *) initWithKey:(NSString *)string;
- (KPPhotoOrderController *) initWithKey:(NSString *)string andImages:(NSArray *)images;

/* Order view controller delegate:
 * assign this delegate to the originating view controller in order
 * to receive optional notifications about cancels and completes
 */
@property (nonatomic, weak) id <KPPhotoOrderControllerDelegate> orderDelegate;


/* Configuration calls
 * Call these to preconfigure various options of the SDK
 */

- (void) setBorderDisabled:(BOOL)disabled;
- (void) preRegisterUserWithEmail:(NSString *)email;
- (void) preRegisterUserWithEmail:(NSString *)email andName:(NSString *)name;
- (void) addImages:(NSArray *)images;

@end
