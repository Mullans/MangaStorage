//
//  MangaWindow.h
//  ProjectN
//
//  Created by Sean Mullan on 3/20/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Manga.h"
#import "MangaEntity.h"
#import "Chapter.h"
#import "Genre.h"
#import "PreferenceEntity.h"

@protocol MangaWindowDelegate;

@interface MangaWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>{
    MangaEntity* myManga;
    PreferenceEntity* preference;
    NSArray* chapters;
    NSManagedObjectContext* context;
    NSMutableArray *sorters;
    NSMutableArray *sortDescriptors;
    NSMutableArray *genres;
    bool filtered;
}
@property (weak) IBOutlet NSTextField *author;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSTextField *numChapters;
@property (weak) IBOutlet NSTextField *host;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *coverImage;
@property (weak) IBOutlet NSButton *markButton;
@property (weak) IBOutlet NSTextField *numToRead;
@property (weak) IBOutlet NSTextField *rating;
@property (weak) IBOutlet NSStepper *stepperValue;
@property (weak) IBOutlet NSButton *status;
@property (weak) IBOutlet NSTableView *genreTable;
- (IBAction)unreadExcluder:(id)sender;
- (IBAction)stepperClicked:(id)sender;
- (IBAction)infoUpdated:(id)sender;
- (IBAction)addGenre:(id)sender;
- (IBAction)removeGenre:(id)sender;

- (IBAction)statusChange:(id)sender;
- (IBAction)getUpdates:(id)sender;
- (IBAction)markButtonPressed:(id)sender;
-(id)initWithManga:(MangaEntity*)newManga parent:(id)parent context:(NSManagedObjectContext*)newContext;
-(void)rowDoubleClicked;
@end

@protocol MangaWindowDelegate <NSObject>

-(void)closingWindow;

@end
