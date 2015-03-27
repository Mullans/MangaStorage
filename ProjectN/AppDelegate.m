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


- (IBAction)addButton:(id)sender {
    addWindow = [[AddingWindow alloc]init];
    addWindow.delegate = self;
}

-(void)addingWindow:(AddingWindow *)addingWindow addedManga:(Manga *)manga{
    if([titles containsObject:[manga getTitle]]){
        [self failAlert];
        return;
    }
    [titles addObject:[manga getTitle]];
    [mangaList addObject:manga];
    [_tableView reloadData];
}

-(void)closingWindow{
    
}

-(void)failAlert{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Continue"];
    [alert setMessageText:@"New Manga Already Exists"];
    [alert setInformativeText:@"The manga you tried to add is already in your library."];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[self window] completionHandler:nil];
}

- (IBAction)updateItemSelect:(id)sender {
    NSIndexSet *indexSet = [_tableView selectedRowIndexes];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
        //use index
        [[mangaList objectAtIndex:index]updateChapters];
        NSLog(@"%lu",index);
    }];
    
}

- (IBAction)updateAllItemSelect:(id)sender {
    for(Manga *item in mangaList){
        [item updateChapters];
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
    Manga* manga = [mangaList objectAtIndex:row];
    int columnIndex = [possibleOptions indexOfObject:tableColumn.identifier];
    if (columnIndex==0){
        result.textField.stringValue = [manga getTitle];
    }else if(columnIndex==1){
        result.textField.stringValue = [manga getAuthor];
    }else if(columnIndex==2){
        result.textField.stringValue = [manga getArtist];
    }else if(columnIndex==3){
        result.textField.stringValue = [manga getHost];
    }else if(columnIndex==4){
        result.textField.stringValue = [NSString stringWithFormat:@"%i",(int)[manga getNumChapters]];
    }else if (columnIndex==5){
        if([manga getStatus]==true){
            result.textField.stringValue = @"Completed";
        }else{
            result.textField.stringValue = @"Ongoing";
        }
    }else if(columnIndex==6){
        result.textField.stringValue = [NSString stringWithFormat:@"%i",(int)[manga getNumberToRead]];
    }
    return result;
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender{
    return YES;
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
        if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
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
