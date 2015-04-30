//
//  PreferenceEntity.h
//  MangaStorage
//
//  Created by Sean Mullan on 4/29/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Genre;

@interface PreferenceEntity : NSManagedObject

@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSNumber * totalCount;
@property (nonatomic, retain) NSSet *onlyIf;
@property (nonatomic, retain) NSSet *onlyIfNot;
@property (nonatomic, retain) NSSet *totalGenres;
@end

@interface PreferenceEntity (CoreDataGeneratedAccessors)

- (void)addOnlyIfObject:(Genre *)value;
- (void)removeOnlyIfObject:(Genre *)value;
- (void)addOnlyIf:(NSSet *)values;
- (void)removeOnlyIf:(NSSet *)values;

- (void)addOnlyIfNotObject:(Genre *)value;
- (void)removeOnlyIfNotObject:(Genre *)value;
- (void)addOnlyIfNot:(NSSet *)values;
- (void)removeOnlyIfNot:(NSSet *)values;

- (void)addTotalGenresObject:(Genre *)value;
- (void)removeTotalGenresObject:(Genre *)value;
- (void)addTotalGenres:(NSSet *)values;
- (void)removeTotalGenres:(NSSet *)values;

@end
