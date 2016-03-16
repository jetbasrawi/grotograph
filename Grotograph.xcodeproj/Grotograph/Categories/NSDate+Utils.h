//
//  Created by jet_basrawi on 07/12/2011.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface NSDate (Utils)

- (NSArray *)getContinuousArrayOfDatesUntil:(NSDate *)date;

- (NSInteger)numberOfDaysUntil:(NSDate *)date;

- (NSDate *)addDays:(NSInteger)numDaysToAdd;

- (NSDate *)getDateWithZeroTime;

- (NSString *)getDateKey;

- (NSString *)formattedDateString;

@end