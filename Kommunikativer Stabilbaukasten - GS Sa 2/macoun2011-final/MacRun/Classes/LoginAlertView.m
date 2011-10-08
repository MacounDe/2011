//
//  LoginAlertView.m
//  MacRun
//
//  Created by Pascal Bihler on 15.09.11.
//  Copyright 2011 Universität Bonn. All rights reserved.
//

#import "LoginAlertView.h"


NSString * const MRUsername = @"username";		//!< Key to store the login username
NSString * const MRPasswordHash = @"passwordHash";		//!< Key to store the hashed user password

@interface  LoginAlertView ()
- (void) checkField:(UITextField *)sender;
- (void) editEnded:(UITextField *)sender;
@end


@implementation LoginAlertView

@synthesize nameField,passwordField;

- (id) initWithAlertViewDelegate:(id<UIAlertViewDelegate>)delegate {
	if ([self initWithTitle:@"Beim Server anmelden" message:@"\n\n\n\n\n"
                   delegate:delegate 
          cancelButtonTitle:@"Abbrechen" 
		  otherButtonTitles:@"Anmelden", nil]) {
		
		// get OK button (the last one) and add handlers to dismiss the keyboard to all buttons
		for (UIView * subView in [self subviews]) {
			if ([subView isKindOfClass:[UIControl class]]) {
				okButton = (UIControl*) subView;
				[okButton addTarget:self action:@selector(editEnded:) forControlEvents:UIControlEventTouchUpInside];
			}
		}
        
        okButton.enabled = NO;
        
		
		checkImage = [[UIImage imageWithContentsOfFile:
                       [[NSBundle mainBundle] pathForResource:@"check" ofType:@"png"]] retain];
		errorImage = [[UIImage imageWithContentsOfFile:
                       [[NSBundle mainBundle] pathForResource:@"important" ofType:@"png"]] retain];
		
		UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
		alertLabel.font = [UIFont systemFontOfSize:16];
		alertLabel.textColor = [UIColor whiteColor];
		alertLabel.backgroundColor = [UIColor clearColor];
		alertLabel.shadowColor = [UIColor blackColor];
		alertLabel.shadowOffset = CGSizeMake(0,-1);
		alertLabel.textAlignment = UITextAlignmentCenter;
		alertLabel.text = @"MacRunners-Anmeldedaten:";
		[self addSubview:alertLabel];
		[alertLabel release];
		
		nameField = [[UITextField alloc] initWithFrame:CGRectMake(16,78,252,31)];
		nameField.font = [UIFont systemFontOfSize:17];
		nameField.borderStyle = UITextBorderStyleRoundedRect;
		nameField.keyboardAppearance = UIKeyboardAppearanceAlert;
		nameField.keyboardType = UIKeyboardTypeEmailAddress;
		nameField.autocorrectionType = UITextAutocorrectionTypeNo;
		nameField.rightViewMode = UITextFieldViewModeAlways;
        nameField.placeholder = @"Name";
		nameField.delegate = self;
		[nameField addTarget:self action:@selector(checkField:) forControlEvents:UIControlEventEditingChanged];
		[nameField addTarget:self action:@selector(editEnded:) forControlEvents:UIControlEventEditingDidEnd];
        
		passwordField = [[UITextField alloc] initWithFrame:CGRectMake(16,115,252,31)];
		passwordField.font = [UIFont systemFontOfSize:17];
		passwordField.borderStyle = UITextBorderStyleRoundedRect;
		passwordField.keyboardAppearance = UIKeyboardAppearanceAlert;
		passwordField.keyboardType = UIKeyboardTypeEmailAddress;
		passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
		passwordField.rightViewMode = UITextFieldViewModeAlways;
        passwordField.secureTextEntry = YES; 
        passwordField.placeholder = @"Passwort";
		passwordField.delegate = self;
		[passwordField addTarget:self action:@selector(checkField:) forControlEvents:UIControlEventEditingChanged];
		[passwordField addTarget:self action:@selector(editEnded:) forControlEvents:UIControlEventEditingDidEnd];
		
		NSString * lastUsername = [[NSUserDefaults standardUserDefaults] objectForKey:MRUsername];
		nameField.text = lastUsername;
        
		
		[nameField becomeFirstResponder];
		[self addSubview:nameField];
		[self addSubview:passwordField];
		[self setTransform:CGAffineTransformMakeTranslation(0,0)];
	}
	
	return self;
}


- (void) checkField:(UITextField *)sender {
	BOOL fieldOK = [sender.text length] > 2;
	UIImageView * rightImageView =  [[UIImageView alloc] initWithImage:(fieldOK ? checkImage : errorImage)];
	sender.rightView = rightImageView;
	[rightImageView release];
    
	okButton.enabled =  ([nameField.text length] > 2) && ([passwordField.text length]>2);
;	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	BOOL fieldOK = [textField.text length] > 3;
	if (fieldOK) {
		[textField resignFirstResponder];
	}
	return fieldOK;
}

- (void) editEnded:(UITextField *)sender {
	[sender resignFirstResponder];
}

-(void) dealloc {
	[nameField release];
	[passwordField release];
	[checkImage release];
	[errorImage release];
	
	[super dealloc];
}



@end
