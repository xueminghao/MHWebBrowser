//
//  MHViewController.m
//  MHWebBrowser
//
//  Created by 薛明浩 on 01/22/2019.
//  Copyright (c) 2019 薛明浩. All rights reserved.
//

#import "MHViewController.h"

#define BridgeMethodName @"BridgeMethodName"
#define BridgeMethodParams @"BridgeMethodParams"

@interface MHViewController ()<MHWebBrowserVCDelegate>

@end

@implementation MHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

#pragma mark - MHWebBrowserVCDelegate

- (void)webBrowser:(MHWebBrowserVC *)vc didReceiveScriptMessage:(NSDictionary *)message withResolveHandler:(MHWebViewResolveHandler)resolveHandler rejectHandler:(MHWebViewRejectHandler)rejectHandler {
    NSString *methodName = message[BridgeMethodName];
    if ([methodName isEqualToString:@"getBundleVersion"]) {
        resolveHandler([self getBundleVersion]);
    } else if ([methodName isEqualToString:@"sendApiRequest"]) {
        [self sendApiRequest:^{
            resolveHandler(@"Done");
        }];
    }
}

- (NSString *)getBundleVersion {
    return [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
}

- (void)sendApiRequest:(void(^)())completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completion();
    });
}
@end
