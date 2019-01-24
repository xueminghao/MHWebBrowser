//
//  MHBundleHelper.m
//  Masonry
//
//  Created by Minghao Xue on 2019/1/22.
//

#import "MHBundleHelper.h"

@implementation MHBundleHelper

+ (NSURL *)bundleURL {
    NSBundle * mainBundle = [NSBundle bundleForClass:[self class]];
    return [mainBundle URLForResource:@"MHWebBrowser" withExtension:@"bundle"];
}

+ (NSBundle *)resourceBundle {
    return [NSBundle bundleWithURL:[self bundleURL]];
}

+ (UIImage *)imageNamed:(NSString *)imageName {
    return [[UIImage imageNamed:imageName inBundle:[self resourceBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end
