//
//  Created by jet_basrawi on 10/01/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "NSArray-Set.h"
#import "Project+Queries.h"
#import "NSDate+Utils.h"
#import "Session.h"


@implementation Project (Queries)

- (Session *)getMostRecentSession {

    //TODO:Optimise this. Pulling out the whole set and taking the last object is not going to scale use a query

     NSArray * sessions = [NSArray arrayByOrderingSet:self.sessions byKey:@"date" ascending:YES];
    Session *session = [sessions lastObject];
    return session;
}

- (Session *) getOrCreateSessionForDate:(NSDate *)date {
    Session *session = [self sessionForDate:date];
    if (!session)
        session = [self createSessionWithDate:date];
    return session;
}

- (Session *) sessionForDate:(NSDate *)date {
    
    Session *sessionToReturn = nil;
        
        //TODO: Look into this
        //This will cause a bug if the user starts before midnght and goes over to next day
        //another session will be returned    
        NSString *dateKey = [date getDateKey];
        //NSLog(@"Getting session with key %@", dateKey);
        
        
        NSArray * sessionsArray = [NSArray
                                   arrayByOrderingSet:self.sessions
                                   byKey:@"dateKey" 
                                   ascending:YES];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateKey == %@", dateKey];
        NSArray *filteredArray = [sessionsArray filteredArrayUsingPredicate:predicate];
        sessionToReturn = [filteredArray lastObject];
        
        return sessionToReturn;
    
}

-(Session *)createSessionWithDate:(NSDate *)date
{
    Session *sessionToReturn = nil;

    NSString *dateKey = [date getDateKey];
    NSDate *zeroDate = [date getDateWithZeroTime];

    //NSLog(@"Creating session with key %@", dateKey);

    sessionToReturn = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Session"
                       inManagedObjectContext:self.managedObjectContext];

    [sessionToReturn setDate:zeroDate];
    [sessionToReturn setDateKey:dateKey];
    [self addSessionsObject:sessionToReturn];
     NSError *error = nil;
    [self.managedObjectContext save:&error];

    return sessionToReturn;
}


@end