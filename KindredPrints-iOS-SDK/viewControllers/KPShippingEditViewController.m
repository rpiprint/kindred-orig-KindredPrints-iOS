//
//  KPShippingEntryViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/9/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPShippingEditViewController.h"
#import "KPShippingViewController.h"
#import "CountryPicker.h"
#import "InterfacePreferenceHelper.h"
#import "KindredServerInterface.h"
#import "UserPreferenceHelper.h"
#import "RoundedTextButton.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface KPShippingEditViewController () <CountryPickerDelegate, ServerInterfaceDelegate, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *dividerViews;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *txtViews;

@property (strong, nonatomic) NSString *importedPhone;
@property (strong, nonatomic) NSString *importedEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtStreet;
@property (weak, nonatomic) IBOutlet UITextField *txtCity;
@property (weak, nonatomic) IBOutlet UITextField *txtZip;
@property (weak, nonatomic) IBOutlet UITextField *txtState;
@property (weak, nonatomic) IBOutlet UIButton *cmdCountry;
@property (strong, nonatomic) UIImageView *importIcon;
@property (strong, nonatomic) CountryPicker *countryPicker;
@property (strong, nonatomic) RoundedTextButton *cmdAddContact;
@property (weak, nonatomic) IBOutlet UILabel *txtErrorField;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) KindredServerInterface *kInterface;

@end

@implementation KPShippingEditViewController

static CGFloat const ADD_CONTANT_HEIGHT = 22;
static CGFloat const ADD_CONTANT_ICON_HEIGHT = 12;
static CGFloat const ADD_CONTACT_WIDTH = 80;
static CGFloat const PADDING = 4;

static NSInteger const STATE_LOADING = 0;
static NSInteger const STATE_ENTRY = 1;

- (KindredServerInterface *)kInterface {
    if (!_kInterface) {
        _kInterface = [[KindredServerInterface alloc] init];
        _kInterface.delegate = self;
    }
    
    return _kInterface;
}

- (void) initCustomView {
    [self.view bringSubviewToFront:self.cmdCountry];
    for (UIView *v in self.dividerViews)
        [self.view bringSubviewToFront:v];
    for (UITextField *txtField in self.txtViews) {
        [self.view bringSubviewToFront:txtField];
        txtField.delegate = self;
    }
    [self.view bringSubviewToFront:self.txtErrorField];
    [self.view bringSubviewToFront:self.activityView];
    
    NSDictionary *placeholderAttrs = [[NSDictionary alloc]
                                      initWithObjects:@[[UIFont fontWithName:FONT_REGULAR size:MenuButtonFontSize],
                                                        [InterfacePreferenceHelper getColor:ColorNavBar]
                                                        ]
                                      forKeys:@[
                                                NSFontAttributeName,
                                                NSForegroundColorAttributeName]];
    [self.txtName setAttributedPlaceholder:[[NSAttributedString alloc]
                                            initWithString:@"Name"
                                            attributes:placeholderAttrs]];
    [self.txtStreet setAttributedPlaceholder:[[NSAttributedString alloc]
                                            initWithString:@"Street"
                                            attributes:placeholderAttrs]];
    [self.txtCity setAttributedPlaceholder:[[NSAttributedString alloc]
                                            initWithString:@"City"
                                            attributes:placeholderAttrs]];
    [self.txtZip setAttributedPlaceholder:[[NSAttributedString alloc]
                                            initWithString:@"Zip"
                                            attributes:placeholderAttrs]];
    [self.txtState setAttributedPlaceholder:[[NSAttributedString alloc]
                                            initWithString:@"State"
                                            attributes:placeholderAttrs]];
    
    CGRect nameFrame = self.txtName.frame;
    self.cmdAddContact = [[RoundedTextButton alloc] initWithFrame:CGRectMake(nameFrame.origin.x+nameFrame.size.width-ADD_CONTACT_WIDTH, nameFrame.origin.y+(nameFrame.size.height-ADD_CONTANT_HEIGHT)/2, ADD_CONTACT_WIDTH, ADD_CONTANT_HEIGHT) withStrokeColor:[UIColor whiteColor] withBaseFillColor:[UIColor clearColor] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"    IMPORT" andFontSize:ImportButtonFontSize];
    self.importIcon = [[UIImageView alloc] initWithFrame:CGRectMake(nameFrame.origin.x+nameFrame.size.width-ADD_CONTACT_WIDTH+2*PADDING, nameFrame.origin.y+(nameFrame.size.height-ADD_CONTANT_ICON_HEIGHT)/2, ADD_CONTANT_ICON_HEIGHT, ADD_CONTANT_ICON_HEIGHT)];
    [self.importIcon setImage:[UIImage imageNamed:@"ico_user_white.png"]];
    [self.view addSubview:self.importIcon];
    [self.cmdAddContact addTarget:self action:@selector(cmdImportPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cmdAddContact];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    self.countryPicker = [[CountryPicker alloc] initWithFrame:CGRectMake(0, screenBounds.size.height, screenBounds.size.width, 0)];
    [self.countryPicker setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    [self.view addSubview:self.countryPicker];

    [self.cmdCountry setTitle:@"United States" forState:UIControlStateNormal];
    [self.cmdCountry addTarget:self action:@selector(cmdCountryPressed) forControlEvents:UIControlEventTouchUpInside];
    self.countryPicker.pickerDelegate = self;
    
    [self.txtErrorField setHidden:YES];
    [self initFieldsIfNecessary];
    [self setInterfaceState:STATE_ENTRY];
}

- (void) initNavBar {
    [self initNavBarWithTitle:@"NEW ADDRESS" andNextTitle:@"DONE"];
    [self checkAndUpdateNextButtonStatus];
}

- (void) checkAndUpdateNextButtonStatus {
    BOOL nextEnabled = YES;
    for (UITextField *v in self.txtViews) {
        if (![v text] || [[v text] length] == 0)
            nextEnabled = NO;
    }
    [self.cmdNext.button setEnabled:nextEnabled];
}

- (void) setInterfaceState:(NSInteger)state {
    if (state == STATE_ENTRY) {
        [self.activityView setHidden:YES];
        for (UIView *v in self.dividerViews)
            [v setHidden:NO];
        [self.cmdAddContact setHidden:NO];
        [self.txtName setHidden:NO];
        [self.txtStreet setHidden:NO];
        [self.txtState setHidden:NO];
        [self.txtCity setHidden:NO];
        [self.txtZip setHidden:NO];
        [self.cmdCountry setHidden:NO];
    } else if (state == STATE_LOADING) {
        [self.activityView setHidden:NO];
        for (UIView *v in self.dividerViews)
            [v setHidden:YES];
        [self.cmdAddContact setHidden:YES];
        [self.txtName setHidden:YES];
        [self.txtStreet setHidden:YES];
        [self.txtState setHidden:YES];
        [self.txtCity setHidden:YES];
        [self.txtZip setHidden:YES];
        [self.cmdCountry setHidden:YES];
    }
}

- (void) cmdCountryPressed {
    [self animateUp];
    [self closeKeyboard];
}

- (void)cmdBackClick {
    [self goBackToList];
}

- (void)cmdNextClick {
    [self setInterfaceState:STATE_LOADING];
    [self.txtErrorField setHidden:YES];
    
    [self.txtErrorField setTextColor:[InterfacePreferenceHelper getColor:ColorError]];

    UserObject *currUser = [UserPreferenceHelper getUserObject];
    NSMutableDictionary *postData = [[NSMutableDictionary alloc] init];
    [postData setObject:currUser.uAuthKey forKey:@"auth_key"];
    [postData setObject:self.txtName.text forKey:@"name"];
    [postData setObject:self.txtStreet.text forKey:@"street1"];
    [postData setObject:@"" forKey:@"street2"];
    [postData setObject:self.txtCity.text forKey:@"city"];
    [postData setObject:self.txtState.text forKey:@"state"];
    [postData setObject:self.txtZip.text forKey:@"zip"];
    [postData setObject:self.countryPicker.selectedCountry forKey:@"country"];
    if (self.importedEmail) [postData setObject:self.importedEmail forKey:@"email"];
    if (self.importedPhone) [postData setObject:self.importedPhone forKey:@"number"];
    if (!self.currAddress || !self.currAddress.aId) {
        [self.kInterface createNewAddress:postData userId:currUser.uId];
    } else {
        [postData setObject:self.currAddress.aId forKey:@"address_id"];
        [self.kInterface updateAddress:postData userId:currUser.uId];
    }
    
    [self closeKeyboard];
}

- (void)goBackToList {
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    BOOL needCreate = YES;
    for(UIViewController *VC in viewControllers)
    {
        if([VC isKindOfClass:[KPShippingViewController class]])
        {
            needCreate = NO;
            break;
        }
    }
    if (needCreate) {
        NSMutableArray *backStack = [self.navigationController.viewControllers mutableCopy];
        KPShippingViewController *shippingVC = [[KPShippingViewController alloc] initWithNibName:@"KPShippingViewController" bundle:nil];
        [backStack replaceObjectAtIndex:[backStack count]-1 withObject:shippingVC];
        [self.navigationController setViewControllers:backStack animated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    

}

- (void)cmdImportPressed {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void) initFieldsIfNecessary {
    if (self.currAddress && self.currAddress.aId) {
        if ([self.currAddress.aCountry length]) {
            if ([self.currAddress.aCountry isEqualToString:@"waiting"])
                self.currAddress.aCountry = @"United States";
            [self.countryPicker selectCountry:self.currAddress.aCountry];
            [self.cmdCountry setTitle:self.currAddress.aCountry forState:UIControlStateNormal];
        }
        if (self.currAddress.aPhone)
            self.importedPhone = self.currAddress.aPhone;
        if (self.currAddress.aEmail)
            self.importedEmail = self.currAddress.aEmail;
        
        if ([self.currAddress.aStreet isEqualToString:@"waiting"]) self.currAddress.aStreet = @"";
        if ([self.currAddress.aCity isEqualToString:@"Request"]) self.currAddress.aCity = @"";
        if ([self.currAddress.aState isEqualToString:@"sent"]) self.currAddress.aState = @"";
        if ([self.currAddress.aZip isEqualToString:@"waiting"]) self.currAddress.aZip = @"";
        
        if (self.currAddress.aName) [self.txtName setText:self.currAddress.aName];
        if (self.currAddress.aStreet) [self.txtStreet setText:self.currAddress.aStreet];
        if (self.currAddress.aCity) [self.txtCity setText:self.currAddress.aCity];
        if (self.currAddress.aState) [self.txtState setText:self.currAddress.aState];
        if (self.currAddress.aZip) [self.txtZip setText:self.currAddress.aZip];
    }
}

- (void)animateUp {
    [UIView beginAnimations:@"showhide" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect posRect = self.countryPicker.frame;
    posRect.origin.y = screenBounds.size.height-self.countryPicker.frame.size.height-self.navigationController.navigationBar.frame.size.height;
    self.countryPicker.frame = posRect;
    
    [UIView commitAnimations];
}

- (void)animateDown {
    [UIView beginAnimations:@"showhide" context:nil];
    [UIView setAnimationDuration:0.25];
    [UIView setAnimationDelegate:self];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGRect posRect = self.countryPicker.frame;
    posRect.origin.y = screenBounds.size.height-self.navigationController.navigationBar.frame.size.height;
    self.countryPicker.frame = posRect;
    
    [UIView commitAnimations];
}

-(void)closeKeyboard {
    for (UITextField *txtV in self.txtViews) {
        [txtV resignFirstResponder];
    }
}

- (void) parseAddressFromServer:(NSDictionary *)serverObject {
    self.currAddress = [[BaseAddress alloc]
                        initWithId:[serverObject objectForKey:@"address_id"]
                        name:[serverObject objectForKey:@"name"]
                        street:[serverObject objectForKey:@"street1"]
                        city:[serverObject objectForKey:@"city"]
                        state:[serverObject objectForKey:@"state"]
                        zip:[serverObject objectForKey:@"zip"]
                        country:[serverObject objectForKey:@"country"]
                        email:[serverObject objectForKey:@"email"]
                        phone:[serverObject objectForKey:@"number"]];
    
    [self setInterfaceState:STATE_ENTRY];
    
    [self initFieldsIfNecessary];
    
    if (self.currAddress.aId) {
        NSMutableArray *allAddresses = [UserPreferenceHelper getAllAddresses];
        BOOL alreadyExists = NO;
        for (int i = 0; i < [allAddresses count]; i++) {
            BaseAddress *address = [allAddresses objectAtIndex:i];
            if ([address.aId isEqualToString:self.currAddress.aId]) {
                alreadyExists = YES;
                self.currAddress.aShipMethod = address.aShipMethod;
                [allAddresses replaceObjectAtIndex:i withObject:self.currAddress];
                break;
            }
        }
        if (!alreadyExists) {
            [allAddresses addObject:self.currAddress];
        }
        [UserPreferenceHelper setAllShippingAddresses:allAddresses];

        NSMutableArray *selectedAddresses = [UserPreferenceHelper getSelectedAddresses];
        BOOL isAlreadySelected = NO;
        for (int i = 0; i < [selectedAddresses count]; i++) {
            BaseAddress *address = [selectedAddresses objectAtIndex:i];
            if ([address.aId isEqualToString:self.currAddress.aId]) {
                isAlreadySelected = YES;
                self.currAddress.aShipMethod = address.aShipMethod;
                [selectedAddresses replaceObjectAtIndex:i withObject:self.currAddress];
                break;
            }
        }
        if (!isAlreadySelected) {
            [selectedAddresses addObject:self.currAddress];
        }
        [UserPreferenceHelper setSelectedShippingAddresses:selectedAddresses];

        [self goBackToList];
    }
}

#pragma mark TextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self animateDown];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *textAfterReplacing = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self.txtErrorField setHidden:YES];
    
    BOOL nextEnabled = YES;
    if ([textAfterReplacing length] == 0) {
        nextEnabled = NO;
    } else {
        for (UITextField *txtField in self.txtViews) {
            if (!txtField.text || [txtField.text length] == 0) {
                if ([txtField isEqual:textField]) {
                    if (![textAfterReplacing length]) {
                        nextEnabled = NO;
                        break;
                    }
                } else {
                    nextEnabled = NO;
                }
            }
        }
        
        if ([self.cmdCountry.titleLabel.text isEqualToString:@"United States"]) {
            if ([textField isEqual:self.txtState]) {
                if ([textAfterReplacing length] > 2)
                    return NO;
            }
        }
    }
    
    [self.cmdNext.button setEnabled:nextEnabled];
    
    return YES;
}


#pragma mark CountryPickerDelegate

- (void) pickedCountry:(NSString *)country {
    [self.cmdCountry setTitle:country forState:UIControlStateNormal];
    [self animateDown];
}

#pragma mark ServerInterfaceDelegate FUNCS

- (void) serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];
        
        if ([requestTag isEqualToString:REQ_TAG_CREATE_NEW_ADDRESS] || [requestTag isEqualToString:REQ_TAG_UPDATE_ADDRESS]) {
            if (status == 200) {
                [self parseAddressFromServer:returnedData];
            } else {
                [self setInterfaceState:STATE_ENTRY];
                [self.txtErrorField setHidden:NO];
            }
        }
    }
}

#pragma mark ContactPickerDelegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    NSString *lastname = ((__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty));
    NSString *firstname = ((__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty));
    NSString* name = nil;
    if (firstname && lastname)
        name = [[firstname stringByAppendingString:@" "] stringByAppendingString:lastname];
    else if (firstname)
        name = firstname;
    else if (lastname)
        name = lastname;
    
    [self.txtName setText:name];
    
    ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    for(CFIndex j = 0; j < ABMultiValueGetCount(multiPhones); j++)
    {
        CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, j);
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiPhones, j);
        NSString *phoneLabel =(__bridge NSString*) ABAddressBookCopyLocalizedLabel(locLabel);
        self.importedPhone = (__bridge NSString *)phoneNumberRef;
        if ([phoneLabel isEqualToString:@"mobile"]) {
            CFRelease(phoneNumberRef);
            CFRelease(locLabel);
            break;
        }
        CFRelease(phoneNumberRef);
        CFRelease(locLabel);
    }
    
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (emailMultiValue) {
        NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
        CFRelease(emailMultiValue);
        self.importedEmail = [emailAddresses objectAtIndex:0];
    }
    
    ABMultiValueRef multi = ABRecordCopyValue(person, kABPersonAddressProperty);
    if (multi) {
        // Set up an NSArray and copy the values in.
        NSArray *theArray = (__bridge NSArray *)(ABMultiValueCopyArrayOfAllValues(multi));
        
        // Set up an NSDictionary to hold the contents of the array.
        NSDictionary *theDict = [theArray objectAtIndex:0];
        
        // Set up NSStrings to hold keys and values.  First, how many are there?
        
        [self.txtStreet setText: [theDict objectForKey:(NSString *)kABPersonAddressStreetKey]];
        [self.txtCity setText:[theDict objectForKey:(NSString *)kABPersonAddressCityKey]];
        [self.txtState setText:[theDict objectForKey:(NSString *)kABPersonAddressStateKey]];
        [self.txtZip setText:[theDict objectForKey:(NSString *)kABPersonAddressZIPKey]];
        if ([theDict objectForKey:(NSString *)kABPersonAddressCountryKey]) {
            [self.countryPicker selectCountry:[theDict objectForKey:(NSString *)kABPersonAddressCountryKey]];
            [self.cmdCountry setTitle:[theDict objectForKey:(NSString *)kABPersonAddressCountryKey] forState:UIControlStateNormal];
        } else {
            [self.countryPicker selectCountry:@"United States"];
            [self.cmdCountry setTitle:@"United States" forState:UIControlStateNormal];
        }
    }
    
    [self checkAndUpdateNextButtonStatus];
    [self.txtErrorField setHidden:YES];
    [self closeKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self closeKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
