//
//  DFSScoreBuffer.h
//
//  Copyright © 2020 Daon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DFSScoreBufferItem : NSObject

@property (nonatomic) UIImage * image;
@property (nonatomic) float score;
@property (nonatomic) NSString * metadata;

- (id) initWithImage:(UIImage*)image score:(float)score metadata:(NSString*)data;

@end

@interface DFSScoreBuffer : NSObject {
    
    @private
        NSMutableArray *buffer;
        NSMutableSet *hashSet;
        NSInteger maxSize;
}

- (id) initWithMaxSize:(NSInteger)size;

- (void) addImage:(UIImage*)image score:(float)score;
- (void) addImage:(UIImage*)image score:(float)score metadata:(NSString*)data;

- (UIImage*) best;
- (DFSScoreBufferItem*) bestItem;
- (NSArray<UIImage*>*) all;

- (void) removeAll;

@end
