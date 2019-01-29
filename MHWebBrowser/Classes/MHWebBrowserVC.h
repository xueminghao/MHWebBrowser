//
//  MHWebBrowserVC.h
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/22.
//

@import UIKit;
#import "MHWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MHWebBrowserVC : UIViewController

@property (nonatomic, readonly) MHWebView *webView;

- (instancetype)initWithURL:(nullable NSURL *)url NS_DESIGNATED_INITIALIZER;

- (void)didReceiveScriptMessage:(NSDictionary *)message withResolveHandler:(MHWebViewResolveHandler)resolveHandler rejectHandler:(MHWebViewRejectHandler)rejectHandler;

@end

NS_ASSUME_NONNULL_END
