//
//  Chapter.m
//  MangaStorage
//
//  Created by Sean Mullan on 3/24/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import "Chapter.h"
#import "MangaEntity.h"


@implementation Chapter

@dynamic index;
@dynamic title;
@dynamic chapterURL;
@dynamic manga;
@dynamic status;
@dynamic addDate;

-(void)switchRead{
    if([self.status  isEqual: @(YES)]){
        self.status = @(NO);
        self.manga.unreadChapters = @([self.manga.unreadChapters integerValue]+1);
    }else{
        self.status = @(YES);
        self.manga.unreadChapters = @([self.manga.unreadChapters integerValue]-1);
    }
}
-(NSURL *)getChapterURL{
    return [[NSURL alloc]initWithString:self.chapterURL];
}

@end
