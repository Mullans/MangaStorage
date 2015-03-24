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
- (IBAction)getUpdates:(id)sender {
    [myManga updateChapters];
    [_tableView reloadData];
}

-(id)initWithManga:(MangaEntity*)newManga parent:(id)parent{
    self = [super initWithWindowNibName:@"MangaWindow"];
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.window.delegate = parent;
    myManga = newManga;
    
    [self.window setTitle:newManga.title];
    
    [_coverImage setImage:[[NSImage alloc]initWithData:newManga.coverArt]];
    
    [_author setStringValue:[@"Author: " stringByAppendingString:newManga.author]];
    [_author sizeToFit];
    
    [_artist setStringValue:[@"Artist: " stringByAppendingString:newManga.artist]];
    [_artist sizeToFit];
    
    [_numToRead setStringValue:[@"Unread Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%li",[newManga.unreadChapters integerValue]]]];
    [_numToRead sizeToFit];
    
    if (newManga.status == [NSNumber numberWithBool:NO]){
        [_status setStringValue:@"Status: Ongoing"];
        [_status sizeToFit];
    }else{
        [_status setStringValue:@"Status: Completed"];
        [_status sizeToFit];
    }
    
    [_host setStringValue:[@"Host: " stringByAppendingString:newManga.host]];
    [_host sizeToFit];
    
    [_numChapters setStringValue:[@"Number Of Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%li",[newManga.chapterTotal integerValue]]]];
    [_numChapters sizeToFit];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    chapters = [[newManga.chapters allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    [_tableView setDoubleAction:@selector(rowDoubleClicked)];
    
    [_tableView reloadData];
    
    return self;
}

-(void)rowDoubleClicked{
    
    NSUInteger flags = [NSEvent modifierFlags];// & NSDeviceIndependentModifierFlagsMask;
    if( flags == NSShiftKeyMask ){
        NSURL* chapterURL = [[chapters objectAtIndex:[_tableView clickedRow]] getChapterURL];
        [[NSWorkspace sharedWorkspace] openURL: chapterURL];
    } else {
        [[chapters objectAtIndex:[_tableView clickedRow]]switchRead];
        Chapter* item = [chapters objectAtIndex:[_tableView clickedRow]];
        NSLog(@"%@",item.status);
        [_numToRead setStringValue:[@"Unread Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%li",[myManga.unreadChapters integerValue]]]];
        [_numToRead sizeToFit];
        [_tableView reloadData];
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [chapters count];
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
    Chapter *chapter = [chapters objectAtIndex:row];
    if ([tableColumn.identifier isEqual:@"Title"]){
        result.textField.stringValue = chapter.title;
    }else{
        NSLog(@"%@",chapter.status);
        if ([chapter.status isEqual:@(NO)]){
            result.textField.stringValue = @"Unread";
        }else{
            result.textField.stringValue = @"Read";
        }
    }
    return result;
}

@end
