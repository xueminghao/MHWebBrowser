//
//  MHWebBrowserVC.h
//  MHWebBrowser
//
//  Created by Minghao Xue on 2019/1/22.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class MHWebBrowserVC;

@protocol MHWebBrowserVCDelegate <NSObject>



@end

@interface MHWebBrowserVC : UIViewController

#pragma mark - Initializers

/**
 Designated initializer.
 */
- (instancetype)initWithURL:(nullable NSURL *)url NS_DESIGNATED_INITIALIZER;

#pragma mark - Load

- (void)loadURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
