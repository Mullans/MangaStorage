//
//  PreferenceEntity.h
//  MangaStorage
//
//  Created by Sean Mullan on 3/27/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Genre;

@interface PreferenceEntity : NSManagedObject

@property (nonatomic, retain) NSNumber * totalCount;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSSet *totalGenres;
@end

@interface PreferenceEntity (CoreDataGeneratedAccessors)

- (void)addTotalGenresObject:(Genre *)value;
- (void)removeTotalGenresObject:(Genre *)value;
- (void)addTotalGenres:(NSSet *)values;
- (void)removeTotalGenres:(NSSet *)values;

@end
