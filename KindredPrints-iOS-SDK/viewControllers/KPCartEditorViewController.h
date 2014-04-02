//
//  KPCartEditorViewController.h
//  KindredPrints-iOS-SDK
//
//  Created by Alex Austin on 1/31/14.
//
//

#import <UIKit/UIKit.h>
#import "BaseImage.h"
#import "OrderImage.h"

@protocol KPCartEditorDelegate <NSObject>

@optional
- (void)userRequestedDeleteOfCurrentPage:(NSInteger)index;
- (void)userChangedQuantityByDeltaPrice:(NSInteger)deltaPrice;
- (void)userRequestedGoForwardAPage;
- (void)userRequestedGoBackAPage;
@end

@interface KPCartEditorViewController : UIViewController

@property (strong, nonatomic) OrderImage *image;
@property (nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil andImage:(OrderImage *)image;

@property (nonatomic, weak) id <KPCartEditorDelegate> delegate;

@end
