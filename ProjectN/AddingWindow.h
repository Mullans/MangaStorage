//
//  AddingWindow.h
//  ProjectN
//
//  Created by Sean Mullan on 3/3/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Manga.h"
#import "MangaEntity.h"

@protocol AddingWindowDelegate;

@interface AddingWindow : NSWindowController<NSWindowDelegate>{
    Manga* newManga;
    MangaEntity* myManga;
    bool *toSave;
}
@property (weak) IBOutlet NSTextField *inputText;
@property (weak) IBOutlet NSImageView *mangaImage;
@property (weak) IBOutlet NSTextField *title;
@property (weak) IBOutlet NSTextField *author;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSTextField *numChapters;
@property (weak) IBOutlet NSTextField *hostingSite;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) NSManagedObjectContext* context;
@property (weak) IBOutlet NSButton *status;


- (IBAction)attributeEdited:(id)sender;
-(id)initWithContext:(NSManagedObjectContext*)context;

#pragma mark - Delegate Stuff

@property (nonatomic, weak)id<AddingWindowDelegate> delegate;
-(void)failAlert: (int)option;
- (IBAction)saveButton:(id)sender;
- (IBAction)statusChange:(id)sender;
@end

@protocol AddingWindowDelegate <NSObject>

-(void)addingWindow:(AddingWindow*)addingWindow addedManga:(MangaEntity*)manga;

@end
