//
//  MangaEntity.m
//  MangaStorage
//
//  Created by Sean Mullan on 3/24/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import "MangaEntity.h"


@implementation MangaEntity

@dynamic author;
@dynamic title;
@dynamic artist;
@dynamic host;
@dynamic chapterTotal;
@dynamic coverArt;
@dynamic status;
@dynamic mangaURL;
@dynamic unreadChapters;
@dynamic chapters;

-(void)generateData:(NSURL *)mangaURL context:(NSManagedObjectContext *)context{
    self.mangaURL = [mangaURL absoluteString];
    
    NSString *imgString;
    NSString *titleString;
    NSString *authorString;
    NSString *artistString;
    NSString *completedString;
    int addToImgRange;
    int subFromImgLength;
    int addToTitleRange;
    int subFromTitleLength;
    int addToAuthorRange;
    int subFromAuthorLength;
    int addToArtistRange;
    int subFromArtistLength;
    int addToCompletedRange;
    int subFromCompletedLength;
    NSString *updatedCheck;
    
    NSString *tableSearchString;
    
    NSString *html = [NSString stringWithContentsOfURL:mangaURL encoding:NSUTF8StringEncoding error:nil];
    
    //mangareader.net
    if ([[mangaURL absoluteString] rangeOfString:@"mangareader.net"].location != NSNotFound){
        self.host = @"MangaReader.net";
        imgString = @"(<img src=\"http://s)([0-9])(.mangareader.net/cover/)(.*?)(.jpg\")";
        titleString = @"(<h2 class=\"aname\">)(.*?)(</h2>)";
        authorString = @"(<td class=\"propertytitle\">Author:</td>)([\n\r])(<td>)(.*?)(</td>)";
        artistString = @"(<td class=\"propertytitle\">Artist:</td>)([\n\r])(<td>)(.*?)(</td>)";
        completedString = @"(<td class=\"propertytitle\">Status:</td>)([\n\r])(<td>)(.*?)(</td>)";
        addToImgRange = 10;
        subFromImgLength = 11;
        addToTitleRange = 18;
        subFromTitleLength = 23;
        addToAuthorRange = 43;
        subFromAuthorLength = 48;
        addToArtistRange = 43;
        subFromArtistLength = 48;
        addToCompletedRange = 43;
        subFromCompletedLength = 48;
        updatedCheck = @"Ongoing";
        
        
        tableSearchString = @"(<table id=\"listing\">)(.*?)(</table>)";
        NSRegularExpression *tableRegex = [NSRegularExpression regularExpressionWithPattern:tableSearchString
                                                                                    options:NSRegularExpressionDotMatchesLineSeparators
                                                                                      error:nil];
        NSRange tableRange = [tableRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
        tableRange.location+=20;
        tableRange.length-=7;
        NSArray *tableArray = [[html substringWithRange:tableRange] componentsSeparatedByString:@"<tr>"];
        NSMutableArray *chapterArray = [[NSMutableArray alloc]initWithCapacity:10];
        NSRegularExpression *chapterFinder = [NSRegularExpression regularExpressionWithPattern:@"(:)(.*?)(</td>)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
        NSRegularExpression *chapterURLFinder = [NSRegularExpression regularExpressionWithPattern:@"(<a href=\")(.*?)(\">)"
                                                                                          options:NSRegularExpressionCaseInsensitive
                                                                                            error:nil];
        tableArray = [tableArray subarrayWithRange:NSMakeRange(1,tableArray.count-1)];
        int chapterIndex = 0;
        for(NSString *item in tableArray){
            NSRange chapterRange = [chapterFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterRange.location+=1;
            chapterRange.length-=6;
            NSString *chapterTitle = [item substringWithRange:chapterRange];
            
            NSRange chapterURLRange = [chapterURLFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterURLRange.location+=9;
            chapterURLRange.length-=11;
            NSString *chapterURLString = [item substringWithRange:chapterURLRange];
            NSURL *chapterURL = [[NSURL alloc]initWithString:[@"http://www.mangareader.net" stringByAppendingString:chapterURLString]];
            
            if([chapterTitle isEqualToString:@""]){
                NSRegularExpression *chapterFinder2 = [NSRegularExpression regularExpressionWithPattern:@"(\">)(.*?)(</a>)"
                                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                                  error:nil];
                chapterRange = [chapterFinder2 rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
                chapterRange.location+=3;
                chapterRange.length-=7;
                chapterTitle = [item substringWithRange:chapterRange];
            }
            
            Chapter *newChapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:context];
            newChapter.title = chapterTitle;
            newChapter.status = [NSNumber numberWithBool:NO];
            newChapter.manga = self;
            newChapter.chapterURL = [chapterURL absoluteString];
            newChapter.index = [NSNumber numberWithInt: chapterIndex];
            [chapterArray addObject:newChapter];
            chapterIndex++;
            
        }
        self.chapters = [[NSSet alloc]initWithArray:chapterArray];
        self.chapterTotal = [NSNumber numberWithInt:chapterIndex];
        self.unreadChapters = self.chapterTotal;
    }
    
    
    
    
    //Get the cover art
    NSRegularExpression *imgRegex = [NSRegularExpression regularExpressionWithPattern:imgString
                                                                              options:NSRegularExpressionCaseInsensitive
                                                                                error:nil];
    NSRange imgRange = [imgRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
    imgRange.location+=addToImgRange;
    imgRange.length-=subFromImgLength;
    imgString = [html substringWithRange:imgRange];
    NSURL *imgURL = [NSURL URLWithString:[html substringWithRange:imgRange]];
    self.coverArt = [[[NSImage alloc]initWithContentsOfURL:imgURL] TIFFRepresentation];
    
    
    //Get the title
    NSRegularExpression *titleRegex = [NSRegularExpression regularExpressionWithPattern:titleString
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:nil];
    NSRange titleRange = [titleRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
    titleRange.location+=addToTitleRange;
    titleRange.length-=subFromTitleLength;
    self.title = [html substringWithRange:titleRange];
    
    
    //get the author
    NSRegularExpression *authorRegex = [NSRegularExpression regularExpressionWithPattern:authorString
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    NSRange authorRange = [authorRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
    authorRange.location+=addToAuthorRange;
    authorRange.length-=subFromAuthorLength;
    self.author = [html substringWithRange:authorRange];
    if([self.author isEqualToString:@""]){
        self.author = @"N/A";
    }
    
    //get the artist
    NSRegularExpression *artistRegex = [NSRegularExpression regularExpressionWithPattern:artistString
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    NSRange artistRange = [artistRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
    artistRange.location+=addToArtistRange;
    artistRange.length-=subFromArtistLength;
    self.artist = [html substringWithRange:artistRange];
    if([self.artist isEqualToString:@""]){
        self.artist = @"N/A";
    }
    
    //get the status
    NSRegularExpression *completedRegex = [NSRegularExpression regularExpressionWithPattern:completedString options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange completedRange = [completedRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0,html.length)];
    completedRange.location+=addToCompletedRange;
    completedRange.length-=subFromCompletedLength;
    
    if ([[html substringWithRange:completedRange] isEqualToString:updatedCheck]){
        self.status = [NSNumber numberWithBool:NO];
    }else{
        self.status = [NSNumber numberWithBool:YES];
    }

}

-(void)updateChapters{
    //use the addChaptersObject and addChapters methods?
}
@end
