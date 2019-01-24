//
//  MHWebBrowserVC.h
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/22.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class MHWebBrowserVC;

typedef void(^MHWebViewResolveHandler)(id);
typedef void(^MHWebViewRejectHandler)(NSString*);

@protocol MHWebBrowserVCDelegate <NSObject>

- (void)webBrowser:(MHWebBrowserVC *)vc didReceiveScriptMessage:(NSDictionary *)message withResolveHandler:(MHWebViewResolveHandler)resolveHandler rejectHandler:(MHWebViewRejectHandler)rejectHandler;

@end

@interface MHWebBrowserVC : UIViewController

#pragma mark - Initializers

/**
 Designated initializer.
 */
- (instancetype)initWithURL:(nullable NSURL *)url NS_DESIGNATED_INITIALIZER;

@property (nonatomic, weak) id<MHWebBrowserVCDelegate> delegate;

#pragma mark - Load

- (void)loadURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
