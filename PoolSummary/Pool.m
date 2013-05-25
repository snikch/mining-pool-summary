//
//  Pool.m
//  PoolSummary
//
//  Created by Mal Curtis on 25/05/13.
//  Copyright (c) 2013 Mal Curtis. All rights reserved.
//

#import "Pool.h"
#import <AFNetworking/AFNetworking.h>

@implementation Pool

- (id)initWithName:(NSString *)name URL:(NSString *)url
{
    self = [super init];
    if (self) {
        _loaded = false;
        _loading = false;
        _name = name;
        _url = [NSURL URLWithString:url];
    }
    return self;
}

-(NSString*)refreshing{
    NSString *refreshing = @"";
    if(_loading && _loaded){
        refreshing = @" (refreshing…)";
    }
    return refreshing;
}

-(NSString*)title{
    return [NSString stringWithFormat:@"%@%@\n%@", [self name], [self refreshing], [self info]];
}

-(void)load{
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"Loaded pool info for %@: %@", _name, JSON);
        _data = JSON;
        _loaded = true;
        _loading = false;
        if(_delegate != nil){
            [_delegate poolDataDidChange:self];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Failed to load pool %@", [error description]);
        _loading = false;
    }];
    _loading = true;
    if(_delegate != nil){
        [_delegate poolDataDidChange:self];
    }
    [operation start];
}

-(int)hashRate{
    int rate = 0;
    NSDictionary *workers = (NSDictionary*)[_data valueForKey:@"workers"];
    if(workers != nil){
        for (NSString * workerName in workers) {
            NSDictionary *workerData = [workers valueForKey:workerName];
            rate += [[workerData valueForKey:@"hashrate"] integerValue];
        }
    }
    
    return rate;
}

-(NSString*)info{
    if(_loaded){
        return [NSString stringWithFormat:@"Confirmed: %@\nRound Estimate: %@\nPaid Out: %@\nHash Rate: %i kh/s",
                [_data valueForKey:@"confirmed_rewards"],
                [_data valueForKey:@"round_estimate"],
                [_data valueForKey:@"payout_history"],
                [self hashRate]
                ];
    }else{
        return @"loading…";
    }
}

@end
