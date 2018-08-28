//
//  AlexaClient.h
//  JrAlexa
//
//  Created by Jonor on 2018/8/27.
//  Copyright © 2018年 Jonor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoginWithAmazon/LoginWithAmazon.h>

NS_ASSUME_NONNULL_BEGIN


extern NSString * const kContentTypeJSON;
extern NSString * const kContentTypeAudio;


@interface AlexaClient : NSObject

@property (class, readonly, strong, null_unspecified) AlexaClient *shareClient;

@property (nonatomic, strong, nullable) AMZNAuthorizeResult *authorization;

- (void)ping;
- (void)reportCapabilitiesIfNeed;

@end


@interface AlexaClient (LoginWithAmazon)

- (void)loginWithAmazon:(AMZNAuthorizationRequestHandler)handler;
- (void)checkLogin:(AMZNAuthorizationRequestHandler)handler;

@end


@interface AlexaClient (SpeechRecognizer)

typedef void (^AlexaSpeechRecognizeHandler)(NSArray * _Nullable directives, NSError * _Nullable error);

- (void)speechRecognize:(NSData *)data withCompleteHandler:(AlexaSpeechRecognizeHandler)handler;

@end

NS_ASSUME_NONNULL_END
