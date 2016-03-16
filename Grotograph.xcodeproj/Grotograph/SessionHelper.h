//
//  SessionHelper.h
//  Grotograph
//
//  Created by Jet Basrawi on 22/10/2011.
//  Copyright (c) 2011 Free for all products Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"
#import "Project.h"

@interface SessionHelper : NSObject

-(NSDictionary *)getSessionsForDates:(NSArray *) dates from:(Project *)project;
-(NSDictionary *) getSessions:(Project *)project startDate:(NSDate *)startDate endDate:(NSDate *)endDate;
-(NSString *) getPosterImageUrl:(Session *)session;
-(Session *) getOrCreateSessionForDate:(NSDate *)date fromProject:(Project *)project;
-(Session *) getSessionForDate:(NSDate *)date fromProject:(Project *)project; 
-(Session *) createSessionInProject:(Project *)project withDate:(NSDate *)date;

@end
