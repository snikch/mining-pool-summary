//
//  Pool.h
//  PoolSummary
//
//  Created by Mal Curtis on 25/05/13.
//  Copyright (c) 2013 Mal Curtis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Pool;

@protocol PoolDelegate <NSObject>

-(void)poolDataDidChange:(Pool*)pool;

@end

@interface Pool : NSObject

@property (nonatomic) BOOL loaded;
@property (nonatomic) BOOL loading;
@property (strong, nonatomic) NSDictionary *data;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *refreshing;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) id delegate;

-(id)initWithName:(NSString*)name URL:(NSString *)url;
-(void)load;

@end
