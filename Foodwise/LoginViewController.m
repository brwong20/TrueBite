//
//  LoginViewController.m
//  Foodwise
//
//  Created by Brian Wong on 8/21/16.
//  Copyright © 2016 Brian Wong. All rights reserved.
//

#import "LoginViewController.h"
#import "RestaurantListViewController.h"

#import <FirebaseAuth/FirebaseAuth.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LoginViewController()<FBSDKLoginButtonDelegate, GIDSignInUIDelegate , GIDSignInDelegate>

@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet GIDSignInButton *googleLoginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.fbLoginButton = [[FBSDKLoginButton alloc]init];
    self.fbLoginButton.center = self.view.center;
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email"];
    self.fbLoginButton.delegate = self;
    [self.view addSubview:self.fbLoginButton];
    
    //Google Sign-in button
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    //self.googleLoginButton = [[GIDSignInButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 - self.fbLoginButton.frame.size.width/2, CGRectGetMaxY(self.fbLoginButton.frame), self.fbLoginButton.frame.size.width, self.fbLoginButton.frame.size.height * 0.4)];
    self.googleLoginButton.style = kGIDSignInButtonStyleStandard;
    self.googleLoginButton.colorScheme = kGIDSignInButtonColorSchemeLight;
    
    //Use this for custom button!
    //[[GIDSignIn sharedInstance]signIn]
    
    [self.view addSubview:self.googleLoginButton];
}

- (IBAction)guestSignIn:(id)sender
{
    [[FIRAuth auth]signInAnonymouslyWithCompletion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Anon sign in successful!");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}
#pragma GIDSignInUIDelegate methods
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error
{
    if (!error) {
        GIDAuthentication *authentication = user.authentication;
        FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:authentication.idToken accessToken:authentication.accessToken];
        [[FIRAuth auth]signInWithCredential:credential completion:^(FIRUser * _Nullable user, NSError * _Nullable error) {
            if (user) {
                NSLog(@"Login to Firebase with Google successful!!!");
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                NSLog(@"Firebase login with Google failed...");
            }
        }];
    }
    else
    {
        NSLog(@"Google login failed...");
    }
}

#pragma FBSDKLoginButtonDelegate Methods

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if (error == nil) {
        FIRAuthCredential *credential = [FIRFacebookAuthProvider
                                         credentialWithAccessToken:[FBSDKAccessToken currentAccessToken]
                                         .tokenString];
        
        [[FIRAuth auth] signInWithCredential:credential completion:^(FIRUser *user, NSError *error) {
            if (user) {
                NSLog(@"User has logged into Firebase through Facebook!");
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }
    else
    {
        NSLog(@"Error loggin in FB:%@", error.localizedDescription);
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"User has logged out with Facebook");
}

@end
