//
//  AddingWindow.h
//  ProjectN
//
//  Created by Sean Mullan on 3/3/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Manga.h"

@protocol AddingWindowDelegate;

@interface AddingWindow : NSWindowController{
    Manga* newManga;
}

@property (weak) IBOutlet NSTextField *inputText;
@property (weak) IBOutlet NSImageView *mangaImage;
@property (weak) IBOutlet NSTextField *title;
@property (weak) IBOutlet NSTextField *author;
@property (weak) IBOutlet NSTextField *artist;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *numChapters;
@property (weak) IBOutlet NSTextField *hostingSite;
@property (weak) IBOutlet NSButton *addButton;

#pragma mark - Delegate Stuff

@property (nonatomic, weak)id<AddingWindowDelegate> delegate;
-(void)failAlert;
- (IBAction)saveButton:(id)sender;

@end

@protocol AddingWindowDelegate <NSObject>

-(void)addingWindow:(AddingWindow*)addingWindow addedManga:(Manga*)manga;

@end
