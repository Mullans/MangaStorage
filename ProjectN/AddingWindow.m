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


- (IBAction)attributeEdited:(id)sender {
    if(sender==_title){
        myManga.title = _title.stringValue;
    }else if(sender==_author){
        myManga.author = _author.stringValue;
    }else if(sender==_artist){
        myManga.artist = _artist.stringValue;
    }else if(sender==_numChapters){
        if([_numChapters integerValue]<1){
            _numChapters.stringValue = [myManga.chapterTotal stringValue];
            return;
        }
        myManga.chapterTotal = @([_numChapters integerValue]);
    }else if(sender==_hostingSite){
        myManga.host = _hostingSite.stringValue;
    }
    [sender sizeToFit];
}

-(id)initWithContext:(NSManagedObjectContext*)context{
    self = [super initWithWindowNibName:@"AddingWindow"];
    [self.window makeKeyAndOrderFront:self];
    [self.window makeMainWindow];
    [self.window setTitle:@"Add New Manga"];
    self.window.delegate = self;
    _context = context;
    toSave = false;
    return self;
}

-(BOOL)windowShouldClose:(id)sender{
    if(!toSave){
        if(myManga!=nil){
            [_context deleteObject:myManga];
        }
    }
    return true;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

//Make it so enter on text box does this too
- (IBAction)searchButton:(id)sender {
    NSURL *search = [NSURL URLWithString: _inputText.stringValue];
    myManga = (MangaEntity*)[NSEntityDescription insertNewObjectForEntityForName:@"MangaEntity" inManagedObjectContext:_context];
    @try{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MangaEntity" inManagedObjectContext:_context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"mangaURL == %@",[search absoluteString]];
        [fetchRequest setPredicate:predicate];
        NSUInteger count = [_context countForFetchRequest:fetchRequest error:nil];
        if (count==NSNotFound || count==0){
            [myManga generateData:search context:_context];
        }else{
            //something to say that the data already exists
            [_context deleteObject:myManga];
            [self failAlert:2];
            return;
        }
        
        [_title setStringValue:myManga.title];
        [_title sizeToFit];
        
        [_mangaImage setImage:[[NSImage alloc]initWithData:myManga.coverArt]];
        
        [_author setStringValue:myManga.author];
        [_author sizeToFit];
        
        [_artist setStringValue:myManga.artist];
        [_artist sizeToFit];
        
        if (myManga.status){
            [_status setStringValue:@"Ongoing"];
            [_status sizeToFit];
        }else{
            [_status setStringValue:@"Completed"];
            [_status sizeToFit];
        }
        
        [_hostingSite setStringValue:myManga.host];
        [_hostingSite sizeToFit];
        
        [_numChapters setStringValue:[NSString stringWithFormat:@"%li",[myManga.chapterTotal integerValue]]];
        [_numChapters sizeToFit];
        
        [_addButton setEnabled:YES];
    }@catch(NSException *e){
        [_context deleteObject:myManga];
        [self failAlert:1];
    }
}
-(void)failAlert:(int)option{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Continue"];
    if(option==1){
        [alert setMessageText:@"Failure To Find Manga"];
        [alert setInformativeText:@"We have failed to find your specific manga. Make sure that you have copied the URL exactly as it is in your browser."];
    }else if(option==2){
        [alert setMessageText:@"Manga Already Exists"];
        [alert setInformativeText:@"The manga you have searched for already exists in your data."];
    }
     [alert setAlertStyle:NSCriticalAlertStyle];
     [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:nil];
}


- (IBAction)saveButton:(id)sender {
    id<AddingWindowDelegate> strongDelegate = self.delegate;
    
    if([strongDelegate respondsToSelector:@selector(addingWindow:addedManga:)]){
        [strongDelegate addingWindow:self addedManga:myManga];
    }
    toSave = true;
    [self.window close];
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
@end
