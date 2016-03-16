//
//  Created by jet_basrawi on 07/12/2011.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSDate+Utils.h"


@implementation NSDate (Utils)


- (NSArray *)getContinuousArrayOfDatesUntil:(NSDate *)date {

    NSMutableArray *arrayToReturn = [[NSMutableArray alloc] init];

    while ([self compare:date] == NSOrderedAscending || [self compare:date] == NSOrderedSame) {
        [arrayToReturn addObject:date];
        date = [self addDays:1];
    }

    return [[arrayToReturn reverseObjectEnumerator] allObjects];
}

- (NSInteger)numberOfDaysUntil:(NSDate *)date {

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:self toDate:date options:0];
    return [components day];

}

- (NSDate *)addDays:(NSInteger)numDaysToAdd {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:numDaysToAdd];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:self options:0];
    return nextDate;
}


- (NSDate *)getDateWithZeroTime {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDate *dateToReturn = [calendar dateFromComponents:components];

    return dateToReturn;
}

- (NSString *)getDateKey {
    // NSLog(@"Getting date key for date");

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self];
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];

    NSString *dateKey = [NSString stringWithFormat:@"%d-%02d-%02d", year, month, day];

    //NSLog(@"Returning %@", dateKey);

    return dateKey;
}


- (NSString *)formattedDateString {
    NSString *formatString = [NSDateFormatter dateFormatFromTemplate:@"yyyyMMMdEEE" options:0 locale:[NSLocale currentLocale]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatString];

    return [dateFormatter stringFromDate:self];
}


@end