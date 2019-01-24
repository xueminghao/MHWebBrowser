//
//  MHBundleHelper.h
//  Masonry
//
//  Created by Minghao Xue on 2019/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MHBundleHelper : NSObject

+ (NSURL *)bundleURL;
+ (NSBundle *)resourceBundle;
+ (UIImage *)imageNamed:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
