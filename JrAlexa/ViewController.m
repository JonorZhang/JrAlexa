//
//  ViewController.m
//  JrAlexa
//
//  Created by Jonor on 2018/8/27.
//  Copyright © 2018年 Jonor. All rights reserved.
//

#import "ViewController.h"
#import "AudioManager.h"
#import "AlexaClient.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *micBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UIImageView *speaker;
@property (weak, nonatomic) IBOutlet UITextView *directivesTextView;

@property (weak, nonatomic) IBOutlet UIView *signedInView;
@property (weak, nonatomic) IBOutlet UILabel *userProfile;

@property (nonatomic, strong) AudioManager *audioManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showLogInPage];
    [AlexaClient.shareClient checkLogin:[self loginRequestHandler]];
    _audioManager = [AudioManager shareManager];
    _directivesTextView.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width * 4, UIScreen.mainScreen.bounds.size.height*10);
}


#pragma mark - Update UI

- (void)showLogInPage {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.signedInView.hidden = true;
    });
}

- (void)showSignedInUser:(AMZNUser *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.signedInView.hidden = false;
        self.userProfile.text = [NSString stringWithFormat:@"%@(%@)", user.name, user.email];
    });
}

- (void)showAlertTitle:(NSString *)title message:(NSString *)message btnTitle:(NSString *)btnTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:true completion:nil];
    });
}

- (void)showMicLevel:(short)level {
    if (level > 14) {
        NSLog(@"⚠️level should be [0...14]");
        return;
    }
    NSString *name = [NSString stringWithFormat:@"record_animate_%02d", level];
    UIImage *img = [UIImage imageNamed:name];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.micBtn setImage:img forState:UIControlStateNormal];
    });
}


#pragma mark - Handler

- (AMZNAuthorizationRequestHandler)loginRequestHandler {
    return ^(AMZNAuthorizeResult * _Nullable result, BOOL userDidCancel, NSError * _Nullable error) {
        if (error) {
            // Notify the user that authorization failed
            [self showAlertTitle:@""
                         message:[NSString stringWithFormat:@"User authorization failed due to an error: %@", error.userInfo[@"AMZNLWAErrorNonLocalizedDescription"]]
                        btnTitle:@"OK"];
        } else if (userDidCancel) {
            // Notify the user that the authorization was cancelled
            [self showAlertTitle:@""
                         message:@"Authorization was cancelled prior to completion. To continue, you will need to try logging in again."
                        btnTitle:@"OK"];
        } else {
            // Authentication was successful. Obtain the user profile data.
            [self showSignedInUser:result.user];
        }
    };
}

- (AlexaSpeechRecognizeHandler)speechRecognizeHandler {
    return ^(NSArray * _Nullable directives, NSError * _Nullable error) {
        if (error) {
            [self showAlertTitle:@""
                         message:[NSString stringWithFormat:@"Speech recognize failed: %@", error.userInfo[NSLocalizedDescriptionKey]]
                        btnTitle:@"OK"];
        } else if (directives) {
            [directives enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj[@"type"] isEqualToString:kContentTypeAudio]) {
                    self.speaker.hidden = false;
                    [AudioManager.shareManager playAudioData:obj[@"content"] completionHandler:^(BOOL successfully) {
                        self.micBtn.enabled = true;
                        self.speaker.hidden = true;
                    }];
                    return;
                } else {
                    self.directivesTextView.text = [self.directivesTextView.text stringByAppendingString:obj.description];
                }
            }];
        }
        [self.activityView stopAnimating];
        self.micBtn.enabled = true;
    };
}


#pragma mark - Button Clicked

- (IBAction)clickedLogin:(id)sender {
    [AlexaClient.shareClient loginWithAmazon:[self loginRequestHandler]];
}

- (IBAction)clickedLogout:(id)sender {
    [[AMZNAuthorizationManager sharedManager] signOut:^(NSError * _Nullable error) {
        if (!error) {
            [self showLogInPage];
        }
    }];
}

- (IBAction)clickedMicrophone:(UIButton *)sender {
    static short lastLevel = 1;
    if (_audioManager.isRecording) {
        [_audioManager recordStop];
        [sender.superview setBackgroundColor:[UIColor whiteColor]];
    } else {
        self.directivesTextView.text = nil;
        
        [sender.superview setBackgroundColor:[UIColor blackColor]];
        [_audioManager recordStartWithProcess:^(float peakPower) {
            short level = (peakPower+0.05) * 14;
            if (level != lastLevel) {
                lastLevel = level;
                [self showMicLevel:level];
                [sender.superview setBackgroundColor:[UIColor colorWithRed:peakPower green:0 blue:0 alpha:1]];
            }
        } failed:^(NSError *error) {
            NSLog(@"mic-error=%@", error);
            [self showMicLevel:0];
        } completed:^(NSData *data) {
            NSLog(@"mic-data=%lu", (unsigned long)data.length);
            self.micBtn.enabled = false;
            [self.activityView startAnimating];
            [self showMicLevel:0];
            [AlexaClient.shareClient speechRecognize:data withCompleteHandler:[self speechRecognizeHandler]];
        }];
    }
}


#pragma mark - Delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        return YES;
    }
    return NO;
}

@end
