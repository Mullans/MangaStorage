//
//  GenreSortWindow.m
//  MangaStorage
//
//  Created by Sean Mullan on 3/28/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import "GenreSortWindow.h"

@interface GenreSortWindow ()

@end

@implementation GenreSortWindow
- (IBAction)buttonPush:(id)sender {
    NSManagedObjectContext* context = myContext;
    NSFetchRequest *preferencesRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *preferenceDescriptor = [NSEntityDescription entityForName:@"PreferenceEntity" inManagedObjectContext:context];
    [preferencesRequest setEntity:preferenceDescriptor];
    NSError *prefError = nil;
    NSArray *fetchedPreference =[context executeFetchRequest:preferencesRequest error:&prefError];
    if([fetchedPreference count]==0){
        //genereate
        myPref = (PreferenceEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"PreferenceEntity" inManagedObjectContext:context];
    }else if([fetchedPreference count]==1){
        myPref = [fetchedPreference objectAtIndex:0];
    }else{
        NSLog(@"TOO MANY PREFERENCE OBJECTS");
    }
    
    genres = [[NSMutableArray alloc]initWithArray:[myPref.totalGenres allObjects]];
    included = [[NSMutableArray alloc]initWithArray:[myPref.onlyIf allObjects]];
    excluded = [[NSMutableArray alloc]initWithArray:[myPref.onlyIfNot allObjects]];
    for(Genre* item in included){
        if([genres containsObject:item]){
            [genres removeObject:item];
        }
    }
    for(Genre* item in excluded){
        if([genres containsObject:item]){
            [genres removeObject:item];
        }
    }
}

-(id)initWithParent:(id)parent context:(NSManagedObjectContext*)context{
    myContext = context;
    self = [super initWithWindowNibName:@"GenreSortWindow"];
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    self.window.delegate = parent;
    [self.window makeFirstResponder:nil];
    
    NSFetchRequest *preferencesRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *preferenceDescriptor = [NSEntityDescription entityForName:@"PreferenceEntity" inManagedObjectContext:context];
    [preferencesRequest setEntity:preferenceDescriptor];
    NSError *prefError = nil;
    NSArray *fetchedPreference =[context executeFetchRequest:preferencesRequest error:&prefError];
    if([fetchedPreference count]==0){
        //genereate
        myPref = (PreferenceEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"PreferenceEntity" inManagedObjectContext:context];
    }else if([fetchedPreference count]==1){
        myPref = [fetchedPreference objectAtIndex:0];
    }else{
        NSLog(@"TOO MANY PREFERENCE OBJECTS");
    }
    
    genres = [[NSMutableArray alloc]initWithArray:[myPref.totalGenres allObjects]];
    included = [[NSMutableArray alloc]initWithArray:[myPref.onlyIf allObjects]];
    excluded = [[NSMutableArray alloc]initWithArray:[myPref.onlyIfNot allObjects]];
    for(Genre* item in included){
        if([genres containsObject:item]){
            [genres removeObject:item];
        }
    }
    for(Genre* item in excluded){
        if([genres containsObject:item]){
            [genres removeObject:item];
        }
    }
    _genresTable.dataSource = self;
    _genresTable.delegate = self;
    _includeTable.dataSource = self;
    _includeTable.delegate = self;
    _excludeTable.dataSource = self;
    _excludeTable.delegate = self;
    
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)addExclude:(id)sender {
    NSIndexSet *indexSet = [_genresTable selectedRowIndexes];
    NSMutableArray *toRemove = [[NSMutableArray alloc]initWithCapacity:10];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        //use index
        Genre* item = [genres objectAtIndex:index];
        [excluded addObject:item];
        [toRemove addObject:item];
        [myPref addOnlyIfNotObject:item];
    }];
    for(Genre* item in toRemove){
        [genres removeObject:item];
    }
    [_genresTable reloadData];
    [_excludeTable reloadData];
}

- (IBAction)removeExclude:(id)sender {
    NSIndexSet *indexSet = [_excludeTable selectedRowIndexes];
    NSMutableArray *toRemove = [[NSMutableArray alloc]initWithCapacity:10];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        //use index
        [myPref removeOnlyIfObject:[excluded objectAtIndex:index]];
        Genre* item = [excluded objectAtIndex:index];
        [genres addObject:item];
        [toRemove addObject:item];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title = %@",item.title];
        Genre* oldGenre = [[[myPref.totalGenres allObjects] filteredArrayUsingPredicate:predicate] objectAtIndex:0];
        NSLog(@"%@",oldGenre.title);
        [myPref removeOnlyIfNotObject:item];
    }];
    for(Genre* item in toRemove){
        
        id<GenreSortWindowDelegate> strongDelegate = self.delegate;
        if([strongDelegate respondsToSelector:@selector(deleteExcludeGenre:)]){
            [strongDelegate deleteExcludeGenre:item];
            NSError *error = nil;
            if (![myContext save:&error]) {
                NSLog(@"Delete Error");
            }
        }
        
//        [self.delegate deleteExcludeGenre:item];
//        [myPref removeOnlyIfNotObject:item];
        [excluded removeObject:item];
    }
    [_genresTable reloadData];
    [_excludeTable reloadData];
}

- (IBAction)removeInclude:(id)sender {
    NSIndexSet *indexSet = [_includeTable selectedRowIndexes];
    NSMutableArray *toRemove = [[NSMutableArray alloc]initWithCapacity:10];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        //use index
        Genre* item = [included objectAtIndex:index];
        [genres addObject:item];
        [toRemove addObject:item];
        [myPref removeOnlyIfObject:[included objectAtIndex:index]];
    }];
    for(Genre* item in toRemove){
        [included removeObject:item];
    }
    [_genresTable reloadData];
    [_includeTable reloadData];
}

- (IBAction)addInclude:(id)sender {
    NSIndexSet *indexSet = [_genresTable selectedRowIndexes];
    NSMutableArray *toRemove = [[NSMutableArray alloc]initWithCapacity:10];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        //use index
        Genre* item = [genres objectAtIndex:index];
        [included addObject:item];
        [toRemove addObject:item];
        [myPref addOnlyIfObject:item];
    }];
    for(Genre* item in toRemove){
        [genres removeObject:item];
    }
    [_genresTable reloadData];
    [_includeTable reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(tableView==_genresTable){
        return [genres count];
    }else if (tableView==_includeTable){
        return [included count];
    }else if (tableView==_excludeTable){
        return [excluded count];
    }
    NSLog(@"Error With table");
    return 0;
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
    if(tableView==_genresTable){
        Genre* thisGenre = [genres objectAtIndex:row];
        result.textField.stringValue = thisGenre.title;
    }else if (tableView==_includeTable){
        Genre* thisGenre = [included objectAtIndex:row];
        result.textField.stringValue = thisGenre.title;
    }else if (tableView==_excludeTable){
        Genre* thisGenre = [excluded objectAtIndex:row];
        result.textField.stringValue = thisGenre.title;
    }
    return result;
}
@end
