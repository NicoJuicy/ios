//
//  NavigationController.h
//  OwnTracks
//
//  Created by Christoph Krey on 29.06.15.
//  Copyright © 2015-2026  OwnTracks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationController : UINavigationController
+ (NavigationController *)sharedInstance;
+ (void)alert:(NSString *)title message:(NSString *)message;
+ (void)alert:(NSString *)title message:(NSString *)message url:(NSString *)url;
+ (void)alert:(NSString *)title message:(NSString *)message dismissAfter:(NSTimeInterval)interval;

@end
