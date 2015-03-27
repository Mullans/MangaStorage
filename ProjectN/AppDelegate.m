//
//  AppDelegate.m
//  ProjectN
//
//  Created by Sean Mullan on 3/3/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation AppDelegate





- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    mangaList = [[NSMutableArray alloc]initWithCapacity:10];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setDoubleAction:@selector(rowDoubleClicked)];
    widths = @[@6,@4,@4,@4,@3,@4,@3,@3];
    columnOptions = [[NSMutableArray alloc]initWithArray:@[@1,@1,@1,@0,@0,@1,@0,@0]];
    possibleOptions = @[@"Title",@"Author",@"Artist",@"Hosting Site",@"Number of Chapters",@"Status",@"Updates",@"Rating"];
    predicateKeys = @[@"title",@"author",@"artist",@"host",@"chapterTotal",@"status",@"unreadChapters",@"rating"];
    
    //set initial sorting
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                                 ascending:YES];
    sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
//    mangaList = [mangaList sortedArrayUsingDescriptors:sortDescriptors];
    
    NSFetchRequest *preferencesRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *preferenceDescriptor = [NSEntityDescription entityForName:@"PreferenceEntity" inManagedObjectContext:[self managedObjectContext]];
    [preferencesRequest setEntity:preferenceDescriptor];
    NSError *prefError = nil;
    NSArray *fetchedPreference =[[self managedObjectContext] executeFetchRequest:preferencesRequest error:&prefError];
    if([fetchedPreference count]==0){
        //genereate
        preference = (PreferenceEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"PreferenceEntity" inManagedObjectContext:[self managedObjectContext]];
    }else if([fetchedPreference count]==1){
        preference = [fetchedPreference objectAtIndex:0];
    }else{
        NSLog(@"TOO MANY PREFERENCE OBJECTS");
    }
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MangaEntity" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    [fetchRequest setSortDescriptors:sortDescriptors];
    mangaList = [[NSMutableArray alloc]initWithArray:[[self managedObjectContext] executeFetchRequest:fetchRequest error:&error]];
    if (mangaList == nil) {
        NSLog(@"Problem! %@",error);
    }
    sorters = [[NSMutableArray alloc]initWithArray:@[@2,@0,@0,@0,@0,@0,@0,@0]];

    [_tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:[_tableView tableColumnWithIdentifier:@"Title"]];
    
    [self updateTableColumns];
}

-(void)windowWillClose:(NSNotification *)notification{
    mangaList = [[NSMutableArray alloc] initWithArray:[mangaList sortedArrayUsingDescriptors:sortDescriptors]];
    [_tableView reloadData];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
}

#pragma mark - Adding Window Methods
- (IBAction)addButton:(id)sender {
    addWindow = [[AddingWindow alloc]initWithContext:_managedObjectContext];
    addWindow.delegate = self;
}

-(void)addingWindow:(AddingWindow *)addingWindow addedManga:(MangaEntity *)manga{
    [mangaList addObject:manga];
    mangaList = [[NSMutableArray alloc] initWithArray:[mangaList sortedArrayUsingDescriptors:sortDescriptors]];
    NSMutableArray *genreStrings = [[NSMutableArray alloc]initWithCapacity:10];
    for(Genre* genre in preference.totalGenres){
        [genreStrings addObject:genre.title];
    }
    for(Genre* genre in manga.genres){
        if([genreStrings containsObject:genre.title]){
            continue;
        }
        [preference addTotalGenresObject:genre];
    }

    [_tableView reloadData];
}

#pragma mark - Menu Item Methods
- (IBAction)undoItemSelect:(id)sender {
    [self.managedObjectContext undo];
    [self reloadTable];
}

- (IBAction)redoItemSelect:(id)sender {
    [self.managedObjectContext redo];
    [self reloadTable];
}

- (IBAction)genreSortItemSelect:(id)sender {
    NSLog(@"Genre Sorting");
}

- (IBAction)genreSortEditItemSelect:(id)sender {
    NSLog(@"Genre Sort Pref");
}

- (IBAction)deleteItem:(id)sender {
    NSIndexSet *indexSet = [_tableView selectedRowIndexes];
    NSMutableArray *toRemove = [[NSMutableArray alloc]initWithCapacity:10];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        //use index
        [_managedObjectContext deleteObject:[mangaList objectAtIndex:index]];
        [toRemove addObject:[mangaList objectAtIndex:index]];
    }];
    for(NSObject *item in toRemove){
        [mangaList removeObject:item];
    }
    [_tableView reloadData];
}

- (IBAction)updateItemSelect:(id)sender {
    NSIndexSet *indexSet = [_tableView selectedRowIndexes];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        //use index
        [[mangaList objectAtIndex:index]updateChapters];
    }];
    
}

- (IBAction)updateAllItemSelect:(id)sender {
    for(MangaEntity *item in mangaList){
        [item updateChapters:_managedObjectContext];
    }
}

- (IBAction)newMenuItemSelect:(id)sender {
    addWindow = [[AddingWindow alloc]init];
    addWindow.delegate = self;
}

- (IBAction)viewItemSelect:(id)sender {
    if ([[sender title] rangeOfString:@"Hide"].location == NSNotFound) {
        if (sender==_titleMenu){
            [columnOptions replaceObjectAtIndex:0 withObject:@1];
            _titleMenu.title = @"Hide Title";
        }else if(sender==_authorMenu){
            [columnOptions replaceObjectAtIndex:1 withObject:@1];
            _authorMenu.title = @"Hide Author";
        }else if(sender==_artistMenu){
            [columnOptions replaceObjectAtIndex:2 withObject:@1];
            _artistMenu.title = @"Hide Artist";
        }else if(sender==_hostingMenu){
            [columnOptions replaceObjectAtIndex:3 withObject:@1];
            _hostingMenu.title = @"Hide Hosting Site";
        }else if(sender==_numberMenu){
            [columnOptions replaceObjectAtIndex:4 withObject:@1];
            _numberMenu.title = @"Hide Number of Chapters";
        }else if(sender==_statusMenu){
            [columnOptions replaceObjectAtIndex:5 withObject:@1];
            _statusMenu.title = @"Hide Current Status";
        }else if (sender==_updatesMenu){
            [columnOptions replaceObjectAtIndex:6 withObject:@1];
            _updatesMenu.title = @"Hide New Updates";
        }else if (sender==_ratingsMenu){
            [columnOptions replaceObjectAtIndex:7 withObject:@1];
            _updatesMenu.title = @"Hide Ratings";
        }
    }else{
        if (sender==_titleMenu){
            [columnOptions replaceObjectAtIndex:0 withObject:@0];
            _titleMenu.title = @"Show Title";
        }else if(sender==_authorMenu){
            [columnOptions replaceObjectAtIndex:1 withObject:@0];
            _authorMenu.title = @"Show Author";
        }else if(sender==_artistMenu){
            [columnOptions replaceObjectAtIndex:2 withObject:@0];
            _artistMenu.title = @"Show Artist";
        }else if(sender==_hostingMenu){
            [columnOptions replaceObjectAtIndex:3 withObject:@0];
            _hostingMenu.title = @"Show Hosting Site";
        }else if(sender==_numberMenu){
            [columnOptions replaceObjectAtIndex:4 withObject:@0];
            _numberMenu.title = @"Show Number of Chapters";
        }else if(sender==_statusMenu){
            [columnOptions replaceObjectAtIndex:5 withObject:@0];
            _statusMenu.title = @"Show Current Status";
        }else if (sender==_updatesMenu){
            [columnOptions replaceObjectAtIndex:6 withObject:@0];
            _updatesMenu.title = @"Show New Updates";
        }else if (sender==_ratingsMenu){
            [columnOptions replaceObjectAtIndex:7 withObject:@0];
             _updatesMenu.title = @"Show Ratings";
        }
    }
    [self updateTableColumns];
}




#pragma mark - Table Methods

-(void)reloadTable{
    //only use this when coredata is changed without also changing mangaList
    //ie. undo and redo
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"MangaEntity" inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSError *error = nil;
    mangaList = [[NSMutableArray alloc]initWithArray:[[self managedObjectContext] executeFetchRequest:fetchRequest error:&error]];
    if (mangaList == nil) {
        NSLog(@"Problem! %@",error);
    }
    mangaList = [[NSMutableArray alloc] initWithArray:[mangaList sortedArrayUsingDescriptors:sortDescriptors]];
    [_tableView reloadData];
}

//clicked on columnheader
-(void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn{
    NSUInteger index = [possibleOptions indexOfObject:tableColumn.identifier];
    
    if([sorters[index] isEqual:@(0)]){
        sorters[index] = @(2);
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:predicateKeys[index] ascending:YES];
        [sortDescriptors insertObject:sortDescriptor atIndex:0];
        [_tableView setIndicatorImage:[NSImage imageNamed:@"NSDescendingSortIndicator"] inTableColumn:tableColumn];
    }else if([sorters[index] isEqual:@(2)]){
        sorters[index] = @(1);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@",predicateKeys[index]];
        [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:predicateKeys[index] ascending:NO];
        [sortDescriptors insertObject:sortDescriptor atIndex:0];
        [_tableView setIndicatorImage:[NSImage imageNamed:@"NSAscendingSortIndicator"] inTableColumn:tableColumn];
        
    }else if([sorters[index] isEqual:@(1)]){
        sorters[index] = @(0);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@",predicateKeys[index]];
        [sortDescriptors removeObject:[[sortDescriptors filteredArrayUsingPredicate:predicate] objectAtIndex:0]];
        [_tableView setIndicatorImage:nil inTableColumn:tableColumn];
    }
    
    mangaList = [[NSMutableArray alloc] initWithArray:[mangaList sortedArrayUsingDescriptors:sortDescriptors]];
    [_tableView reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return mangaList.count;
}

-(void)rowDoubleClicked{
    if([_tableView clickedRow] == -1){
        return;
    }
    @try{
        mangaWindow = [[MangaWindow alloc]initWithManga:[mangaList objectAtIndex:[_tableView clickedRow]] parent:self context:_managedObjectContext];
    }@catch(NSException *e){
        NSLog(@"Didn't click on row");
    }
    
    
    //mangaWindow.delegate = self;
}

-(void)updateTableColumns{
    //makes sure the appropriate columns are present
    int total = 0;
    for(int i = 0; i<columnOptions.count; i++){
        int columnIndex = (int)[_tableView columnWithIdentifier:possibleOptions[i]];
        if([columnOptions[i] integerValue]==1){
            total+=[widths[i] integerValue];
            if(columnIndex==-1){
                NSTableColumn *newColumn = [[NSTableColumn alloc]initWithIdentifier:possibleOptions[i]];
                [[newColumn headerCell]setStringValue:possibleOptions[i]];
                
                int j = 3;
                j++;
                
                [_tableView addTableColumn:newColumn];
            }
        }else{
            if(columnIndex != -1){
                [_tableView removeTableColumn:[_tableView tableColumnWithIdentifier:possibleOptions[i]]];
            }
        }
    }
    //rearranges and resizes columns
    int index = 0;
    for(int i = 0; i<columnOptions.count; i++){
        if([columnOptions[i] integerValue]==1){
            int columnID = (int)[_tableView columnWithIdentifier:possibleOptions[i]];
            [_tableView moveColumn:columnID toColumn:index];
            index++;
            float columnWidth = ([widths[i] floatValue]/total)*_tableView.window.frame.size.width-13;
            [[_tableView tableColumnWithIdentifier:possibleOptions[i]]  setWidth:columnWidth];
        }
    }
    
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    mangaList = [[NSMutableArray alloc]initWithCapacity:10];
//    Manga *item = [[Manga alloc]init];
//    [mangaList addObject:item];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView setDoubleAction:@selector(rowDoubleClicked)];
    widths = @[@6,@4,@4,@4,@3,@4,@3,@3];
    columnOptions = [[NSMutableArray alloc]initWithArray:@[@1,@1,@1,@0,@0,@1,@0,@0]];
    possibleOptions = @[@"Title",@"Author",@"Artist",@"Hosting Site",@"Number of Chapters",@"Status",@"Updates",@"Ratings"];
    
    //add code to initialize titles
    titles = [[NSMutableArray alloc]initWithCapacity:10];
    
    
    [self updateTableColumns];
}

-(void)rowDoubleClicked{
    @try{
        mangaWindow = [[MangaWindow alloc]initWithManga:[mangaList objectAtIndex:[_tableView clickedRow]] parent:self];
    }@catch(NSException *e){
        NSLog(@"Didn't click on row");
    }

        
    //mangaWindow.delegate = self;
}

-(void)windowWillClose:(NSNotification *)notification{
    NSLog(@"Window closed");
    [_tableView reloadData];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

//clicked on columnheader
-(void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn{
    NSLog(@"Sort based on header TBD");
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return mangaList.count;
}


//if images, height 50, else text height (change in actual table?)
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
    MangaEntity* manga = [mangaList objectAtIndex:row];
    NSUInteger columnIndex = [possibleOptions indexOfObject:tableColumn.identifier];
    if (columnIndex==0){
        result.textField.stringValue = manga.title;
    }else if(columnIndex==1){
        result.textField.stringValue = manga.author;
    }else if(columnIndex==2){
        result.textField.stringValue = manga.artist;
    }else if(columnIndex==3){
        result.textField.stringValue = manga.host;
    }else if(columnIndex==4){
        result.textField.stringValue = [NSString stringWithFormat:@"%li",(long)[manga.chapterTotal integerValue]];
    }else if (columnIndex==5){
        if([manga.status isEqual:@(YES)]){
            result.textField.stringValue = @"Completed";
        }else{
            result.textField.stringValue = @"Ongoing";
        }
    }else if(columnIndex==6){
        result.textField.stringValue = [NSString stringWithFormat:@"%li",(long)[manga.unreadChapters integerValue]];
    }
    return result;
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mullan.ProjectN" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.mullan.ProjectN"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ProjectN" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationDocumentsDirectory = [self applicationDocumentsDirectory];
    BOOL shouldFail = NO;
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    
    // Make sure the application files directory is there
    NSDictionary *properties = [applicationDocumentsDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    if (properties) {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            failureReason = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationDocumentsDirectory path]];
            shouldFail = YES;
        }
    } else if ([error code] == NSFileReadNoSuchFileError) {
        error = nil;
        [fileManager createDirectoryAtPath:[applicationDocumentsDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    if (!shouldFail && !error) {
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        NSURL *url = [applicationDocumentsDirectory URLByAppendingPathComponent:@"OSXCoreDataObjC.storedata"];
        if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
            coordinator = nil;
        }
        _persistentStoreCoordinator = coordinator;
    }
    
    if (shouldFail || error) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        if (error) {
            dict[NSUnderlyingErrorKey] = error;
        }
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

#pragma mark - Core Data Saving and Undo support

- (IBAction)saveAction:(id)sender {
    // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    NSError *error = nil;
    if ([[self managedObjectContext] hasChanges] && ![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
    return [[self managedObjectContext] undoManager];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertFirstButtonReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

@end
