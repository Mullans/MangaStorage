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
@dynamic genres;
@dynamic rating;
@dynamic missingChapters;

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
        
        
        NSString *genreSearchString = @"(<span class=\"genretags\">)(.+?)(</span>)";
        NSRegularExpression *genreRegex = [NSRegularExpression regularExpressionWithPattern:genreSearchString options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray* genreMatches = [genreRegex matchesInString:html options:0 range:NSMakeRange(0, html.length)];
        NSMutableArray *genres = [[NSMutableArray alloc]initWithCapacity:10];
        for (NSTextCheckingResult* match in genreMatches){
            NSRange genreRange = match.range;
            genreRange.location+=24;
            genreRange.length-=31;
            Genre *newGenre = (Genre*)[NSEntityDescription insertNewObjectForEntityForName:@"Genre" inManagedObjectContext:context];
            NSLog(@"%@",[html substringWithRange:genreRange]);
            newGenre.title = [html substringWithRange:genreRange];
            [genres addObject:newGenre];
        }
        
        
        
        tableSearchString = @"(<table id=\"listing\">)(.*?)(</table>)";
        NSRegularExpression *tableRegex = [NSRegularExpression regularExpressionWithPattern:tableSearchString
                                                                                    options:NSRegularExpressionDotMatchesLineSeparators
                                                                                      error:nil];
        NSRange tableRange = [tableRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
        tableRange.location+=20;
        tableRange.length-=7;
        NSArray *tableArray = [[html substringWithRange:tableRange] componentsSeparatedByString:@"<tr>"];
        NSMutableArray *chapterArray = [[NSMutableArray alloc]initWithCapacity:10];
        //regex for title
        NSRegularExpression *chapterFinder = [NSRegularExpression regularExpressionWithPattern:@"( : )(.*?)(</td>)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
        //regex for url
        NSRegularExpression *chapterURLFinder = [NSRegularExpression regularExpressionWithPattern:@"(<a href=\")(.*?)(\">)"
                                                                                          options:NSRegularExpressionCaseInsensitive
                                                                                            error:nil];
        //regex for date
        NSRegularExpression *chapterDateFinder = [NSRegularExpression regularExpressionWithPattern:@"[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        
        //regex for index (mangareader only)
        NSRegularExpression *chapterIndexFinder = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+?)(</a> :)" options:NSRegularExpressionCaseInsensitive error:nil];
        
        tableArray = [tableArray subarrayWithRange:NSMakeRange(1,tableArray.count-1)];
        float chapterCount = 0.0;
        for(NSString *item in tableArray){
            NSRange chapterRange = [chapterFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterRange.location+=3;
            chapterRange.length-=8;
            NSString *chapterTitle = [item substringWithRange:chapterRange];
            
            NSRange chapterURLRange = [chapterURLFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterURLRange.location+=9;
            chapterURLRange.length-=11;
            NSString *chapterURLString = [item substringWithRange:chapterURLRange];
            NSURL *chapterURL = [[NSURL alloc]initWithString:[@"http://www.mangareader.net" stringByAppendingString:chapterURLString]];
            
            NSRange chapterIndexRange = [chapterIndexFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterIndexRange.length-=6;
            NSNumber *chapterIndex = [NSNumber numberWithFloat:[[item substringWithRange:chapterIndexRange]floatValue]];
            
            NSRange dateRange = [chapterDateFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            [dateFormater setDateFormat:@"MM/dd/yyyy"];
            NSDate *chapterDate = [dateFormater dateFromString:[item substringWithRange:dateRange]];
            
            if([chapterTitle isEqualToString:@""]){
                NSRegularExpression *chapterFinder2 = [NSRegularExpression regularExpressionWithPattern:@"(\">)(.*?)(</a>)"
                                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                                  error:nil];
                chapterRange = [chapterFinder2 rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
                chapterRange.location+=2;
                chapterRange.length-=6;
                chapterTitle = [item substringWithRange:chapterRange];
            }
            
            Chapter *newChapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:context];
            if([chapterTitle isEqualToString:@""]){
                chapterTitle = @"N/A";
            }
            newChapter.title = chapterTitle;
            newChapter.status = [NSNumber numberWithBool:NO];
            newChapter.manga = self;
            newChapter.chapterURL = [chapterURL absoluteString];
            newChapter.index = chapterIndex;//[NSNumber numberWithFloat:chapterIndex];
            newChapter.addDate = chapterDate;
            [chapterArray addObject:newChapter];
            chapterCount++;
            
        }
        self.chapters = [[NSSet alloc]initWithArray:chapterArray];
        self.chapterTotal = [NSNumber numberWithInt:chapterCount];
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

-(void)updateChapters:context{
    //use the addChaptersObject and addChapters methods?
    //set up indices using +.0001 if it already exists, then iterate and recode indices
    NSString *html = [NSString stringWithContentsOfURL:[[NSURL alloc]initWithString:self.mangaURL] encoding:NSUTF8StringEncoding error:nil];

    if ([self.host isEqualTo:@"MangaReader.net"]){
        //regex for chapter table
        NSRegularExpression *tableRegex = [NSRegularExpression regularExpressionWithPattern:@"(<table id=\"listing\">)(.*?)(</table>)"
                                                                                    options:NSRegularExpressionDotMatchesLineSeparators
                                                                                      error:nil];
        NSRange tableRange = [tableRegex rangeOfFirstMatchInString:html options:NSMatchingReportProgress range:NSMakeRange(0, html.length)];
        tableRange.location+=20;
        tableRange.length-=7;
        NSArray *tableArray = [[html substringWithRange:tableRange] componentsSeparatedByString:@"<tr>"];
        NSMutableArray *chapterArray = [[NSMutableArray alloc]initWithCapacity:10];
        //regex for title
        NSRegularExpression *chapterFinder = [NSRegularExpression regularExpressionWithPattern:@"( : )(.*?)(</td>)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
        //regex for url
        NSRegularExpression *chapterURLFinder = [NSRegularExpression regularExpressionWithPattern:@"(<a href=\")(.*?)(\">)"
                                                                                          options:NSRegularExpressionCaseInsensitive
                                                                                            error:nil];
        //regex for date
        NSRegularExpression *chapterDateFinder = [NSRegularExpression regularExpressionWithPattern:@"[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]" options:NSRegularExpressionDotMatchesLineSeparators error:nil];
        
        //regex for index (mangareader only)
        NSRegularExpression *chapterIndexFinder = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+?)(</a> :)" options:NSRegularExpressionCaseInsensitive error:nil];
        
        tableArray = [tableArray subarrayWithRange:NSMakeRange(1,tableArray.count-1)];
        float chapterCount = 0.0;
        for(NSString *item in tableArray){
            NSRange chapterRange = [chapterFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterRange.location+=3;
            chapterRange.length-=8;
            NSString *chapterTitle = [item substringWithRange:chapterRange];
            
            NSRange chapterURLRange = [chapterURLFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterURLRange.location+=9;
            chapterURLRange.length-=11;
            NSString *chapterURLString = [item substringWithRange:chapterURLRange];
            NSURL *chapterURL = [[NSURL alloc]initWithString:[@"http://www.mangareader.net" stringByAppendingString:chapterURLString]];
            
            NSRange chapterIndexRange = [chapterIndexFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            chapterIndexRange.length-=6;
            NSNumber *chapterIndex = [NSNumber numberWithFloat:[[item substringWithRange:chapterIndexRange]floatValue]];
            
            NSRange dateRange = [chapterDateFinder rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
            NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
            [dateFormater setDateFormat:@"MM/dd/yyyy"];
            NSDate *chapterDate = [dateFormater dateFromString:[item substringWithRange:dateRange]];
            
            if([chapterTitle isEqualToString:@""]){
                NSRegularExpression *chapterFinder2 = [NSRegularExpression regularExpressionWithPattern:@"(\">)(.*?)(</a>)"
                                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                                  error:nil];
                chapterRange = [chapterFinder2 rangeOfFirstMatchInString:item options:NSMatchingReportProgress range:NSMakeRange(0,item.length)];
                chapterRange.location+=2;
                chapterRange.length-=6;
                chapterTitle = [item substringWithRange:chapterRange];
            }

//            NSLog(@"%@",chapterTitle);
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"chapterURL == %@",chapterURL];
            NSSet* chapterCheck = [self.chapters filteredSetUsingPredicate:predicate];
            NSUInteger setCount = [chapterCheck count];
            if (setCount>1){
                NSLog(@"Error, multiple chapters with the same URL");
            }
            if(setCount == 0){
                Chapter *newChapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:context];
                newChapter.title = chapterTitle;
                newChapter.status = [NSNumber numberWithBool:NO];
                newChapter.manga = self;
                newChapter.chapterURL = [chapterURL absoluteString];
                newChapter.index = chapterIndex;
                newChapter.addDate = chapterDate;
                [self addChaptersObject:newChapter];
                chapterCount+=1;
            }else{
                //chapter already exists
                // remove all but the continue when done testing
                Chapter *newChapter = (Chapter*)[NSEntityDescription insertNewObjectForEntityForName:@"Chapter" inManagedObjectContext:context];
                newChapter.title = @"temp";
                newChapter.status = [NSNumber numberWithBool:NO];
                newChapter.manga = self;
                newChapter.chapterURL = [chapterURL absoluteString];
                newChapter.index = chapterIndex;
                newChapter.addDate = chapterDate;
                [self addChaptersObject:newChapter];
                continue;
            }
            //use this when checking on updated chapters in the middle of lists
//            NSLog(@"%f chapterIndex, %li setCount",chapterIndex,setCount);
            
        }
    }
}

@end
