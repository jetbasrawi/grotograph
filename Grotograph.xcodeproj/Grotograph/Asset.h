//
//  Photo.h
//  Grotograph
//
//  Created by Jet Basrawi on 14/01/2012.
//  Copyright (c) 2012 Free for all products Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AssetGroup, AssetTransformation, Comment, Session;

@interface Asset : NSManagedObject

@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSDate * dateImported;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) Session *session;
@property (nonatomic, retain) AssetTransformation *transformation;
@property (nonatomic, retain) Comment *comments;
@property (nonatomic, retain) AssetGroup *assetGroups;

@end
