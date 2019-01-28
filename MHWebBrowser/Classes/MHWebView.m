//
//  MHWebView.m
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/28.
//

#import "MHWebView.h"
#import "MHBundleHelper.h"

#define BridgeTunnel @"bridgeTunnel"
#define BridgeTunnelMessagePromiseIdendifier @"BridgeTunnelMessagePromiseIdendifier"

@import WebKit;

static NSArray *kvoProperties;

@interface MHWebView ()<WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebViewConfiguration *webViewConfiguration;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *loadingProgressView;

@property (nonatomic, copy) NSURL *initialURL;
@property (nonatomic, strong) NSURL *url;

@end

@implementation MHWebView

#pragma mark - Life cycles

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithFrame:CGRectZero]) {
        self.initialURL = url;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kvoProperties = @[
                              @"title",
                              @"loading",
                              @"estimatedProgress",
                              @"canGoBack"
                              ];
        });
        
        [self mh_setupSubViews];
        [self mh_addKVObservers];
        [self loadInitalRequest];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithURL:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithURL:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        [self loadingStatusChanged];
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self estimatedProgressChanged];
    } else if ([keyPath isEqualToString:@"title"]) {
        [self titleChanged];
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        [self canGoBackChanged];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)dealloc {
    [self mh_removeKVObservers];
}

#pragma mark - Public methods

- (void)loadURL:(NSURL *)URL {
    if (!URL) {
        return;
    }
    self.url = URL;
    [self load];
}

- (void)reload {
    [self load];
}

- (void)goBack {
    [self.webView goBack];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id _Nullable, NSError * _Nullable))completionHandler {
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengeRejectProtectionSpace, nil);
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:BridgeTunnel]) {
        if (![message.body isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *messageBody = message.body;
        NSString *promiseIdentifier = messageBody[BridgeTunnelMessagePromiseIdendifier];
        if (promiseIdentifier.length == 0) {
            return;
        }
        NSMutableDictionary *dict = [NSMutableDictionary new];
        for (NSString *key in messageBody.keyEnumerator) {
            if ([key isEqualToString:BridgeTunnelMessagePromiseIdendifier]) {
                continue;
            }
            [dict setObject:messageBody[key] forKey:key];
        }
        if ([self.delegate respondsToSelector:@selector(webView:didReceiveScriptMessage:withResolveHandler:rejectHandler:)]) {
            [self.delegate webView:self didReceiveScriptMessage:[dict copy] withResolveHandler:^(id _Nonnull data) {
                [self resolvePromise:promiseIdentifier withData:data];
            } rejectHandler:^(NSString * _Nonnull msg) {
                [self rejectPromise:promiseIdentifier withErrorMessage:msg];
            }];
        }
    }
}

#pragma mark - JSBridge

- (void)resolvePromise:(NSString *)promiseIdentifier withData:(id)data {
    if (promiseIdentifier.length == 0) {
        return;
    }
    NSString *jsCode = nil;
    id params = nil;
    if (data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = data;
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            params = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else if ([data isKindOfClass:[NSArray class]]) {
            NSArray *array = data;
            NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
            params = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        } else {
            params = data;
        }
    }
    if (params) {
        jsCode = [NSString stringWithFormat:@"resolveBridgePromise(\"%@\",\"%@\")", promiseIdentifier, params];
    } else {
        jsCode = [NSString stringWithFormat:@"resolveBridgePromise(\"%@\")", promiseIdentifier];
    }
    [self.webView evaluateJavaScript:jsCode completionHandler:nil];
}

- (void)rejectPromise:(NSString *)promiseIdentifier withErrorMessage:(NSString *)errorMessage {
    if (promiseIdentifier.length == 0) {
        return;
    }
    NSString *msg = errorMessage.length == 0 ? @"Unknown error happened." : errorMessage;
    NSString *jsCode = [NSString stringWithFormat:@"rejectBridgePromise(\"%@\",\"%@\")", promiseIdentifier, msg];
    [self.webView evaluateJavaScript:jsCode completionHandler:nil];
}

#pragma mark - Private methods

- (void)mh_setupSubViews {
    self.webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *contentController = self.webViewConfiguration.userContentController;
    NSString *scriptPath = [[MHBundleHelper resourceBundle] pathForResource:@"inject" ofType:@"js"];
    NSString *jsContent = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *bridgeScript = [[WKUserScript alloc] initWithSource:jsContent injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    [contentController addUserScript:bridgeScript];
    [contentController addScriptMessageHandler:self name:BridgeTunnel];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webViewConfiguration];
    self.webView.navigationDelegate = self;
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIApplicationBackgroundFetchIntervalNever;
    }
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self addSubview:self.webView];
    
    self.loadingProgressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.loadingProgressView];
    self.loadingProgressView.hidden = YES;
    NSArray *webViewHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webview]-0-|" options:0 metrics:nil views:@{@"webview":self.webView}];
    NSArray *webViewVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webview]-0-|" options:0 metrics:nil views:@{@"webview":self.webView}];
    NSArray *loadingHConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[progressview]-0-|" options:0 metrics:nil views:@{@"webview":self.webView,@"progressview":self.loadingProgressView}];
    NSArray *loadingVConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[progressview(1)]" options:0 metrics:nil views:@{@"webview":self.webView,@"progressview":self.loadingProgressView}];

    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.loadingProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:webViewHConstraints];
    [self addConstraints:webViewVConstraints];
    [self addConstraints:loadingHConstraints];
    [self addConstraints:loadingVConstraints];
}

- (void)mh_addKVObservers {
    for (NSString *property in kvoProperties) {
        [self.webView addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)loadingStatusChanged {
    self.loadingProgressView.hidden = !self.webView.loading;
    if ([self.delegate respondsToSelector:@selector(webView:loadingStatusDidChanged:)]) {
        [self.delegate webView:self loadingStatusDidChanged:self.webView.loading];
    }
}

- (void)estimatedProgressChanged {
    self.loadingProgressView.progress = self.webView.estimatedProgress;
    if ([self.delegate respondsToSelector:@selector(webView:loadingProgressDidChanged:)]) {
        [self.delegate webView:self loadingProgressDidChanged:self.webView.estimatedProgress];
    }
}

- (void)titleChanged {
    if ([self.delegate respondsToSelector:@selector(webView:pageTitleDidChanged:)]) {
        [self.delegate webView:self pageTitleDidChanged:self.webView.title];
    }
}

- (void)canGoBackChanged {
    self.canGoBack = self.webView.canGoBack;
    if ([self.delegate respondsToSelector:@selector(webView:canGoBackDidChanged:)]) {
        [self.delegate webView:self canGoBackDidChanged:self.webView.canGoBack];
    }
}

- (void)mh_removeKVObservers {
    for (NSString *property in kvoProperties) {
        [self.webView removeObserver:self forKeyPath:property];
    }
}

- (void)loadInitalRequest {
    [self loadURL:self.initialURL];
}

- (void)load {
    if ([self.url isFileURL]) {
        NSString *HTMLString = [NSString stringWithContentsOfURL:self.url encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:HTMLString baseURL:nil];
    } else {
        NSURLRequest *reqeust = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:reqeust];
    }
}

@end

