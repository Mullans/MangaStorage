//
//  MangaWindow.m
//  ProjectN
//
//  Created by Sean Mullan on 3/20/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import "MangaWindow.h"

@interface MangaWindow ()

@end

@implementation MangaWindow

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(id)initWithManga:(Manga*)newManga{
    self = [super initWithWindowNibName:@"MangaWindow"];
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    myManga = newManga;
    
    [self.window setTitle:[newManga getTitle]];
    
    [_coverImage setImage:[newManga getCover]];
    
    [_author setStringValue:[@"Author: " stringByAppendingString:[newManga getAuthor]]];
    [_author sizeToFit];
    
    [_artist setStringValue:[@"Artist: " stringByAppendingString:[newManga getArtist]]];
    [_artist sizeToFit];
    
    if ([newManga getAuthor]){
        [_status setStringValue:@"Status: Ongoing"];
        [_status sizeToFit];
    }else{
        [_status setStringValue:@"Status: Completed"];
        [_status sizeToFit];
    }
    
    [_host setStringValue:[@"Host: " stringByAppendingString:[newManga getHost]]];
    [_host sizeToFit];
    
    [_numChapters setStringValue:[@"Number Of Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%i",(int)[newManga getNumChapters]]]];
    [_numChapters sizeToFit];
    
    [_tableView setDoubleAction:@selector(rowDoubleClicked)];
    
    [_tableView reloadData];
    
    return self;
}

-(void)rowDoubleClicked{
    
    [myManga switchRead:[_tableView clickedRow]];
    [_tableView reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [myManga getNumChapters];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSTableCellView *result = [tableView makeViewWithIdentifier:@"tableView" owner:self];
    
    if (result==nil){
        result = [[NSTableCellView alloc]initWithFrame:NSMakeRect(0,0,tableView.bounds.size.width,[tableView rowHeight])];
    }
    NSTextField *cellTF = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, result.bounds.size.height)];
    [result addSubview:cellTF];
    result.textField = cellTF;
    [cellTF setBordered:NO];
    [cellTF setEditable:NO];
    [cellTF setDrawsBackground:NO];
    [result addSubview:cellTF];
    result.textField = cellTF;
    [cellTF setBordered:NO];
    [cellTF setEditable:NO];
    [cellTF setDrawsBackground:NO];
    NSArray *chapter = [myManga getChapter:row];
    if ([tableColumn.identifier isEqual:@"Title"]){
        result.textField.stringValue = chapter[0];
    }else{
        if ([chapter[1] integerValue]==0){
            result.textField.stringValue = @"Unread";
        }else{
            result.textField.stringValue = @"Read";
        }
    }
    return result;
}

@end
