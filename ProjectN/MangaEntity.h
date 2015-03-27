//
//  MangaEntity.h
//  MangaStorage
//
//  Created by Sean Mullan on 3/27/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Cocoa/Cocoa.h>


@class Chapter, Genre;

@interface MangaEntity : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSNumber * chapterTotal;
@property (nonatomic, retain) NSData * coverArt;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSString * mangaURL;
@property (nonatomic, retain) NSNumber * missingChapters;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unreadChapters;
@property (nonatomic, retain) NSSet *chapters;
@property (nonatomic, retain) NSSet *genres;
@end

@interface MangaEntity (CoreDataGeneratedAccessors)

- (void)addChaptersObject:(Chapter *)value;
- (void)removeChaptersObject:(Chapter *)value;
- (void)addChapters:(NSSet *)values;
- (void)removeChapters:(NSSet *)values;

- (void)addGenresObject:(Genre *)value;
- (void)removeGenresObject:(Genre *)value;
- (void)addGenres:(NSSet *)values;
- (void)removeGenres:(NSSet *)values;

-(void)generateData:(NSURL *)mangaURL context:(NSManagedObjectContext *)context;
-(void)updateChapters:(NSManagedObjectContext*)context;

@end
