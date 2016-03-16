//
//  SessionHelper.m
//  Grotograph
//
//  Created by Jet Basrawi on 22/10/2011.
//  Copyright (c) 2011 Free for all products Ltd. All rights reserved.
//

#import "SessionHelper.h"
#import "NSArray-Set.h"
#import "Asset.h"
#import "NSDate+Utils.h"

@implementation SessionHelper

-(NSDictionary *)getSessionsForDates:(NSArray *) dates from:(Project *)project
{
    NSMutableDictionary *dicToReturn = [[NSMutableDictionary alloc] init];
    
    for (NSDate *date in dates) {
    
        SessionHelper *sessionHelper = [[SessionHelper alloc] init];
        Session *session = [sessionHelper getSessionForDate:date fromProject:project];
        
        if (session) {
            [dicToReturn setObject:session forKey:date];
        }
        else
        {
            [dicToReturn setObject:[NSNull null] forKey:date];
        }
    }
    
    return dicToReturn;
}

-(NSDictionary *)getSessions:(Project *)project startDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    NSArray *arrayOfDates = [startDate getContinuousArrayOfDatesUntil:endDate];
    return [self getSessionsForDates:arrayOfDates from:project];
}

-(NSString *) getPosterImageUrl:(Session *)session
{
    NSString *urlStringToReturn = nil;
    
    if (session.keyFrame != nil) {
        urlStringToReturn = session.keyFrame.url;
    }
    else
    {
        NSArray *photos = [NSArray arrayByOrderingSet:session.assets byKey:@"dateCreated" ascending:YES];
        if (photos.count > 0) {
            urlStringToReturn = (NSString *)[[photos objectAtIndex:0] url];
        }
    }
    
    return urlStringToReturn;
}

-(Session *)getOrCreateSessionForDate:(NSDate *)date fromProject:(Project *)project
{
    Session * session = [self getSessionForDate:date fromProject:project];
    if(!session)
        session = [self createSessionInProject:project withDate:date];
    return session;
}

- (Session *) getSessionForDate:(NSDate *)date fromProject:(Project *)project
{
    Session *sessionToReturn = nil;
    
    //TODO: Look into this
    //This will cause a bug if the user starts before midnght and goes over to next day
    //another session will be returned    
    NSString *dateKey = [date getDateKey];
    //NSLog(@"Getting session with key %@", dateKey);
    
    
    NSArray * sessionsArray = [NSArray
                               arrayByOrderingSet:project.sessions
                               byKey:@"dateKey" 
                               ascending:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateKey == %@", dateKey];
    NSArray *filteredArray = [sessionsArray filteredArrayUsingPredicate:predicate];
    sessionToReturn = [filteredArray lastObject];
    
    return sessionToReturn;
}

-(Session *)createSessionInProject:(Project *)project withDate:(NSDate *)date 
{
    Session *sessionToReturn = nil;

    NSString *dateKey = [date getDateKey];
    NSDate *zeroDate = [date getDateWithZeroTime];
    
    //NSLog(@"Creating session with key %@", dateKey);

    sessionToReturn = [NSEntityDescription 
                       insertNewObjectForEntityForName:@"Session" 
                       inManagedObjectContext:project.managedObjectContext];
      
    [sessionToReturn setDate:zeroDate];
    [sessionToReturn setDateKey:dateKey];
    [project addSessionsObject:sessionToReturn];
     NSError *error = nil;
    [project.managedObjectContext save:&error];

    
    return sessionToReturn;
}


@end
