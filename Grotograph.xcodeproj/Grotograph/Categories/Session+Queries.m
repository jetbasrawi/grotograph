//
//  Created by jet_basrawi on 10/01/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <AssetsLibrary/AssetsLibrary.h>
#import "Session+Queries.h"
#import "NSArray-Set.h"
#import "Grotograph/Asset.h"


@implementation Session (Queries)

- (Asset *)getMostRecentPhoto {

    //TODO:Optimise this. Pulling out the whole set and taking the last object is not going to scale use a query
    NSArray *photos = [NSArray arrayByOrderingSet:self.assets byKey:@"dateCreated" ascending:YES];
    Asset *photo = [photos lastObject];
    return photo;
}

- (Asset *)photoWithUrl:(NSString *)url {

    Asset *photo = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"SELF.url = %@", url];

    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];

    if (objects) {
        photo = [objects lastObject];
    }

    return photo;
}

@end