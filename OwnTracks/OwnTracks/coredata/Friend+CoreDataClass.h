//
//  Friend+CoreDataClass.h
//  OwnTracks
//
//  Created by Christoph Krey on 08.12.16.
//  Copyright © 2016-2025  OwnTracks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>

@class Location, Region, Subscription, Waypoint;

NS_ASSUME_NONNULL_BEGIN

@interface Friend : NSManagedObject <MKAnnotation, MKOverlay>

@property (nonatomic) CLLocationCoordinate2D coordinate;

+ (Friend *)existsFriendWithTopic:(NSString *)topic
           inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Friend *)friendWithTopic:(NSString *)topic
     inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSString *)nameOfPerson:(NSString *)contactId;
+ (NSData *)imageDataOfPerson:(NSString *)contactId;

+ (void)deleteAllFriendsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allFriendsInManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)allNonStaleFriendsInManagedObjectContext:(NSManagedObjectContext *)context;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString * _Nonnull name;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString * _Nonnull nameOrTopic;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSData * _Nonnull image;

+ (NSString *)effectiveTid:(NSString *)tid device:(NSString *)device;
@property (NS_NONATOMIC_IOSONLY, getter=getEffectiveTid, readonly, copy) NSString * _Nonnull effectiveTid;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) Waypoint * _Nonnull newestWaypoint;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) MKPolyline * _Nonnull polyLine;

@end

NS_ASSUME_NONNULL_END

#import "Friend+CoreDataProperties.h"
