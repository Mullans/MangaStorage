//
//  Genre.h
//  MangaStorage
//
//  Created by Sean Mullan on 3/24/15.
//  Copyright (c) 2015 SilentLupin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Genre : NSManagedObject

@property (nonatomic, retain) NSString * title;

@end
