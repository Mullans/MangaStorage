//
//  AppDelegate.h
//  ProjectN
//
//  Created by Sean Mullan on 3/3/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddingWindow.h"
#import "MangaWindow.h"
#import "MangaEntity.h"
#import "PreferenceEntity.h"
#import "Genre.h"
#import "GenreSortWindow.h"

//TODO: make shown categories customizable
//TODO: IMPORTANT implement coredata

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, AddingWindowDelegate, NSWindowDelegate,GenreSortWindowDelegate>{
    NSMutableArray *mangaList;
    AddingWindow *addWindow;
    MangaWindow *mangaWindow;
    GenreSortWindow *genreWindow;
    NSMutableArray *columnOptions;
    NSArray *possibleOptions;
    NSArray *widths;
    NSMutableArray *titles;
    
    NSMutableArray *sorters;
    NSMutableArray *sortDescriptors;
    NSArray *predicateKeys;
    
    bool updatesOnly;
    bool sortByGenre;
    PreferenceEntity *preference;
}
@property (weak) IBOutlet NSMenuItem *titleMenu;
@property (weak) IBOutlet NSMenuItem *authorMenu;
@property (weak) IBOutlet NSMenuItem *artistMenu;
@property (weak) IBOutlet NSMenuItem *hostingMenu;
@property (weak) IBOutlet NSMenuItem *numberMenu;
@property (weak) IBOutlet NSMenuItem *statusMenu;
@property (weak) IBOutlet NSMenuItem *updatesMenu;
@property (weak) IBOutlet NSMenuItem *ratingsMenu;
@property (weak) IBOutlet NSMenuItem *undoItem;
@property (weak) IBOutlet NSMenuItem *redoItem;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSMenuItem *genreSortItem;

- (IBAction)undoItemSelect:(id)sender;
- (IBAction)redoItemSelect:(id)sender;
- (IBAction)genreSortItemSelect:(id)sender;
- (IBAction)genreSortEditItemSelect:(id)sender;
- (IBAction)showOnlyUpdates:(id)sender;

- (IBAction)deleteItem:(id)sender;

- (IBAction)updateItemSelect:(id)sender;
- (IBAction)updateAllItemSelect:(id)sender;
- (IBAction)newMenuItemSelect:(id)sender;
- (IBAction)viewItemSelect:(id)sender;
-(void)rowDoubleClicked;
-(void)updateTableColumns;
-(void)reloadTable;
@end

