# Kindred Prints iOS SDK

The Kindred Prints SDK makes it extremely easy to start selling and getting paid for physical printed photos straight from your app. You simply need drop the folder into your iPhone or iPad project, and add a photo through our simple SDK interface to send your user to the checkout flow.

![Kindred Diagram](https://s3-us-west-1.amazonaws.com/kindredmetaimages/KindredDiagram.png)

## About the Kindred Prints SDK

Here are the details of what is included in the Kindred Printing platform

### What You Get
- Payouts straight to you bank account for every print you sell
- Create custom coupons for your users
- Give specific users credits
- Monitor all orders, users on a custom dashboard
- An photo print cart with complete checkout/payments 
- All related customer service handled by Kindred

### Overview of User Checkout Flow
1. [behind the scenes] You add photos and (optionally) preregister the user for shipment, order notifications
1. Present the Kindred Prints order flow
1. User sees all photos you added, with list of available products for each photo
1. User selects quantities for each order
1. User adds/selects shipping destination
1. User sees order summary
1. User enters credit card to (securely) pay for items
1. User receives order confirmation email
1. A day or two later, user receives shipping notification
1. The user receives the prints in the mail

### Current Print Capabilities

- 4" x 4" glossy premium print

![4x4 Prints](https://raw.githubusercontent.com/KindredPrints/KindredPrints-iOS/master/Documentation/4by4.jpg)

- 4" x 6" glossy premium print

![4x6 Prints](https://raw.githubusercontent.com/KindredPrints/KindredPrints-iOS/master/Documentation/4by6.jpg)

## iOS Specific Installation

The entire SDK is open sourced and a release schedule will be publicized soon. You can download the raw SDK files or clone the entire project with accompanying test app.

### Download the SDK with Test Project

Follow the instructions in this section if you want to see how an example test app interfaces with the SDK. All publicly callable functions in the SDK are demonstrated.

You can grab a zipped copy here.

1. Download [zipped test project and SDK](https://s3-us-west-1.amazonaws.com/kindredmeta/KindredPrints-iOS.zip) to the folder of your choice
2. Unzip the file to your development directory

OR clone this project and open it in Xcode.

1. `cd` into your development directory.
2. Run `git clone git://github.com/kindredprints/kindredprints-ios.git` in the command line

Then.

1. Double click **KindredPrints-iOS-TestBed.xcodeproj**, located in KindredPrints-iOS-TestBed
2. View **TestViewController.m** and update this line with your test Kindred App ID (you can grab one by signing up [here](http://sdk.kindredprints.com/signup/))

```objc
static NSString *const KINDRED_APP_ID = @"YOUR TEST KEY HERE";
```
3. Run the project and play with the test app.
4. All the publicly callable SDK functions are demonstrated in **TestViewController.m**

### Download the raw SDK files

If you would prefer to just add the SDK folder to your project and get started right away with out looking at the test app, follow these instructions.

1. You can grab a zipped copy of the **KindredPrints-iOS-SDK** folder [here](https://s3-us-west-1.amazonaws.com/kindredmeta/KindredPrints-iOS-SDK.zip)

Or use the **KindredPrints-iOS-SDK** folder out of the test project folder (instructions on downloading above)

1. Drag and drop the **KindredPrints-iOS-SDK** folder into your project in Xcode, or add the folder by clicking **File -> Add files to ..**

### Using the SDK

In this section, I'll try to explain the functions as employed by some example implementation, but feel free to let your imagination run wild here.There are two main ways to use the SDK in your app, and the choice is really up to you. 

#### A note about testing

All testing should be done using the test key you get through signing up (sign up located here: 'link to partner signup'), which means that none of your orders get sent to the printer and no credit cards are charged. Be sure to switch this key to the live version before opening it up to the public.

With the Kindred test key, you can use a fake credit card with the number **4242 4242 4242 4242** and any valid future date/cvv code.

#### Example Single Photo Workflow

Everyone should read this example implementation, as it shows more details than the multi photo flow (pre user registration and delegate callbacks). This is the type of implementation if you would like to drive users to checkout based on a single photo. You would be interested in this if you are an app that deals primarily with editing or improving a single photo or you've developed a beautiful layout of user content that you would like to let your users buy (like a cooking recipe card).

For this example, we assume that the photo is stored in local memory. For example using remote URLs, see similar methods in the examples below.

1. Add a button next to the photo that says Print or whatever you feel is appropriate.

2. Add the appropriate imports to your class:

```objc
#import "KPPhotoOrderController.h"
#import "KPMEMImage.h"
```
3. Create a method to handle the button click and insert this code into it:

```objc
KPMEMImage *img = [[KPMEMImage alloc] initWithImage:(UIImage *)chosenImage];
KPPhotoOrderController *orderController = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID andImages:@[img]];
[self.navigationController presentViewController:self.orderPhotosVC animated:YES completion:nil];
```
4. Replace the `KINDRED_APP_ID` with your test or live key (depending on which mode you are in). You can get one for you app through the quick signup process [here](http://sdk.kindredprints.com/signup/)

5. You're done! Yea - it can really be that simple. We'll take care of the rest.

**Delegate Addendum:**
 If you want to register for a callback when the SDK finishes, simply register your class as a KPPhotoOrderControllerDelegate. To do this, follow these instructions:

1. Register your class as a KPPhotoOrderControllerDelegate by placing <KPPhotoOrderControllerDelegate> next to the interface declaration. An example can be found in our TestProject like so:

```objc
@interface TestViewController () <KPPhotoOrderControllerDelegate>
```
2. Add responses to the optional delegate functions like so:

```objc
- (void)userDidCompleteOrder:(KPPhotoOrderController *)orderController {
    NSLog(@"USER DID COMPLETE ORDER");
}
- (void)userDidClickCancel:(KPPhotoOrderController *)orderController {
    NSLog(@"USER DID RETURN TO APP");
}
```
3. Assign the instance of KPPhotoOrderController a delegate before presenting it to the user. As shown here:

```objc
KPMEMImage *img = [[KPMEMImage alloc] initWithImage:(UIImage *)chosenImage];
KPPhotoOrderController *orderController = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID andImages:@[img]];
orderController.delegate = self;
[self.navigationController presentViewController:self.orderPhotosVC animated:YES completion:nil];
```
4. Done!

**User Preregistration Addendum:** 
We require users to enter an email address for a number of reasons. The two most common cases are for the order confirmation and shipping notifications that we send when the prints are mailed. We also need to reach out to the customer in case of any issues with their orders. 

We understand that email addresses can be a friction point that lowers conversion, so we wanted to let you take care of this if you already know the email address of the user. To pre register an email address with the service, it's very simple, just call these lines of code any where.

```objc
KPPhotoOrderController *orderPhotosVC = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
[orderPhotosVC preRegisterUserWithEmail:(NSString *)userEmail];
```
If you already initialized the **KPPhotoOrderController** class, you can just call 'preRegisterUserWithEmail' on it.

Also of note, if you know the name of the user as well, we can personalize the emails for a better experience if you call this function

```objc
KPPhotoOrderController *orderPhotosVC = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
[orderPhotosVC preRegisterUserWithEmail:(NSString *)userEmail andName:(NSString *)userName];
```
#### Example Multi Photo Workflow

You would be interested in this example if you are an app that deals with a lot of photos. Let's say you have a whole album of photos, and you want to add 5-10 of them to the photo print cart. Or, you want to give the user the feeling of a cart like experience, and let them individually add photos to the cart before they are ready to "Checkout". You could build a simple "Checkout" button in the top corner of the screen and place an "Add to cart" button next to every photo.

In this example, all photos are located on a remote server, and are passed to the SDK via their urls. The checkout flow will then cache the photo for display to the user.

1. Add the "Add to cart" button to your project and place it next to each photo in a list

2. Add the appropriate imports to your class:

```objc
#import "KPPhotoOrderController.h"
#import "KPURLImage.h"
```
3. Create a method to handle the button click and insert this code into it:

```objc
KPPhotoOrderController *orderController = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
KPURLImage *img = [[KPURLImage alloc] initWithOriginalUrl:@"http://site.com/img.jpg"];
[orderController addImages:@[img]];
```
   Alternatively, if you also store a remote url for a pre rendered preview size image in addition to the original, you can init a KPURLImage like this.

```objc
KPURLImage *img = [[KPURLImage alloc] initWithPreviewUrl:@"http://site.com/prevImg.jpg" andOriginalUrl:@"http://site.com/img.jpg"];
```
4. Now, add a button somewhere on the display that says "Checkout"

5. Create a method to handle the button click and insert this code into it:

```objc
KPPhotoOrderController *orderController = [[KPPhotoOrderController alloc] initWithKey:KINDRED_APP_ID];
[self.navigationController presentViewController:self.orderPhotosVC animated:YES completion:nil];
```
6. You're done! The user can now check out all of the images they've added before.
