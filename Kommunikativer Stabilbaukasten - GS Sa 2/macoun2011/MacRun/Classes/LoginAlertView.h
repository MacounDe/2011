//
//  LoginAlertView.h
//  MacRun
//
//  Created by Pascal Bihler on 15.09.11.
//  Copyright 2011 Universität Bonn. All rights reserved.
//

#import <UIKit/UIKit.h>


NSString * const MRUsername;		//!< Key to store the login username
NSString * const MRPasswordHash;		//!< Key to store the hashed user password

@interface LoginAlertView : UIAlertView <UITextFieldDelegate> {
    
	UITextField *nameField;
	UITextField *passwordField;
	
	UIImage * checkImage;	//!< Image of Check icon
	UIImage * errorImage;	//!< Image of Error icon
	
	UIControl * okButton;
}

@property(nonatomic,readonly) UITextField *nameField;		//!< The text field with the name
@property(nonatomic,readonly) UITextField *passwordField;		//!< The text field with the password

/**
 @brief		Inits the login dialog
 @param	delegate	the delegate of the alert view
 @result		the view
 */
- (id) initWithAlertViewDelegate:(id<UIAlertViewDelegate>)delegate;

@end
