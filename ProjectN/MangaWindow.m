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
- (IBAction)unreadExcluder:(id)sender {
    if([sender state] == NSOnState){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@(NO)];
        chapters = [[myManga.chapters allObjects] filteredArrayUsingPredicate:predicate];
    }else{
        chapters = [myManga.chapters allObjects];
    }
    chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
    [_tableView reloadData];
}

- (IBAction)getUpdates:(id)sender {
    [myManga updateChapters:context];
    [_tableView reloadData];
}

-(id)initWithManga:(MangaEntity*)newManga parent:(id)parent context:(NSManagedObjectContext*)newContext{
    self = [super initWithWindowNibName:@"MangaWindow"];
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    
    context = newContext;
    
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
    sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    chapters = [[newManga.chapters allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    sorters = [[NSMutableArray alloc]initWithArray:@[@2,@0,@0]];
    
    [_tableView setDoubleAction:@selector(rowDoubleClicked)];
    
    [_tableView reloadData];
    
    return self;
}

-(void)rowDoubleClicked{
    
    NSUInteger flags = [NSEvent modifierFlags];// & NSDeviceIndependentModifierFlagsMask;
//    NSUInteger *temp = [_tableView clickedRow];
    if([_tableView clickedRow] == -1){
        return;
    }
    if( flags == NSShiftKeyMask ){
        NSURL* chapterURL = [[chapters objectAtIndex:[_tableView clickedRow]] getChapterURL];
        [[NSWorkspace sharedWorkspace] openURL: chapterURL];
    } else {
        [[chapters objectAtIndex:[_tableView clickedRow]]switchRead];
        Chapter* item = [chapters objectAtIndex:[_tableView clickedRow]];
        [_numToRead setStringValue:[@"Unread Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%li",[myManga.unreadChapters integerValue]]]];
        [_numToRead sizeToFit];
        chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
        [_tableView reloadData];
        NSLog(@"\nTitle:%@\nIndex:%@",item.title,item.index);

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
    if([tableColumn.identifier isEqual:@"Index"]){
        result.textField.stringValue = [NSString stringWithFormat:@"%@",chapter.index];
    }else if ([tableColumn.identifier isEqual:@"Title"]){
        result.textField.stringValue = chapter.title;
    }else if([tableColumn.identifier isEqual:@"Status"]){
        if ([chapter.status isEqual:@(NO)]){
            result.textField.stringValue = @"Unread";
        }else{
            result.textField.stringValue = @"Read";
        }
    }
    return result;
}

-(void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn{

    if([tableColumn.identifier isEqual:@"Index"]){
        if([sorters[0] isEqual:@(0)]){
            sorters[0] = @(2);
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:YES];
            [sortDescriptors insertObject:sortDescriptor atIndex:0];
        }else if([sorters[0] isEqual:@(2)]){
            sorters[0] = @(1);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'index'"];
            [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:NO];
            [sortDescriptors insertObject:sortDescriptor atIndex:0];
            
        }else if([sorters[0] isEqual:@(1)]){
            sorters[0] = @(0);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'index'"];
            [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
            
        }
    }else if ([tableColumn.identifier isEqual:@"Title"]){
        if([sorters[1] isEqual:@(0)]){
            sorters[1] = @(2);
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES];
            [sortDescriptors insertObject:sortDescriptor atIndex:0];
        }else if([sorters[1] isEqual:@(2)]){
            sorters[1] = @(1);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'title'"];
            [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:NO];
            [sortDescriptors insertObject:sortDescriptor atIndex:0];
            
        }else if([sorters[0] isEqual:@(1)]){
            sorters[1] = @(0);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'title'"];
            [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
            
        }
    }else if([tableColumn.identifier isEqual:@"Status"]){
        if([sorters[2] isEqual:@(0)]){
            sorters[2] = @(2);
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"status" ascending:YES];
            [sortDescriptors insertObject:sortDescriptor atIndex:0];
            
            
        }else if([sorters[2] isEqual:@(2)]){
            sorters[2] = @(1);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'status'"];
            [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"status" ascending:NO];
            [sortDescriptors insertObject:sortDescriptor atIndex:0];
        }else if([sorters[2] isEqual:@(1)]){
            sorters[2] = @(0);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'status'"];
            [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
        }
    }
    
    chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
    [_tableView reloadData];
}
@end
