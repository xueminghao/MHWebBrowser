//
//  MHWebView.h
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MHWebView;

typedef void(^MHWebViewResolveHandler)(id);
typedef void(^MHWebViewRejectHandler)(NSString*);

@protocol MHWebViewDelegate <NSObject>
@optional
- (void)webView:(MHWebView *)webView loadingStatusDidChanged:(BOOL)loading;
- (void)webView:(MHWebView *)webView loadingProgressDidChanged:(double)progress;
- (void)webView:(MHWebView *)webView pageTitleDidChanged:(NSString *)title;
- (void)webView:(MHWebView *)webView canGoBackDidChanged:(BOOL)canGoBack;
- (void)webView:(MHWebView *)webView didReceiveScriptMessage:(NSDictionary *)message withResolveHandler:(MHWebViewResolveHandler)resolveHandler rejectHandler:(MHWebViewRejectHandler)rejectHandler;

@end

@interface MHWebView : UIView

#pragma mark - Initializers

/**
 Designated initializer.
 */
- (instancetype)initWithURL:(nullable NSURL *)url NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<MHWebViewDelegate> delegate;

@property (nonatomic, assign) BOOL canGoBack;

#pragma mark - Load

- (void)loadURL:(NSURL *)url;
- (void)reload;
- (void)goBack;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
