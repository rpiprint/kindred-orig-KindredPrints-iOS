//
//  TestViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/3/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "TestViewController.h"
#import "KPPhotoOrderController.h"

@interface TestViewController () <KPPhotoOrderControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) KPPhotoOrderController *orderPhotosVC;

@property (weak, nonatomic) IBOutlet UIButton *cmdTakePhoto;
@property (weak, nonatomic) IBOutlet UITextField *txtUrl;
@property (weak, nonatomic) IBOutlet UIButton *cmdAdd3Test;
@property (weak, nonatomic) IBOutlet UIButton *cmdAddUrl;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *cmdPickGallery;
@property (weak, nonatomic) IBOutlet UIButton *cmdAddABunch;

@property (nonatomic) NSInteger index;

@end

@implementation TestViewController

static NSString *const KINDRED_APP_ID = @"YOUR KEY HERE";

- (KPPhotoOrderController *)orderPhotosVC {
    if (!_orderPhotosVC) _orderPhotosVC = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
    return _orderPhotosVC;
}

- (IBAction)cmdAddUrlImage:(id)sender {
    if (!self.txtUrl.text || [self.txtUrl.text length] == 0)
        return;
    KPURLImage *urlImage = [[KPURLImage alloc] initWithPartnerId:@"4" andOriginalUrl:self.txtUrl.text];
    
    [self.orderPhotosVC addImages:@[urlImage]];
}
- (IBAction)cmdAddABunch:(id)sender {
    NSMutableArray *photoArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        [photoArray addObject:[[KPURLImage alloc] initWithPartnerId:[NSString stringWithFormat:@"%d", i] andOriginalUrl:@"https://s3-us-west-1.amazonaws.com/kindredmetaimages/electronics.jpg"]];
    }
    [self.orderPhotosVC addImages:photoArray];
    self.orderPhotosVC.orderDelegate = self;
    [self.navigationController presentViewController:self.orderPhotosVC animated:YES completion:nil];
}

- (IBAction)cmdAdd3Test:(id)sender {
    self.index = self.index + 1;
    KPURLImage *urlImage1 = [[KPURLImage alloc] initWithPartnerId:[NSString stringWithFormat:@"%d", self.index] andOriginalUrl:@"http://kindredprints.com/img/dmitri.jpg"];
    self.index = self.index + 1;
    KPURLImage *urlImage2 = [[KPURLImage alloc] initWithPartnerId:[NSString stringWithFormat:@"%d", self.index] andOriginalUrl:@"http://kindredprints.com/img/sparky.png"];
    self.index = self.index + 1;
    KPURLImage *urlImage3 = [[KPURLImage alloc] initWithPartnerId:[NSString stringWithFormat:@"%d", self.index] andOriginalUrl:@"http://kindredprints.com/img/alex.png"];

    [self.orderPhotosVC queueImages:@[urlImage1, urlImage2, urlImage3]];
}
- (IBAction)cmdPreRegister:(id)sender {
    if (!self.txtEmail.text || [self.txtEmail.text length] == 0)
        return;
    KPPhotoOrderController *orderPhotosVC = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
    [orderPhotosVC preRegisterUserWithEmail:self.txtEmail.text];
}

- (IBAction)cmdLaunchSDK:(id)sender {
    self.orderPhotosVC.orderDelegate = self;
    [self.orderPhotosVC prepareImages];
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
- (IBAction)cmdAddCustom:(id)sender {
    KPCustomImage *customImage = [[KPCustomImage alloc] initWithPartnerId:@"01" andType:@"allthecooks" andData:@"http://www.allthecooks.com/amies-achara.html"];
    [self.orderPhotosVC addImages:@[customImage]];
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
    self.index = 0;
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

    self.index = self.index + 1;
    KPMEMImage *img = [[KPMEMImage alloc] initWithPartnerId:[NSString stringWithFormat:@"%d", self.index] andImage:chosenImage];
    [self.orderPhotosVC addImages:@[img]];
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
