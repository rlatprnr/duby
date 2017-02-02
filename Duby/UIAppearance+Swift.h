//
//  NSObject+UIAppearance_Swift_h.h
//  Duby
//
//  Created by Aziz on 9/18/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewAppearance_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end