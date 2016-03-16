//
//  Created by jet_basrawi on 10/01/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Session.h"

@interface Session (Queries)

- (Asset *)getMostRecentPhoto;

- (Asset *)photoWithUrl:(NSString *)url;

@end