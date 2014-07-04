//
//  KPLoginViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/7/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPLoginViewController.h"
#import "InterfacePreferenceHelper.h"
#import "NavButton.h"
#import "NavTitleBar.h"
#import "RoundedTextField.h"
#import "BackgroundGradientHelper.h"
#import "UserPreferenceHelper.h"
#import "KPShippingEditViewController.h"
#import "KindredServerInterface.h"
#import "UserObject.h"
#import "Mixpanel.h"

@interface KPLoginViewController () <UITextFieldDelegate, ServerInterfaceDelegate>

@property (strong, nonatomic) NSMutableDictionary *userStuff;
@property (strong, nonatomic) KindredServerInterface *kInterface;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *txtHeader;
@property (strong, nonatomic) UILabel *txtError;
@property (strong, nonatomic) RoundedTextField *txtEmail;
@property (strong, nonatomic) RoundedTextField *txtPassword;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@property (nonatomic) NSInteger currState;
@property (nonatomic) BOOL needReset;
@property (nonatomic) BOOL passwordVisible;

@property (strong, nonatomic) Mixpanel *mixpanel;


@end

@implementation KPLoginViewController

static CGFloat const HEADER_PADDING = 25.0f;
static CGFloat const PADDING = 10.0f;
static CGFloat const TEXT_HEIGHT = 40.0f;

static NSInteger const BASE_REGISTER_STATE = 0;
static NSInteger const BASE_LOGIN_STATE = 1;
static NSInteger const LOADING_STATE = 2;
static NSInteger const ERROR_STATE = 3;

- (KindredServerInterface *)kInterface {
    if (!_kInterface) {
        _kInterface = [[KindredServerInterface alloc] init];
        _kInterface.delegate = self;
    }
    return _kInterface;
}

- (Mixpanel *)mixpanel {
    if (!_mixpanel) _mixpanel = [Mixpanel sharedInstance];
    return _mixpanel;
}

- (void) initCustomView {
    CGRect bounds = [InterfacePreferenceHelper getScreenBounds];
    
    self.txtEmail = [[RoundedTextField alloc] initWithFrame:CGRectMake((bounds.size.width-[InterfacePreferenceHelper getLoginFormFieldWidth])/2, self.txtHeader.frame.origin.y+self.txtHeader.frame.size.height+HEADER_PADDING, [InterfacePreferenceHelper getLoginFormFieldWidth], [InterfacePreferenceHelper getLoginFormFieldHeight]) andStrokeColor:[UIColor whiteColor] andIconBackgroundColor:[InterfacePreferenceHelper getColor:ColorLoginHeader] andImage:[UIImage imageNamed:@"ico_ampersand_white.png"] andHintText:@"email"];
    self.txtEmail.txtEntry.delegate = self;
    [self.txtEmail.txtEntry setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.txtEmail.txtEntry setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.txtEmail.txtEntry setKeyboardType:UIKeyboardTypeEmailAddress];
    [self.txtEmail.txtEntry setReturnKeyType:UIReturnKeyNext];
    [self.txtEmail.txtEntry addTarget:self
                               action:@selector(cmdNextTextfieldPressed)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
    if (self.scrollView) [self.scrollView addSubview:self.txtEmail];
    else [self.view addSubview:self.txtEmail];
    
    self.txtPassword = [[RoundedTextField alloc] initWithFrame:CGRectMake((bounds.size.width-[InterfacePreferenceHelper getLoginFormFieldWidth])/2, self.txtEmail.frame.origin.y+self.txtEmail.frame.size.height+PADDING, [InterfacePreferenceHelper getLoginFormFieldWidth], [InterfacePreferenceHelper getLoginFormFieldHeight]) andStrokeColor:[UIColor whiteColor] andIconBackgroundColor:[InterfacePreferenceHelper getColor:ColorLoginHeader] andImage:[UIImage imageNamed:@"ico_lock_white.png"] andHintText:@"password"];
    self.txtPassword.txtEntry.delegate = self;
    [self.txtPassword.txtEntry setKeyboardType:UIKeyboardTypeASCIICapable];
    [self.txtPassword.txtEntry setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self.txtPassword.txtEntry setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self.txtPassword.txtEntry setSecureTextEntry:YES];
    [self.txtPassword.txtEntry setReturnKeyType:UIReturnKeyDone];
    [self.txtPassword.txtEntry addTarget:self
                                  action:@selector(cmdDonePressed)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
    if (self.scrollView) [self.scrollView addSubview:self.txtPassword];
    else [self.view addSubview:self.txtPassword];
    
    CGRect mainBounds = [InterfacePreferenceHelper getScreenBounds];
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGSize activitySize = self.activityView.frame.size;
    [self.activityView setFrame:CGRectMake(mainBounds.size.width/2-activitySize.width/2, self.txtEmail.frame.origin.y+(2*TEXT_HEIGHT+PADDING)/2-activitySize.height/2, activitySize.width  , activitySize.height)];
    [self.activityView setHidden:YES];
    [self.view addSubview:self.activityView];
    
    self.txtError = [[UILabel alloc] initWithFrame:CGRectMake((bounds.size.width-[InterfacePreferenceHelper getLoginFormFieldWidth])/2, self.txtPassword.frame.origin.y+self.txtPassword.frame.size.height+PADDING, [InterfacePreferenceHelper getLoginFormFieldWidth], [InterfacePreferenceHelper getLoginFormFieldHeight])];
    [self.txtError setFont:[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize]];
    [self.txtError setTextColor:[InterfacePreferenceHelper getColor:ColorError]];
    [self.txtError setBackgroundColor:[UIColor clearColor]];
    [self.txtError setTextAlignment:NSTextAlignmentCenter];
    [self.txtError setNumberOfLines:2];
    
    [self.txtError setHidden:YES];
    
    if (self.scrollView) [self.scrollView addSubview:self.txtError];
    else [self.view addSubview:self.txtError];
    [self.view bringSubviewToFront:self.txtHeader];
    if (self.scrollView) [self.view bringSubviewToFront:self.scrollView];
    
    UserObject *currUser = [UserPreferenceHelper getUserObject];
    if (![currUser.uEmail isEqualToString:USER_VALUE_NONE] && [currUser.uId isEqualToString:USER_VALUE_NONE]) {
        [self.txtEmail.txtEntry setText:currUser.uEmail];
        [self setInterfaceState:BASE_LOGIN_STATE];
    } else {
        [self setInterfaceState:BASE_REGISTER_STATE];
    }
    
    [self.mixpanel track:@"login_page_view"];
}

- (void) initNavBar {
    [self initNavBarWithTitle:@"CONTACT INFO" andNextTitle:@"NEXT"];
}

- (void)cmdNextClick {
    self.userStuff = [[NSMutableDictionary alloc] init];
    
    if (self.txtEmail.txtEntry.text && self.txtEmail.txtEntry.text.length > 0)
        [self.userStuff setObject:self.txtEmail.txtEntry.text forKey:@"email"];
    else {
        [self.txtError setText:@"Please fill in the email field"];
        [self setInterfaceState:ERROR_STATE];
    }
    
    if (self.needReset) {
        [self.kInterface startPasswordReset:self.userStuff];
        [self setInterfaceState:LOADING_STATE];
        return;
    }
    
    if (self.currState != BASE_REGISTER_STATE) {
        if (self.txtPassword.txtEntry.text && self.txtPassword.txtEntry.text.length > 0)
            [self.userStuff setObject:self.txtPassword.txtEntry.text forKey:@"password"];
        else {
            [self.txtError setText:@"Please fill in the password field"];
            [self setInterfaceState:ERROR_STATE];
        }
    }
    
    [self.userStuff setObject:@"a Kindred user" forKey:@"name" ];
    [self.userStuff setObject:@"ios" forKey:@"os" ];
    [self.userStuff setObject:[NSNumber numberWithBool:YES] forKey:@"sdk"];
    [self.userStuff setObject:[NSNumber numberWithBool:YES] forKey:@"send_welcome"];

    if (!self.passwordVisible) {
        [self startRegistrationProcess:self.userStuff];
    } else {
        [self startLoginProcess:self.userStuff];
    }
    
    [self setInterfaceState:LOADING_STATE];
}

- (void)startRegistrationProcess:(NSDictionary *)regPost {
    [self.kInterface createUser:regPost];
}

- (void)startLoginProcess:(NSDictionary *)loginPost {
    [self.kInterface loginUser:loginPost];
}

- (void)handleErrors:(NSInteger)errorCode {
    switch (errorCode) {
        case 421:
            [self.txtError setText:@"That email is taken, try logging in?"];
            self.passwordVisible = YES;
            break;
        case 422:
            [self.txtError setText:@"Please enter an email."];
            break;
        case 423:
            [self.txtError setText:@"Please enter a valid email."];
            break;
        case 424:
            [self.txtError setText:@"Please enter a password."];
            break;
        case 425:
            [self.txtError setText:@"No spaces in passwords please."];
            break;
        case 426:
            [self.txtError setText:@"Passwords must be > 6 characters."];
            break;
        case 427:
            [self.txtError setText:@"Password is too obvious."];
            break;
        case 428:
            [self.txtError setText:@"That email does not exist!"];
            break;
        case 429:
            [self.txtError setText:@"That password does not match. Click RESET to reset it."];
            [self.cmdNext.button setTitle:@"RESET" forState:UIControlStateNormal];
            self.needReset = YES;
            break;
        default:
            break;
    }
    [self setInterfaceState:ERROR_STATE];

}

- (void) setInterfaceState:(NSInteger)state {
    self.currState = state;
    if (state == BASE_REGISTER_STATE) {
        [self.activityView setHidden:YES];
        [self.txtHeader setHidden:NO];
        [self.txtEmail setHidden:NO];
        [self.txtPassword setHidden:YES];
        [self.txtError setHidden:YES];
        [self.txtEmail.txtEntry setReturnKeyType:UIReturnKeyDone];
        self.passwordVisible = NO;
    } else if (state == BASE_LOGIN_STATE) {
        [self.activityView setHidden:YES];
        [self.txtHeader setHidden:NO];
        [self.txtEmail setHidden:NO];
        [self.txtPassword setHidden:NO];
        [self.txtError setHidden:YES];
        [self.txtEmail.txtEntry setReturnKeyType:UIReturnKeyNext];
        self.passwordVisible = YES;
    } else if (state == LOADING_STATE) {
        [self.activityView setHidden:NO];
        [self.txtHeader setHidden:YES];
        [self.txtEmail setHidden:YES];
        [self.txtPassword setHidden:YES];
        [self.txtError setHidden:YES];
    } else if (state == ERROR_STATE) {
        [self.activityView setHidden:YES];
        [self.txtHeader setHidden:NO];
        [self.txtEmail setHidden:NO];
        [self.txtPassword setHidden:!self.passwordVisible];
        [self.txtError setHidden:NO];
    }
}

- (BOOL)textInTextFields:(RoundedTextField *)textField {
    if (textField.txtEntry.text.length > 0)
        return YES;
    return NO;
}

- (void)cmdDonePressed {
    [self.txtPassword.txtEntry resignFirstResponder];
    if (self.scrollView) [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self cmdNextClick];
}

- (void)cmdNextTextfieldPressed {
    if (!self.passwordVisible) {
        [self.txtEmail.txtEntry resignFirstResponder];
        if (self.scrollView) [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self cmdNextClick];
    } else {
        [self.txtEmail.txtEntry resignFirstResponder];
        [self.txtPassword.txtEntry becomeFirstResponder];
    }
}

- (void) moveToNextView {
    NSMutableArray *mutableVCs = [self.navigationController.viewControllers mutableCopy];
    [mutableVCs removeLastObject];
    KPShippingEditViewController *shippingVC = [[KPShippingEditViewController alloc] initWithNibName:@"KPShippingEditViewController" bundle:nil];
    [mutableVCs addObject:shippingVC];
    [self.navigationController setViewControllers:mutableVCs animated:YES];
}

#pragma mark UITextField delegate funcs
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *textAfterReplacing = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (self.needReset) {
        [self.cmdNext.button setTitle:@"NEXT" forState:UIControlStateNormal];
        self.needReset = NO;
    }
    
    if ([self textInTextFields:self.txtEmail] && ([self textInTextFields:self.txtPassword] || !self.passwordVisible)) {
        [self.cmdNext.button setEnabled:YES];
    } else {
        if ([textField isEqual:self.txtPassword.txtEntry]) {
            if ([self textInTextFields:self.txtEmail] && textAfterReplacing.length)
                [self.cmdNext.button setEnabled:YES];
            else
                [self.cmdNext.button setEnabled:NO];
        } else {
            if ([self textInTextFields:self.txtPassword] && textAfterReplacing.length)
                [self.cmdNext.button setEnabled:YES];
            else
                [self.cmdNext.button setEnabled:NO];
        }
    }
            
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.scrollView) [self.scrollView setContentOffset:CGPointMake(0, textField.superview.frame.origin.y-20) animated:YES];
    return YES;
}

#pragma mark ServerInterfaceDelegate

- (void)serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];

        if ([requestTag isEqualToString:REQ_TAG_LOGIN] || [requestTag isEqualToString:REQ_TAG_REGISTER]) {
            if (status == 200) {
                NSString *userId = [returnedData objectForKey:@"user_id"];
                NSString *name = [returnedData objectForKey:@"name"];
                NSString *email = [returnedData objectForKey:@"email"];
                NSString *authKey = [returnedData objectForKey:@"auth_key"];
                
                [self.mixpanel identify:email];
                
                UserObject *userObj = [[UserObject alloc] initWithId:userId andName:name andEmail:email andAuthKey:authKey andPaymentSaved:NO];
                [UserPreferenceHelper setUserObject:userObj];
                
                [self moveToNextView];
            } else if (status < 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Connection Error" message:@"Printing your images requires a stable internet connection. Please try again with better reception!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                [self handleErrors:status];
            }
        } else if ([requestTag isEqualToString:REQ_TAG_PASSWORD_RESET]) {
            if (status == 200) {
                [self.txtError setText:@"Please check your email for the reset link."];
                [self.txtPassword.txtEntry setText:@""];
                [self.cmdNext.button setTitle:@"NEXT" forState:UIControlStateNormal];
                [self setInterfaceState:ERROR_STATE];
                self.needReset = NO;
            }
        }
    }
}

@end
