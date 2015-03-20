//
//  MangaWindow.h
//  ProjectN
//
//  Created by Sean Mullan on 3/20/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Manga.h"

@protocol MangaWindowDelegate;

@interface MangaWindow : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>{
    Manga* myManga;
}
@property (weak) IBOutlet NSTextField *author;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *numChapters;
@property (weak) IBOutlet NSTextField *host;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSImageView *coverImage;
@property (weak) IBOutlet NSTextField *numToRead;

- (IBAction)getUpdates:(id)sender;
-(id)initWithManga:(Manga*)newManga parent:(id)parent;
-(void)rowDoubleClicked;
@end

@protocol MangaWindowDelegate <NSObject>

-(void)closingWindow;

@end
