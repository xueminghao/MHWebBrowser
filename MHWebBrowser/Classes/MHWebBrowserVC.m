//
//  MHWebBrowserVC.m
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/22.
//

#import "MHWebBrowserVC.h"

@import WebKit;

static NSArray *kvoProperties;

@interface MHWebBrowserVC ()

@property (nonatomic, strong) WKWebViewConfiguration *webViewConfiguration;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *loadingProgressView;

@property (nonatomic, copy) NSString *initialURLString;
@property (nonatomic, copy) NSString *URLString;

@end

@implementation MHWebBrowserVC

#pragma mark - Life cycles

- (instancetype)initWithURLString:(NSString *)URLString {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.initialURLString = URLString;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            kvoProperties = @[
              @"title",
              @"loading",
              @"estimatedProgress"
              ];
        });
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithURLString:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithURLString:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self mh_setupSubViews];
    [self mh_addKVObservers];
    [self loadInitalRequest];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        [self loadingStatusChanged];
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self estimatedProgressChanged];
    } else if ([keyPath isEqualToString:@"title"]) {
        [self titleChanged];
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

- (void)loadURLString:(NSString *)URLString {
    if (URLString.length > 0) {
        self.URLString = URLString;
    }
    [self load];
}

#pragma mark - Private methods

- (void)mh_setupSubViews {
    self.webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webViewConfiguration];
    self.edgesForExtendedLayout = UIRectEdgeAll;
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

- (void)mh_removeKVObservers {
    for (NSString *property in kvoProperties) {
        [self.webView removeObserver:self forKeyPath:property];
    }
}

- (void)loadInitalRequest {
    if (self.initialURLString.length == 0) {
        return;
    }
    self.URLString = self.initialURLString;
    [self load];
}

- (void)load {
    NSURL *url = [NSURL URLWithString:self.URLString];
    NSURLRequest *reqeust = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:reqeust];
}

@end
