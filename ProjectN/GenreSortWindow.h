//
//  GenreSortWindow.h
//  MangaStorage
//
//  Created by Sean Mullan on 3/28/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferenceEntity.h"
#import "Genre.h"

@protocol GenreSortWindowDelegate <NSObject>

-(void)deleteExcludeGenre:(Genre* )genre;
-(void)deleteIncludeGenre:(Genre*)genre;

@end

@interface GenreSortWindow : NSWindowController<NSTableViewDataSource,NSTableViewDelegate>{
    NSMutableArray* genres;
    NSMutableArray* included;
    NSMutableArray* excluded;
    PreferenceEntity *myPref;
    NSManagedObjectContext *myContext;
}

@property (nonatomic, weak)id<GenreSortWindowDelegate> delegate;

@property (weak) IBOutlet NSTableView *genresTable;
@property (weak) IBOutlet NSTableView *includeTable;
@property (weak) IBOutlet NSTableView *excludeTable;
- (IBAction)addExclude:(id)sender;
- (IBAction)removeExclude:(id)sender;

- (IBAction)removeInclude:(id)sender;
- (IBAction)addInclude:(id)sender;

-(id)initWithParent:(id)parent context:(NSManagedObjectContext*)context;

@end
