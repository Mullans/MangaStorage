//
//  Chapter.h
//  MangaStorage
//
//  Created by Sean Mullan on 3/24/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MangaEntity;

@interface Chapter : NSManagedObject

@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * chapterURL;
@property (nonatomic, retain) MangaEntity *manga;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSDate * addDate;

-(void)switchRead;
-(NSURL*)getChapterURL;
@end
