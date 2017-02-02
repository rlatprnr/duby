//
//  NSObject+UIAppearance_Swift_h.m
//  Duby
//
//  Created by Aziz on 9/18/15.
//  Copyright (c) 2016 Duby, LLC. All rights reserved.
//

#import "UIAppearance+Swift.h"

@implementation UIView (UIViewAppearance_Swift)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
  return [self appearanceWhenContainedIn:containerClass, nil];
}
@end