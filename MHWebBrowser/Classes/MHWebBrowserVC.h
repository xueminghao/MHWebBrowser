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

- (instancetype)initWithURLString:(nullable NSString *)URLString NS_DESIGNATED_INITIALIZER;

#pragma mark - Load

- (void)loadURLString:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
