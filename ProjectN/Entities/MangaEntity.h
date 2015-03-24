//
//  MangaEntity.h
//  MangaStorage
//
//  Created by Sean Mullan on 3/24/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Cocoa/Cocoa.h>
#import "Chapter.h"


@interface MangaEntity : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * host;
@property (nonatomic, retain) NSNumber * chapterTotal;
@property (nonatomic, retain) NSData * coverArt;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSString * mangaURL;
@property (nonatomic, retain) NSNumber * unreadChapters;
@property (nonatomic, retain) NSSet *chapters;
@end

@interface MangaEntity (CoreDataGeneratedAccessors)

- (void)addChaptersObject:(NSManagedObject *)value;
- (void)removeChaptersObject:(NSManagedObject *)value;
- (void)addChapters:(NSSet *)values;
- (void)removeChapters:(NSSet *)values;


-(void)generateData:(NSURL*)mangaURL context:(NSManagedObjectContext*)context;
-(void)updateChapters;

@end
