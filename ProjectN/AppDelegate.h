//
//  AppDelegate.h
//  ProjectN
//
//  Created by Sean Mullan on 3/3/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddingWindow.h"
#import "Manga.h"
#import "MangaWindow.h"

//TODO: make shown categories customizable
//TODO: IMPORTANT implement coredata

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, AddingWindowDelegate>{
    NSMutableArray *mangaList;
    AddingWindow *addWindow;
    MangaWindow *mangaWindow;
    NSMutableArray *columnOptions;
    NSArray *possibleOptions;
    NSArray *widths;
}
@property (weak) IBOutlet NSMenuItem *titleMenu;
@property (weak) IBOutlet NSMenuItem *authorMenu;
@property (weak) IBOutlet NSMenuItem *artistMenu;
@property (weak) IBOutlet NSMenuItem *hostingMenu;
@property (weak) IBOutlet NSMenuItem *numberMenu;
@property (weak) IBOutlet NSMenuItem *statusMenu;
@property (weak) IBOutlet NSMenuItem *updatesMenu;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;

- (IBAction)viewItemSelect:(id)sender;
-(void)rowDoubleClicked;
-(void)updateTableColumns;
@end

