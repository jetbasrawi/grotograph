//
//  Created by jet_basrawi on 10/01/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Project.h"

@interface Project (Queries)

- (Session *)getMostRecentSession;

- (Session *)getOrCreateSessionForDate:(NSDate *)date;

- (Session *)sessionForDate:(NSDate *)date;

- (Session *)createSessionWithDate:(NSDate *)date;


@end