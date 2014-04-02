//
//  TestViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/3/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "TestViewController.h"
#import "KPPhotoOrderController.h"
#import "KPURLImage.h"
#import "KPMEMImage.h"

@interface TestViewController () <KPPhotoOrderControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) KPPhotoOrderController *orderPhotosVC;

@property (weak, nonatomic) IBOutlet UIButton *cmdTakePhoto;
@property (weak, nonatomic) IBOutlet UITextField *txtUrl;
@property (weak, nonatomic) IBOutlet UIButton *cmdAdd3Test;
@property (weak, nonatomic) IBOutlet UIButton *cmdAddUrl;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *cmdPickGallery;

@end

@implementation TestViewController

static NSString *const KINDRED_APP_ID = @"test_SDHdPzfxotJ8xAQ674ABbXap";

- (KPPhotoOrderController *)orderPhotosVC {
    if (!_orderPhotosVC) _orderPhotosVC = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
    return _orderPhotosVC;
}

- (IBAction)cmdAddUrlImage:(id)sender {
    if (!self.txtUrl.text || [self.txtUrl.text length] == 0)
        return;
    KPURLImage *urlImage = [[KPURLImage alloc] initWithOriginalUrl:self.txtUrl.text];
    
    [self.orderPhotosVC addImages:@[urlImage]];
}

- (IBAction)cmdAdd3Test:(id)sender {
    KPURLImage *urlImage1 = [[KPURLImage alloc] initWithOriginalUrl:@"http://dev.kindredprints.com/img/horizRect.jpg"];
    KPURLImage *urlImage2 = [[KPURLImage alloc] initWithOriginalUrl:@"http://dev.kindredprints.com/img/squareTest.jpg"];
    KPURLImage *urlImage3 = [[KPURLImage alloc] initWithOriginalUrl:@"http://kindredprints.com/img/alex.png"];

    [self.orderPhotosVC addImages:@[urlImage1, urlImage2, urlImage3]];
}
- (IBAction)cmdPreRegister:(id)sender {
    if (!self.txtEmail.text || [self.txtEmail.text length] == 0)
        return;
    KPPhotoOrderController *orderPhotosVC = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
    [orderPhotosVC preRegisterUserWithEmail:self.txtEmail.text];
}

- (IBAction)cmdLaunchSDK:(id)sender {
    self.orderPhotosVC.orderDelegate = self;
    [self.navigationController presentViewController:self.orderPhotosVC animated:YES completion:nil];
}
- (IBAction)cmdPickGalleryClicked:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}
- (IBAction)cmdTakePhotoClicked:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)closeKeyboard {
    [self.txtEmail resignFirstResponder];
    [self.txtUrl resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(270, 0, 50, 35)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(closeKeyboard)],
                           nil];
    self.txtEmail.inputAccessoryView = numberToolbar;
    self.txtUrl.inputAccessoryView = numberToolbar;
}

#pragma mark PHOTO ORDER DELEGATE

- (void)userDidCompleteOrder:(KPPhotoOrderController *)orderController {
    NSLog(@"PARTNER APP - USER DID COMPLETE ORDER");
}
- (void)userDidClickCancel:(KPPhotoOrderController *)orderController {
    NSLog(@"PARTNER APP - USER DID RETURN TO APP");
}
#pragma mark PHOTOPICKER DELEGATE


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    KPMEMImage *img = [[KPMEMImage alloc] initWithImage:chosenImage];
    [self.orderPhotosVC addImages:@[img]];

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
