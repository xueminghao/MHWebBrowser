//
//  MHWebBrowserVC.m
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/22.
//

#import "MHWebBrowserVC.h"
#import "MHBundleHelper.h"

#define BridgeTunnel @"bridgeTunnel"
#define BridgeTunnelMessagePromiseIdendifier @"BridgeTunnelMessagePromiseIdendifier"

@import WebKit;

static NSArray *kvoProperties;

@interface MHWebBrowserVC ()<WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebViewConfiguration *webViewConfiguration;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *loadingProgressView;

@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;

@property (nonatomic, copy) NSURL *initialURL;
@property (nonatomic, strong) NSURL *url;

@end

@implementation MHWebBrowserVC

#pragma mark - Life cycles

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithNibName:nil bundle:nil]) {
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
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithURL:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithURL:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self mh_setupSubViews];
    [self mh_addKVObservers];
    [self loadInitalRequest];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(load)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    self.navigationItem.leftBarButtonItem = [self getBackItemIfAvaliable];
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

- (void)viewDidLayoutSubviews {
    CGRect bounds = self.view.bounds;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    CGRect webViewFrame = CGRectMake(0,
                                      topBarOffset,
                                      bounds.size.width,
                                      bounds.size.height - topBarOffset);
    self.webView.frame = webViewFrame;
    
    CGRect progressViewFrame = CGRectMake(0,
                                              topBarOffset,
                                              bounds.size.width,
                                              1);
    self.loadingProgressView.frame = progressViewFrame;
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
        if ([self.delegate respondsToSelector:@selector(webBrowser:didReceiveScriptMessage:withResolveHandler:rejectHandler:)]) {
            [self.delegate webBrowser:self didReceiveScriptMessage:[dict copy] withResolveHandler:^(id _Nonnull data) {
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

#pragma mark - Lazy load properties

- (UIBarButtonItem *)backItem {
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] initWithImage:[MHBundleHelper imageNamed:@"back"] style:UIBarButtonItemStyleDone target:self action:@selector(backItemClicked)];
    }
    return _backItem;
}

- (UIBarButtonItem *)closeItem {
    if (!_closeItem) {
        _closeItem = [[UIBarButtonItem alloc] initWithImage:[MHBundleHelper imageNamed:@"close"] style:UIBarButtonItemStyleDone target:self action:@selector(closeItemClicked)];
    }
    return _closeItem;
}

#pragma mark - Target action methods

- (void)backItemClicked {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeItemClicked {
    [self.navigationController popViewControllerAnimated:YES];
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
    [self.view addSubview:self.webView];
    
    self.loadingProgressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.loadingProgressView];
    self.loadingProgressView.hidden = YES;
}

- (void)mh_addKVObservers {
    for (NSString *property in kvoProperties) {
        [self.webView addObserver:self forKeyPath:property options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)loadingStatusChanged {
    self.loadingProgressView.hidden = !self.webView.loading;
}

- (void)estimatedProgressChanged {
    self.loadingProgressView.progress = self.webView.estimatedProgress;
}

- (void)titleChanged {
    self.title = self.webView.title;
}

- (void)canGoBackChanged {
    NSMutableArray<UIBarButtonItem *> *items = [NSMutableArray new];
    UIBarButtonItem *backItem = [self getBackItemIfAvaliable];
    if (self.webView.canGoBack) {
        if (backItem) {
            [items addObject:self.backItem];
        }
        [items addObject:self.closeItem];
    } else {
        if (backItem) {
            [items addObject:self.backItem];
        }
    }
    self.navigationItem.leftBarButtonItems = [items copy];
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

- (UIBarButtonItem *)getBackItemIfAvaliable {
    if (self.navigationController.viewControllers.count > 1) {
        return self.backItem;
    }
    return nil;
}

@end
