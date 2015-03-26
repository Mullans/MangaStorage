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

@protocol MangaWindowDelegate;

@interface MangaWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>{
    MangaEntity* myManga;
    NSArray* chapters;
    NSManagedObjectContext* context;
    NSMutableArray *sorters;
    NSMutableArray *sortDescriptors;
    bool filtered;
}
@property (weak) IBOutlet NSTextField *author;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *numChapters;
@property (weak) IBOutlet NSTextField *host;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *coverImage;
@property (weak) IBOutlet NSButton *markButton;
@property (weak) IBOutlet NSTextField *numToRead;
- (IBAction)unreadExcluder:(id)sender;

- (IBAction)getUpdates:(id)sender;
- (IBAction)markButtonPressed:(id)sender;
-(id)initWithManga:(MangaEntity*)newManga parent:(id)parent context:(NSManagedObjectContext*)newContext;
-(void)rowDoubleClicked;
@end

@protocol MangaWindowDelegate <NSObject>

-(void)closingWindow;

@end
