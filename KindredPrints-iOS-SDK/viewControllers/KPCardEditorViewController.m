//
//  KPCardEditorViewController.m
//  KindredPrints-iOS-TestBed
//
//  Created by Alex Austin on 2/17/14.
//  Copyright (c) 2014 Kindred Prints. All rights reserved.
//

#import "KPCardEditorViewController.h"
#import "KPOrderCompleteViewController.h"
#import "KPOrderSummaryViewController.h"
#import "UserPreferenceHelper.h"
#import "DevPreferenceHelper.h"
#import "InterfacePreferenceHelper.h"
#import "RoundedTextButton.h"
#import "KindredServerInterface.h"
#import "STPCard.h"
#import "Stripe.h"
#import "StripeError.h"
#import "UserObject.h"
#import "OrderManager.h"
#import "OrderProcessingHelper.h"
#import "LoadingStatusView.h"

@interface KPCardEditorViewController () <ServerInterfaceDelegate, UITextFieldDelegate, OrderProcessingDelegate, LoadingStatusViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *txtTotal;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *entryViews;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (weak, nonatomic) IBOutlet UITextField *txtNameField;
@property (weak, nonatomic) IBOutlet UITextField *txtCardField;
@property (weak, nonatomic) IBOutlet UITextField *txtDateFiel;
@property (weak, nonatomic) IBOutlet UITextField *txtSecCodeField;
@property (weak, nonatomic) IBOutlet UILabel *txtError;
@property (weak, nonatomic) IBOutlet RoundedTextButton *cmdCompleteOrder;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) OrderProcessingHelper *orderProcessing;
@property (strong, nonatomic) KindredServerInterface *kInterface;

@property (strong, nonatomic) OrderManager *orderManager;
@property (strong, nonatomic) UserObject *currUser;
@property (strong, nonatomic) NSArray *selectedAddresses;
@property (strong, nonatomic) NSArray *currOrders;

@property (strong, nonatomic) LoadingStatusView *progBarView;

@property (nonatomic) BOOL checkout;

@end

@implementation KPCardEditorViewController

static NSInteger STATE_ENTRY = 0;
static NSInteger STATE_LOADING = 1;
static NSInteger STATE_ERROR = 2;

- (KindredServerInterface *)kInterface {
    if (!_kInterface) {
        _kInterface = [[KindredServerInterface alloc] init];
        _kInterface.delegate = self;
    }
    
    return _kInterface;
}
- (OrderProcessingHelper *)orderProcessing {
    if (!_orderProcessing) {
        _orderProcessing = [[OrderProcessingHelper alloc] init];
        _orderProcessing.delegate = self;
    }
    return _orderProcessing;
}
- (OrderManager *)orderManager {
    if (!_orderManager) _orderManager = [OrderManager getInstance];
    return _orderManager;
}
- (UserObject *)currUser {
    if (!_currUser) {
        _currUser = [UserPreferenceHelper getUserObject];
    }
    return _currUser;
}
- (LoadingStatusView *)progBarView {
    if (!_progBarView) {
        CGRect screenBounds = [InterfacePreferenceHelper getScreenBounds];
        _progBarView = [[LoadingStatusView alloc] initWithFrame:CGRectMake(0, 0, screenBounds.size.width, screenBounds.size.height)];
        _progBarView.delegate = self;
        [self.view addSubview:_progBarView];
    }
    return _progBarView;
}
- (NSArray *)selectedAddresses {
    if (!_selectedAddresses)
        _selectedAddresses = [UserPreferenceHelper getSelectedAddresses];
    return _selectedAddresses;
}
- (NSArray *)currOrders {
    if (!_currOrders) {
        _currOrders = [UserPreferenceHelper getSelectedOrders];
    }
    return _currOrders;
}


- (void) initCustomView {
    for (UIView *v in self.entryViews)
        [self.view bringSubviewToFront:v];
    [self.view bringSubviewToFront:self.activityView];
    [self.view bringSubviewToFront:self.txtError];
    if (self.viewContainer) [self.view bringSubviewToFront:self.viewContainer];
    if (self.scrollView) [self.view bringSubviewToFront:self.scrollView];
    [self.txtError setTextColor:[InterfacePreferenceHelper getColor:ColorError]];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(270, 0, 50, 35)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(closeKeyboard)],
                           nil];
    self.txtNameField.inputAccessoryView = numberToolbar;
    self.txtCardField.inputAccessoryView = numberToolbar;
    self.txtDateFiel.inputAccessoryView = numberToolbar;
    self.txtSecCodeField.inputAccessoryView = numberToolbar;
    
    if (!self.completePurchase) {
        [self.cmdCompleteOrder setHidden:YES];
    } else {
        [self.cmdCompleteOrder drawButtonWithStrokeColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton] withBaseFillColor:[InterfacePreferenceHelper getColor:ColorCompleteOrderButton] andPressedFillColor:[UIColor whiteColor] andTextColor:[UIColor whiteColor] andText:@"COMPLETE ORDER" andFontSize:MenuButtonFontSize];
    }
    
    [self setInterfaceState:STATE_ENTRY];

    [self.txtTotal setText:[UserPreferenceHelper getOrderTotal]];
    [self initWithCardData];
}

- (void) initNavBar {
    [self initNavBarWithTitle:@"ENTER CARD" andNextTitle:@"DONE"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)cmdNextClick {
    if ([self validateCardInfo]) {
        if (!self.completePurchase)
            self.checkout = NO;
        else
            self.checkout = YES;
        [self launchCardRegProcess];
    }
}

- (void)setInterfaceState:(NSInteger)state {
    if (state == STATE_ENTRY || state == STATE_ERROR) {
        for (UIView *v in self.entryViews)
            [v setHidden:NO];
        [self.activityView setHidden:YES];
        if (state == STATE_ERROR)
            [self.txtError setHidden:NO];
        else
            [self.txtError setHidden:YES];
    } else {
        for (UIView *v in self.entryViews)
            [v setHidden:YES];
        [self.txtError setHidden:YES];
        [self.activityView setHidden:NO];
    }
}

- (void) initWithCardData {
    if (self.currUser.uPaymentSaved) {
        [self.txtNameField setText:self.currUser.uName];
        [self.txtCardField setText:[NSString stringWithFormat:@"XXXX XXXX XXXX %@", self.currUser.uLastFour]];
        [self.txtSecCodeField setText:@"XXX"];
    }
}

- (IBAction)cmdCompleteOrderClick:(id)sender {
    [self setInterfaceState:STATE_LOADING];
    [self closeKeyboard];

    if ([self validateCardInfo]) {
        self.checkout = YES;
        [self launchCardRegProcess];
    } else if (self.currUser.uPaymentSaved) {
        [self.orderProcessing initiateCheckoutSequence];
    }
}

- (void) launchCardRegProcess {
    [self closeKeyboard];
    [self.progBarView updateStatusCellWithMessage:@"registering new card.." andProgress:0.0];
    [self.progBarView show];
    
    NSUInteger tempInt = 0;
    NSString *card = [self removeNonDigits:self.txtCardField.text andPreserveCursorPosition:&tempInt];
    NSString *date = [self removeNonDigits:self.txtDateFiel.text andPreserveCursorPosition:&tempInt];
    [self getStripeToken:card expMonth:[self getMonth:date] expYear:[self getYear:date] andCvv:self.txtSecCodeField.text];
    
    NSDictionary *post = [[NSDictionary alloc]
                          initWithObjects:
                          @[self.currUser.uAuthKey, self.txtNameField.text]
                          forKeys:
                          @[@"auth_key", @"name"]];
    [self.kInterface registerName:post userId:self.currUser.uId];
}

#pragma mark form validation

-(BOOL) isFormFilledOut
{
    for(UIView *view in self.entryViews)
    {
        if([view isKindOfClass:[UITextField class]])
        {
            if([DevPreferenceHelper testForNullValue:((UITextField *)view).text])
            {
                return NO;
            }
        }
    }
    return YES;
}
-(BOOL) validateCardInfo {
    NSUInteger tempInt = 0;
    if (![self isFormFilledOut]) {
        [self.txtError setText:@"Unfortunately, it appears that you left some fields blank!"];
        [self setInterfaceState:STATE_ERROR];
        return NO;
    } else if (![self luhnCheck:[self removeNonDigits:self.txtCardField.text andPreserveCursorPosition:&tempInt]]) {
        [self.txtError setText:@"Unfortunately, it appears that your card number is invalid. Please make sure you entered it correctly."];
        [self setInterfaceState:STATE_ERROR];
        return NO;
    } else if (![self expDateCheck:[self removeNonDigits:self.txtDateFiel.text andPreserveCursorPosition:&tempInt]]) {
        [self.txtError setText:@"Unfortunately, it appears that the expiration date is invalid. Please make sure you entered it correctly."];
        [self setInterfaceState:STATE_ERROR];
        return NO;
    }
    return YES;
}



#pragma mark Server Interface Callback

- (void) serverCallback:(NSDictionary *)returnedData {
    if (returnedData) {
        NSInteger status = [[returnedData objectForKey:kpServerStatusCode] integerValue];
        NSString *requestTag = [returnedData objectForKey:kpServerRequestTag];
        
        if ([requestTag isEqualToString:REQ_TAG_STRIPE_REG]) {
            if (status == 200) {
                self.currUser.uPaymentSaved = [[returnedData objectForKey:@"payment_status"] boolValue];
                self.currUser.uCreditType = [returnedData objectForKey:@"card_type"];
                self.currUser.uLastFour = [returnedData objectForKey:@"last_four"];
                [UserPreferenceHelper setUserObject:self.currUser];
                
                if (self.checkout) {
                    [self.orderProcessing initiateCheckoutSequence];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } else if (status < 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Connection Error" message:@"Printing your images requires a stable internet connection. Please try again with better reception!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                [self.txtError setText:@"Error: Card declined. Please check your entry."];
                [self setInterfaceState:STATE_ERROR];
            }
            [self.progBarView hide];
        } else if ([requestTag isEqualToString:REQ_TAG_NAME_REG]) {
            if (status == 200) {
                self.currUser.uName = self.txtNameField.text;
                [UserPreferenceHelper setUserObject:self.currUser];
            }
        }
    }
}


#pragma mark Stripe Reg Method

-(void) getStripeToken:(NSString *)cardNumber expMonth:(NSUInteger)month expYear:(NSUInteger)year andCvv:(NSString *)cvv
{
    STPCard *card = [[STPCard alloc] init];
    if([DevPreferenceHelper getIsStripeTest]) {
        card.number = @"4242424242424242";
        card.expMonth = 1;
        card.expYear = 2017;
        
    } else {
        card.number = cardNumber;
        card.expMonth = month;
        card.expYear = year;
        card.cvc = cvv;
    }
    
    STPCompletionBlock completionHandler = ^(STPToken *token, NSError *error)
    {
        if (error) {
            [self.progBarView hide];
            [self setInterfaceState:STATE_ERROR];
            [self.txtError setText:[NSString stringWithFormat:@"Error: %@", [error localizedDescription]]];
        } else {
            [self registerStripeToken:token.tokenId];
        }
    };
    
    [Stripe createTokenWithCard:card
                 publishableKey:[DevPreferenceHelper getStripeKey]
                     completion:completionHandler];
}

- (void) registerStripeToken:(NSString *)stripeToken {
    [self.progBarView updateStatusCellWithMessage:@"saving new card.." andProgress:0.5];

    NSDictionary *post = [[NSDictionary alloc]
                          initWithObjects:
                          @[self.currUser.uAuthKey, stripeToken]
                          forKeys:
                          @[@"auth_key", @"stripe_token"]];
    [self.kInterface registerStripeToken:post userId:self.currUser.uId];
}


#pragma mark Keyboard Methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)replacementString {
    NSString *textAfterReplacing = [textField.text stringByReplacingCharactersInRange:range withString:replacementString];
    NSUInteger targetCursorPosition = range.location + [replacementString length];
    NSString *stringOnlyNumbers = [self removeNonDigits:textAfterReplacing andPreserveCursorPosition:&targetCursorPosition];
    
    BOOL isDelete = NO;
    if (range.location < [textField.text length] && [replacementString isEqualToString:@""])
        isDelete = YES;
    
    if ([textField isEqual:self.txtDateFiel]) {
        if ([stringOnlyNumbers length] > 4)
            return NO;
        
        if (![self expDateCheck:stringOnlyNumbers]) {
            [textField setTextColor:[UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1]];
        } else {
            [textField setTextColor:[UIColor whiteColor]];
        }
        
        NSString *expDateWithSpaces = [self insertSlashEveryTwoDigitsIntoString:(NSString *)stringOnlyNumbers andPreserveCursorPosition:&targetCursorPosition ignoreTrailingSpace:isDelete];
        
        textField.text = expDateWithSpaces;
        UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument]
                                                                  offset:targetCursorPosition];
        [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
        
        return NO;
    } else if ([textField isEqual:self.txtSecCodeField]){
        if ([textAfterReplacing length] > 4)
            return NO;
    } else if ([textField isEqual:self.txtNameField]) {
        if ([textAfterReplacing length] > 32)
            return NO;
    } else {
        if ([stringOnlyNumbers length] > 16) {
            // If the user is trying to enter more than 16 digits, we cancel the entire operation and leave the text field as it was.
            return NO;
        }
        
        if (![self luhnCheck:stringOnlyNumbers] && [stringOnlyNumbers length] == 16) {
            [textField setTextColor:[UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1]];
        } else {
            [textField setTextColor:[UIColor whiteColor]];
        }
        
        NSString *cardNumberWithSpaces = [self insertSpacesEveryFourDigitsIntoString:(NSString *)stringOnlyNumbers andPreserveCursorPosition:&targetCursorPosition ignoreTrailingSpace:isDelete];
        
        textField.text = cardNumberWithSpaces;
        UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument]
                                                                  offset:targetCursorPosition];
        [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
        
        return NO;
    }
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


- (NSString *)removeNonDigits:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition {
    NSUInteger targetCursorPositionInOriginalReplacementString = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd) || characterToAdd == '*') {
            NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < targetCursorPositionInOriginalReplacementString) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition ignoreTrailingSpace:(BOOL)ignore {
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
        if ((i>0) && (((i+1) % 4) == 0) && (i+1) < 16 && !(ignore && (i+1) == [string length])) {
            [stringWithAddedSpaces appendString:@" "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
    }
    
    return stringWithAddedSpaces;
}

- (NSString *)insertSlashEveryTwoDigitsIntoString:(NSString *)string andPreserveCursorPosition:(NSUInteger *)cursorPosition ignoreTrailingSpace:(BOOL)ignore {
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd = [NSString stringWithCharacters:&characterToAdd length:1];
        [stringWithAddedSpaces appendString:stringToAdd];
        if ((i>0) && (((i+1) % 2) == 0) && (i+1)<4 && !(ignore && (i+1) == [string length])) {
            [stringWithAddedSpaces appendString:@" / "];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition) = (*cursorPosition) + 3;
            }
        }
    }
    
    return stringWithAddedSpaces;
}

- (BOOL) luhnCheck:(NSString *)stringToTest {
    
    NSMutableArray *stringAsChars = [[NSMutableArray alloc] init];
    for (int i = 0; i < [stringToTest length]; i++) {
        [stringAsChars addObject:[NSString stringWithFormat:@"%C", [stringToTest characterAtIndex:i]]];
    }
    
    BOOL isOdd = YES;
    int oddSum = 0;
    int evenSum = 0;
    
    for (NSInteger i = [stringToTest length] - 1; i >= 0; i--) {
        
        int digit = [(NSString *)[stringAsChars objectAtIndex:i] intValue];
        
        if (isOdd)
            oddSum += digit;
        else
            evenSum += digit/5 + (2*digit) % 10;
        
        isOdd = !isOdd;
    }
    
    return ((oddSum + evenSum) % 10 == 0);
}

- (int) getMonth:(NSString *)string {
    NSRange monthRange = NSMakeRange(0,2);
    return [[string substringWithRange:monthRange] intValue];
}
- (int) getYear:(NSString *)string {
    NSRange yearRange = NSMakeRange(2,2);
    return [[string substringWithRange:yearRange] intValue];
}
- (BOOL) expDateCheck:(NSString *)stringToTest {
    if ([stringToTest length] < 2)
        return YES;
    
    int month = [self getMonth:stringToTest];
    
    if (month < 1 || month > 12)
        return NO;
    
    if ([stringToTest length] < 4)
        return YES;
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:currentDate]; // Get necessary date components
    NSInteger thisYear = [components year];
    NSInteger thisMonth = [components month];
    
    
    int year = [self getYear:stringToTest];
    
    if (year+2000 < thisYear || ((year+2000) == thisYear && month < thisMonth))
        return NO;
    
    if ((year+2000) > thisYear+15)
        return NO;
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.scrollView) [self.scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y-20) animated:YES];
    return YES;
}

- (void)keyboardDidHideNotification:(NSNotification *)notification {
    if (self.scrollView) [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

-(void)closeKeyboard {
    [self.txtCardField resignFirstResponder];
    [self.txtNameField resignFirstResponder];
    [self.txtDateFiel resignFirstResponder];
    [self.txtSecCodeField resignFirstResponder];
    if (self.scrollView) [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark order processor delegate

- (void)orderCreatedAndReturnedLineItems:(NSArray *)lineItems {
    
}

- (void)orderProcessingUpdateProgress:(CGFloat)progress withStatus:(NSString *)message {
    
}

- (void)paymentProcessed {
    KPOrderCompleteViewController *orderFinishedVC = [[KPOrderCompleteViewController alloc] initWithNibName:@"KPOrderCompleteViewController" bundle:nil];
    [self.navigationController setViewControllers:@[orderFinishedVC] animated:YES];
}

- (void)orderFailedToProcess:(NSString *)error {
    [self.txtError setText:error];
    [self setInterfaceState:STATE_ERROR];
}

@end
