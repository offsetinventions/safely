//
//  WatchdogUser.h
//  Watchdog 3
//
//  Created by Kendall Toerner on 4/25/16.
//  Copyright © 2016 Elovation Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NSData,NSArray<ObjectType>;

@interface WatchdogUser : NSObject

-(bool)setUsername:(NSString*)user_username;
-(NSString*)getUsername;

-(bool)setFacebookID:(NSString*)user_facebookid;
-(NSString*)getFacebookID;

-(bool)setPropic:(UIImage*)user_propic;
-(UIImage*)getPropic;

@end
