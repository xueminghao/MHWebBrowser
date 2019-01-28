//
//  MHWebBrowserVC.m
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/22.
//

#import "MHWebBrowserVC.h"
#import "MHBundleHelper.h"

@interface MHWebBrowserVC ()<MHWebViewDelegate>

@property (nonatomic, strong) MHWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *closeItem;

@property (nonatomic, strong) NSURL *url;

@end

@implementation MHWebBrowserVC

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.url = url;
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
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(load)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    self.navigationItem.leftBarButtonItem = [self getBackItemIfAvaliable];
    self.webView = [[MHWebView alloc] initWithURL:self.url];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void)viewDidLayoutSubviews {
    CGRect bounds = self.view.bounds;
    CGFloat topBarOffset = self.topLayoutGuide.length;
    CGRect webViewFrame = CGRectMake(0,
                                     topBarOffset,
                                     bounds.size.width,
                                     bounds.size.height - topBarOffset);
    self.webView.frame = webViewFrame;
}

- (void)didReceiveScriptMessage:(NSDictionary *)message withResolveHandler:(MHWebViewResolveHandler)resolveHandler rejectHandler:(MHWebViewRejectHandler)rejectHandler {
    
}

- (void)load {
    [self.webView reload];
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
#pragma mark - MHWebViewDelegate

- (void)webView:(MHWebView *)webView canGoBackDidChanged:(BOOL)canGoBack {
    NSMutableArray<UIBarButtonItem *> *items = [NSMutableArray new];
    UIBarButtonItem *backItem = [self getBackItemIfAvaliable];
    if (canGoBack) {
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

- (void)webView:(MHWebView *)webView pageTitleDidChanged:(NSString *)title {
    self.title = title;
}

- (void)webView:(MHWebView *)webView didReceiveScriptMessage:(NSDictionary *)message withResolveHandler:(MHWebViewResolveHandler)resolveHandler rejectHandler:(MHWebViewRejectHandler)rejectHandler {
    [self didReceiveScriptMessage:message withResolveHandler:resolveHandler rejectHandler:rejectHandler];
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

- (UIBarButtonItem *)getBackItemIfAvaliable {
    if (self.navigationController.viewControllers.count > 1) {
        return self.backItem;
    }
    return nil;
}

@end
