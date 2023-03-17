//
//  WatchdogUser.m
//  Watchdog 3
//
//  Created by Kendall Toerner on 4/25/16.
//  Copyright © 2016 Elovation Design. All rights reserved.
//

#import "WatchdogUser.h"

@class NSData,NSArray<ObjectType>;

@implementation WatchdogUser

NSString *watchdog_username = @"";
NSString *watchdog_facebookid = @"";
UIImage *watchdog_propic;

-(bool) setUsername:(NSString *)user_username
{
    if ([user_username isEqualToString:@""]) return false;
    
    watchdog_username = user_username;
    
    return true;
}

-(NSString *)getUsername
{
    return watchdog_username;
}

-(bool)setFacebookID:(NSString *)user_facebookid
{
    if ([user_facebookid isEqualToString:@""]) return false;
    
    watchdog_facebookid = user_facebookid;
    
    return true;
}

-(NSString *)getFacebookID
{
    return watchdog_facebookid;
}

-(bool)setPropic:(UIImage *)user_propic
{
    watchdog_propic = user_propic;
    
    return true;
}

-(UIImage *)getPropic
{
    return watchdog_propic;
}

@end
