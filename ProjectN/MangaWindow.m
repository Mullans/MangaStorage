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
        filtered = YES;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@(NO)];
        chapters = [[myManga.chapters allObjects] filteredArrayUsingPredicate:predicate];
    }else{
        filtered = NO;
        chapters = [myManga.chapters allObjects];
    }
    chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
    [_tableView reloadData];
}

- (IBAction)stepperClicked:(id)sender {
    myManga.rating = @(_stepperValue.integerValue);
    [_rating setStringValue:[NSString stringWithFormat:@"Rating: %li/10",(long)[myManga.rating integerValue]]];

}

- (IBAction)infoUpdated:(id)sender {
    NSLog(@"%@",[sender stringValue]);
    if(sender==_author){
        myManga.author = _author.stringValue;
    }else if(sender==_artist){
        myManga.artist = _artist.stringValue;
    }else if(sender==_numChapters){
        if([_numChapters integerValue]<1){
            _numChapters.stringValue = [myManga.chapterTotal stringValue];
            return;
        }
        myManga.chapterTotal = @([_numChapters integerValue]);
    }else if(sender==_host){
        myManga.host = _host.stringValue;
    }
//    [sender sizeToFit];
    
    //status as button
}



- (IBAction)statusChange:(id)sender {
    if ([_status.title isEqual:@"Ongoing"]){
        _status.title = @"Completed";
        myManga.status = [NSNumber numberWithBool:YES];
    }else{
        _status.title = @"Ongoing";
        myManga.status = [NSNumber numberWithBool:NO];
    }
    [_status sizeToFit];
}

- (IBAction)getUpdates:(id)sender {
    [myManga updateChapters:context];
    
    if(filtered){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@",@(NO)];
        chapters = [[myManga.chapters allObjects] filteredArrayUsingPredicate:predicate];
    }else{
        chapters = [myManga.chapters allObjects];
    }
    chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
    
    [[sender window] makeFirstResponder:nil];
    
    [_tableView reloadData];
}

- (IBAction)markButtonPressed:(id)sender {
    if([_markButton.title isEqual:@"Mark Selected Read"]){
        NSIndexSet *indexSet = [_tableView selectedRowIndexes];
        NSMutableArray *toRemove = [[NSMutableArray alloc]initWithCapacity:10];
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            //use index
            [[chapters objectAtIndex:index]switchRead];
        }];
        _markButton.title = @"Mark All Read";
    }else{
        for(Chapter* item in chapters){
            [item switchRead];
        }
    }
    [_numToRead setStringValue:[@"Unread Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%li",[myManga.unreadChapters integerValue]]]];
    [_numToRead sizeToFit];
    chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
    [_tableView reloadData];
}

-(id)initWithManga:(MangaEntity*)newManga parent:(id)parent context:(NSManagedObjectContext*)newContext{
    self = [super initWithWindowNibName:@"MangaWindow"];
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    self.window.delegate = self;
    [self.window makeFirstResponder:nil];
    
    context = newContext;
    _genreTable.dataSource = self;
    _genreTable.delegate = self;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.window.delegate = parent;
    myManga = newManga;
    
    NSSortDescriptor *genreSort = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES];
    genres = [[NSMutableArray alloc]initWithArray:[[newManga.genres allObjects] sortedArrayUsingDescriptors:@[genreSort]]];

    
    [self.window setTitle:newManga.title];
    
    [_coverImage setImage:[[NSImage alloc]initWithData:newManga.coverArt]];
    
    [_rating setStringValue:[NSString stringWithFormat:@"Rating: %li/10",(long)[newManga.rating integerValue]]];

    [_author setStringValue:newManga.author];
//    if([newManga.author length]>40){
//        [_author setStringValue:[newManga.author substringToIndex:41]];
//    }
//    [_author sizeToFit];
    
    
    [_artist setStringValue:newManga.artist];
//    if([newManga.artist length]>40){
//        [_artist setStringValue:[newManga.artist substringToIndex:41]];
//    }
//    [_artist sizeToFit];
    
    [_numToRead setStringValue:[NSString stringWithFormat:@"%li",[newManga.unreadChapters integerValue]]];
//    [_numToRead sizeToFit];
    if ([newManga.status  isEqual: @(NO)]){
        [_status setTitle:@"Ongoing"];
    }else{
        [_status setTitle:@"Completed"];
    }
    [_status sizeToFit];
    
    [_host setStringValue:newManga.host];
//    [_host sizeToFit];
    
    [_numChapters setStringValue:[NSString stringWithFormat:@"%li",[newManga.chapterTotal integerValue]]];
//    [_numChapters sizeToFit];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"index"
                                                 ascending:YES];
    sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    chapters = [[newManga.chapters allObjects] sortedArrayUsingDescriptors:sortDescriptors];
    
    [_tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:[_tableView tableColumnWithIdentifier:@"Index"]];
    
    sorters = [[NSMutableArray alloc]initWithArray:@[@2,@0,@0,@0]];
    
    [_tableView setDoubleAction:@selector(rowDoubleClicked)];
    
    NSFetchRequest *preferencesRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *preferenceDescriptor = [NSEntityDescription entityForName:@"PreferenceEntity" inManagedObjectContext:context];
    [preferencesRequest setEntity:preferenceDescriptor];
    NSError *prefError = nil;
    NSArray *fetchedPreference =[context executeFetchRequest:preferencesRequest error:&prefError];
    if([fetchedPreference count]==0){
        //genereate
        preference = (PreferenceEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"PreferenceEntity" inManagedObjectContext:context];
    }else if([fetchedPreference count]==1){
        preference = [fetchedPreference objectAtIndex:0];
    }else{
        NSLog(@"TOO MANY PREFERENCE OBJECTS");
    }
    
    [_tableView reloadData];
    
    return self;
}

#pragma mark Genre Table Methods

- (IBAction)addGenre:(id)sender {
    //dialogue to add genre?
    [genres insertObject:@"---" atIndex:0];
    [_genreTable reloadData];
    [_genreTable editColumn:0 row:0 withEvent:nil select:YES];
    
}

- (IBAction)removeGenre:(id)sender {
    if([_genreTable selectedRow]!=-1){
        Genre* genre = [genres objectAtIndex:[_genreTable selectedRow]];
        genre.count = @([genre.count integerValue]-1);
        if ([genre.count integerValue]<1){
            [preference removeTotalGenresObject:genre];
            if([preference.onlyIf containsObject:genre]){
                [preference removeOnlyIfObject:genre];
            }
            if([preference.onlyIfNot containsObject:genre]){
                [preference removeOnlyIfNotObject:genre];
            }
        }
        [myManga removeGenresObject:[genres objectAtIndex:[_genreTable selectedRow]]];
        [genres removeObjectAtIndex:[_genreTable selectedRow]];
        
        [_genreTable reloadData];
    }
    
}

-(void)genreUpdate:(id)sender{
    Genre *newGenre = (Genre*)[NSEntityDescription insertNewObjectForEntityForName:@"Genre" inManagedObjectContext:context];
    newGenre.title = [sender stringValue];
    [myManga addGenresObject:newGenre];
    [genres addObject:newGenre];
    
    NSMutableArray *genreStrings = [[NSMutableArray alloc]initWithCapacity:10];
    for(Genre* genre in preference.totalGenres){
        [genreStrings addObject:genre.title];
    }
    if(![genreStrings containsObject:newGenre]){
        newGenre.count=@1;
        [preference addTotalGenresObject:newGenre];
    }else{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = '%@'",newGenre.title];
        Genre* oldGenre = [[[preference.totalGenres allObjects] filteredArrayUsingPredicate:predicate] objectAtIndex:0];
        oldGenre.count = @([oldGenre.count integerValue]+1);
    }
    
    [[sender window]makeFirstResponder:nil];
    [genres removeObjectAtIndex:0];
    
    NSSortDescriptor *genreSort = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES];
    genres = [[NSMutableArray alloc]initWithArray:[genres sortedArrayUsingDescriptors:@[genreSort]]];
    
    [_genreTable reloadData];
}

#pragma mark Table Methods


-(void)rowDoubleClicked{
    
    NSUInteger flags = [NSEvent modifierFlags];// & NSDeviceIndependentModifierFlagsMask;
    //    NSUInteger *temp = [_tableView clickedRow];
    if([_tableView clickedRow] == -1){
        return;
    }
    /*
     Code for clicking on only a specific column
     if([_tableView clickedColumn]==[_tableView columnWithIdentifier:@"Status"]){
     
     }
     */
    if( flags == NSShiftKeyMask ){
        NSURL* chapterURL = [[chapters objectAtIndex:[_tableView clickedRow]] getChapterURL];
        [[NSWorkspace sharedWorkspace] openURL: chapterURL];
    } else {
        [[chapters objectAtIndex:[_tableView clickedRow]]switchRead];
        [chapters objectAtIndex:[_tableView clickedRow]];
        [_numToRead setStringValue:[@"Unread Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%li",[myManga.unreadChapters integerValue]]]];
        [_numToRead sizeToFit];
        chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
        [_tableView reloadData];
        
    }
    if([[_tableView selectedRowIndexes]count] == 0){
        _markButton.title = @"Mark All Read";
    }
}


-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(tableView==_tableView){
        return [chapters count];

    }else if(tableView==_genreTable){
        return [genres count];
    }
    return -1;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    if([[_tableView selectedRowIndexes]count] > 0){
        _markButton.title = @"Mark Selected Read";
    }else{
        _markButton.title = @"Mark All Read";
    }
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
    if(tableView==_tableView){
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
        }else if([tableColumn.identifier isEqual:@"Date"]){
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            [dateFormater setDateFormat:@"MM/dd/yyyy"];
            result.textField.stringValue = [dateFormater stringFromDate:chapter.addDate];
        }
    }else if (tableView==_genreTable){
        @try{
            Genre* item = [genres objectAtIndex:row];
            result.textField.stringValue = item.title;
        }
        @catch(NSException* e){
            result.textField.stringValue = @"Genre";
            [result.textField setEditable:YES];
            [result.textField setAction:@selector(genreUpdate:)];
            
        }
    }
    return result;
}



-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    if(tableView==_tableView){
        if([tableColumn.identifier isEqual:@"Index"]){
            if([sorters[0] isEqual:@(0)]){
                sorters[0] = @(2);
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:YES];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
            }else if([sorters[0] isEqual:@(2)]){
                sorters[0] = @(1);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'index'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"index" ascending:NO];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];
                
            }else if([sorters[0] isEqual:@(1)]){
                sorters[0] = @(0);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'index'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                [_tableView setIndicatorImage:nil inTableColumn:tableColumn];
            }
        }else if ([tableColumn.identifier isEqual:@"Title"]){
            if([sorters[1] isEqual:@(0)]){
                sorters[1] = @(2);
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:YES];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
            }else if([sorters[1] isEqual:@(2)]){
                sorters[1] = @(1);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'title'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"title" ascending:NO];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];
                
            }else if([sorters[1] isEqual:@(1)]){
                sorters[1] = @(0);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'title'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                [_tableView setIndicatorImage:nil inTableColumn:tableColumn];
                
            }
        }else if([tableColumn.identifier isEqual:@"Status"]){
            if([sorters[2] isEqual:@(0)]){
                sorters[2] = @(2);
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"status" ascending:YES];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
                
                
            }else if([sorters[2] isEqual:@(2)]){
                sorters[2] = @(1);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'status'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"status" ascending:NO];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];

            }else if([sorters[2] isEqual:@(1)]){
                sorters[2] = @(0);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'status'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                [_tableView setIndicatorImage:nil inTableColumn:tableColumn];
            }
        }else if ([tableColumn.identifier isEqual:@"Date"]){
            if([sorters[3] isEqual:@(0)]){
                sorters[3] = @(2);
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"addDate" ascending:YES];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
            }else if([sorters[3] isEqual:@(2)]){
                sorters[3] = @(1);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'addDate'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"addDate" ascending:NO];
                [sortDescriptors insertObject:sortDescriptor atIndex:0];
                [_tableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];
                
            }else if([sorters[3] isEqual:@(1)]){
                sorters[3] = @(0);
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == 'addDate'"];
                [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
                [_tableView setIndicatorImage:nil inTableColumn:tableColumn];
                
            }
        }
        chapters = [chapters sortedArrayUsingDescriptors:sortDescriptors];
        [_tableView reloadData];
        
        

    }
    else if (tableView==_genreTable){
        //sort _genreTable?
    }
}
@end
