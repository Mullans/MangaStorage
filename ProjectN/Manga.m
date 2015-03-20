//
//  Manga.m
//  ProjectN
//
//  Created by Sean Mullan on 3/7/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import "Manga.h"

@implementation Manga

- (instancetype)init
{
    self = [super init];
    if (self) {
        author = @"No one";
        title = @"Nothing";
        chapterTotal = 0;
        chapterList = @[];
        finished = NO;
    }
    return self;
}

-(id)initWithURL:(NSURL*)mangaURL{
    self = [super init];
    
    //tenmanga.com
    /*
    NSString *imgString = @"(<meta property=\"og:image\" content=\"http://img.mangayes.com/files/img/logo/)([0-9]*?)(/)([0-9]*?)(.jpg)";
    NSString *titleString = @"(content=\")(.*?)( Manga - Read)";
     
    NSString *authorString = @"(href=\"http://www.taadd.com/search/author-)(.*?)(.html\">)";
    NSString *completedString = @"(http://www.taadd.com/category/)(.*?)</a>";
     
     int addToImgRange = 35;
     int subFromImgLength = 35;
     int addToTitleRange = 9;
     int subFromTitleLength = 22;
     int addToAuthorRange = 41;
     int subFromAuthorLength = 48;
     int addToCompletedRange = 44;
     int subFromCompletedLength = 48;

     */
    
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
    NSArray *tempChapterList = @[];
    
    NSString *html = [NSString stringWithContentsOfURL:mangaURL encoding:NSUTF8StringEncoding error:nil];
    
    //mangareader.net
    if ([[mangaURL absoluteString] rangeOfString:@"mangareader.net"].location != NSNotFound){
        host = @"MangaReader.net";
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
        tableArray = [tableArray subarrayWithRange:NSMakeRange(1,tableArray.count-1)];
        for(NSString *item in tableArray){
            NSRange chapterRange = [chapterFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterRange.location+=2;
            chapterRange.length-=7;
            NSString *chapterTitle = [item substringWithRange:chapterRange];
            if([chapterTitle isEqualToString:@""]){
                NSRegularExpression *chapterFinder2 = [NSRegularExpression regularExpressionWithPattern:@"([0-9]\">)(.*?)(</a>)"
                                                                          options:NSRegularExpressionCaseInsensitive
                                                                            error:nil];
                chapterRange = [chapterFinder2 rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
                chapterRange.location+=3;
                chapterRange.length-=7;
                chapterTitle = [item substringWithRange:chapterRange];
            }
            [chapterArray addObject:@[chapterTitle,@false]];
        }
        chapterList = chapterArray;
        chapterTotal = (NSInteger)chapterArray.count;
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
    coverArt = [[NSImage alloc]initWithContentsOfURL:imgURL];

    
    //Get the title
    NSRegularExpression *titleRegex = [NSRegularExpression regularExpressionWithPattern:titleString
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:nil];
    NSRange titleRange = [titleRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
    titleRange.location+=addToTitleRange;
    titleRange.length-=subFromTitleLength;
    title = [html substringWithRange:titleRange];
    
    
    //get the author
    NSRegularExpression *authorRegex = [NSRegularExpression regularExpressionWithPattern:authorString
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    NSRange authorRange = [authorRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
    authorRange.location+=addToAuthorRange;
    authorRange.length-=subFromAuthorLength;
    author = [html substringWithRange:authorRange];
    
    //get the artist
    NSRegularExpression *artistRegex = [NSRegularExpression regularExpressionWithPattern:artistString
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    NSRange artistRange = [artistRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
    artistRange.location+=addToArtistRange;
    artistRange.length-=subFromArtistLength;
    artist = [html substringWithRange:artistRange];
    if([artist isEqualToString:@""]){
        artist = @"N/A";
    }
    
    //get the status
    NSRegularExpression *completedRegex = [NSRegularExpression regularExpressionWithPattern:completedString options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange completedRange = [completedRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0,html.length)];
    completedRange.location+=addToCompletedRange;
    completedRange.length-=subFromCompletedLength;
    
    NSLog([html substringWithRange:completedRange]);
    if ([[html substringWithRange:completedRange] isEqualToString:updatedCheck]){
        finished = NO;
    }else{
        finished = YES;
    }
    
    
    
    return self;
}
-(void)print{
    NSLog(@"%@\n%@\n%hhd",title,author,finished);
}

-(NSString*)getAuthor{
    return author;
}
-(NSString*)getTitle{
    return title;
}
-(BOOL)getStatus{
    return finished;
}
-(NSArray*)getChapterList{
    return chapterList;
}
-(NSInteger)getNumChapters{
    return chapterTotal;
}
-(NSImage*)getCover{
    return coverArt;
}
-(NSString *)getHost{
    return host;
}
-(NSString *)getArtist{
    return artist;
}
-(NSArray*)getChapter:(int)index{
    return [chapterList objectAtIndex:index];
}
-(void)switchRead:(int)index{
    NSArray *item = [chapterList objectAtIndex:index];
    NSNumber *read = @(([item[1] integerValue]+1)%2);
    [chapterList replaceObjectAtIndex:index withObject:@[item[0],read]];
}

@end
