//
//  KPPhotoSelectViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 4/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPPhotoSelectViewController.h"
#import "KPPhotoOrderController.h"
#import "KPCartPageViewController.h"
#import "InterfacePreferenceHelper.h"
#import "PhotoCell.h"
#import "ImageManager.h"
#import "OrderManager.h"

@interface KPPhotoSelectViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *sourcePhotos;
@property (strong, nonatomic) NSMutableArray *selectedPhotos;
@property (strong, nonatomic) ImageManager *imManager;
@property (strong, nonatomic) OrderManager *orderManager;

@end

@implementation KPPhotoSelectViewController

- (NSMutableArray *)selectedPhotos {
    if (!_selectedPhotos) {
        _selectedPhotos = [[NSMutableArray alloc] init];
    }
    return _selectedPhotos;
}

- (OrderManager *)orderManager {
    if (!_orderManager) _orderManager = [OrderManager getInstance];
    return _orderManager;
}

- (ImageManager *)imManager {
    if (!_imManager) {
        _imManager = [ImageManager GetInstance];
    }
    return _imManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andImages:(NSArray *)images {
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        self.sourcePhotos = images;
    }
    return self;
}

- (void) initCustomView {
    [self.view bringSubviewToFront:self.collectionView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setItemSize:CGSizeMake([InterfacePreferenceHelper getSelectImageSide], [InterfacePreferenceHelper getSelectImageSide])];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumInteritemSpacing:2.0];
    [layout setMinimumLineSpacing:2.0];
    [self.collectionView setCollectionViewLayout:layout];
    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    
    [self.collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:CELL_ID];
    
    [self.cmdNext setDisabled];
}

- (void) initNavBar {
    [self initNavBarWithTitle:@"SELECT PHOTOS" andNextTitle:@"NEXT"];
}

- (void)cmdNextClick {
    if ([self.selectedPhotos count]) {
        for (KPImage *image in self.selectedPhotos) {
            [self.orderManager addExternalImage:image];
        }
        KPCartPageViewController *cartVC = [[KPCartPageViewController alloc] initWithNibName:@"KPCartPageViewController" bundle:nil];
        cartVC.isRootController = YES;
        [self.navigationController setViewControllers:@[cartVC] animated:YES];
    }
}
- (void)cmdBackClick {
    KPPhotoOrderController *navController = (KPPhotoOrderController *)self.navigationController;
    if (navController.orderDelegate) [navController.orderDelegate userDidClickCancel:navController];
    [self dismissViewControllerAnimated:YES completion:nil];

}
#pragma mark HELPERS

-(int)isImageSelected:(NSString *)pid {
    int index = 0;
    for(KPImage *photo in self.selectedPhotos) {
        if([pid isEqualToString:photo.pId]) {
            return index;
        }
        index++;
    }
    return -1;
}
-(void) toggleImageSelection: (NSIndexPath *)index {
    KPImage *photo = (KPImage *)[self.sourcePhotos objectAtIndex:index.row];
    if ([self isImageSelected:photo.pId] == -1) {
        [self setImageSelected:photo atIndex:index];
    } else {
        [self setImageUnselected:photo atIndex:index];
    }
    if ([self.selectedPhotos count]) {
        [self.cmdNext setEnabled];
    } else {
        [self.cmdNext setDisabled];
    }
}
- (void)setImageSelected:(KPImage *)photo atIndex:(NSIndexPath *)index {
    [self removeObjectForId:photo.pId];
    [self.selectedPhotos addObject:photo];
    PhotoCell *cell = (PhotoCell *)[self.collectionView cellForItemAtIndexPath:index];
    [cell setChecked];
}
- (void) setImageUnselected:(KPImage *)photo atIndex:(NSIndexPath *)index {
    [self removeObjectForId:photo.pId];
    PhotoCell *cell = (PhotoCell *)[self.collectionView cellForItemAtIndexPath:index];
    [cell setUnchecked];
}

- (void)removeObjectForId:(NSString *)pid {
    for (int i = 0; i < [self.selectedPhotos count]; i++) {
        KPImage *selPhoto = [self.selectedPhotos objectAtIndex:i];
        if ([selPhoto.pId isEqualToString:pid]) {
            [self.selectedPhotos removeObjectAtIndex:i];
            break;
        }
    }
}

#pragma mark COLLECTION VIEW DELEGATE FUNCS

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.sourcePhotos count];
}
-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([InterfacePreferenceHelper getSelectImageSide], [InterfacePreferenceHelper getSelectImageSide]);
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self toggleImageSelection:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    [cell.imageView setImage:nil];
    KPImage *img = [self.sourcePhotos objectAtIndex:indexPath.row];
    
    [cell.activityView setHidden:NO];
    [self.imManager setImageAsync:cell.imageView andProgressView:cell.activityView withImage:img andIndex:indexPath.row];
    
    if ([self isImageSelected:img.pId] > -1) {
        [cell setChecked];
    } else {
        [cell setUnchecked];
    }
    
       return cell;
}


@end
