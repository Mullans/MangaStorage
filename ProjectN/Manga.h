//
//  Manga.h
//  ProjectN
//
//  Created by Sean Mullan on 3/7/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

//TODO: parse chapters, most recent chapter, chapter total, and categories (summary?)

@interface Manga : NSObject{
    NSString *author; //
    NSString *title; //
    NSString *artist;
    NSString *host;
    NSInteger chapterTotal;
    NSMutableArray *chapterList;
    NSImage* coverArt; //
    BOOL finished;
    NSURL *mangaHomePage;
    NSInteger chaptersToRead;
}

-(id)initWithURL:(NSURL*)mangaURL;
-(NSString*)getAuthor;
-(NSString*)getArtist;
-(NSString*)getTitle;
-(NSString*)getHost;
-(BOOL)getStatus;
-(NSArray*)getChapterList;
-(NSArray*)getChapter:(int)index;
-(NSInteger)getNumChapters;
-(NSInteger)getNumberToRead;
-(void)switchRead:(int)index;
-(NSURL*)getChapterURL:(int)index;
-(void)updateChapters;
-(NSImage*)getCover;
-(void)print;
@end
