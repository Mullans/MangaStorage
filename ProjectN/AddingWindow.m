//
//  AddingWindow.m
//  ProjectN
//
//  Created by Sean Mullan on 3/3/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import "AddingWindow.h"

@interface AddingWindow ()

@end

@implementation AddingWindow


-(id)init{
    self = [super initWithWindowNibName:@"AddingWindow"];
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    [self.window setTitle:@"Add New Manga"];
    return self;
}



- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//Make it so enter on text box does this too
- (IBAction)searchButton:(id)sender {
    NSURL *search = [NSURL URLWithString: _inputText.stringValue];
    @try{
        newManga = [[Manga alloc]initWithURL:search];
        [_title setStringValue:[@"Title: " stringByAppendingString:[newManga getTitle]]];
        [_title sizeToFit];
        
        [_mangaImage setImage:[newManga getCover]];
        
        [_author setStringValue:[@"Author: " stringByAppendingString:[newManga getAuthor]]];
        [_author sizeToFit];
        
        [_artist setStringValue:[@"Artist: " stringByAppendingString:[newManga getArtist]]];
        [_artist sizeToFit];
        
        if ([newManga getAuthor]){
            [_status setStringValue:@"Status: Ongoing"];
            [_status sizeToFit];
        }else{
            [_status setStringValue:@"Status: Completed"];
            [_status sizeToFit];
        }
        
        [_hostingSite setStringValue:[@"Host: " stringByAppendingString:[newManga getHost]]];
        [_hostingSite sizeToFit];
        
        [_numChapters setStringValue:[@"Number Of Chapters: " stringByAppendingString:[NSString stringWithFormat:@"%i",[newManga getNumChapters]]]];
        [_numChapters sizeToFit];
        
        [_addButton setEnabled:YES];
    }@catch(NSException *e){
        [self failAlert];
    }
}
-(void)failAlert{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Continue"];
    [alert setMessageText:@"Failure To Find Manga"];
    [alert setInformativeText:@"We have failed to find your specific manga. Make sure that you have copied the URL exactly as it is in your browser."];
     [alert setAlertStyle:NSCriticalAlertStyle];
     [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}


- (IBAction)saveButton:(id)sender {
    id<AddingWindowDelegate> strongDelegate = self.delegate;
    
    if([strongDelegate respondsToSelector:@selector(addingWindow:addedManga:)]){
        [strongDelegate addingWindow:self addedManga:newManga];
    }
    
    [self.window close];
}
@end
