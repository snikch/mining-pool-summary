//
//  AppDelegate.h
//  PoolSummary
//
//  Created by Mal Curtis on 25/05/13.
//  Copyright (c) 2013 Mal Curtis. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Pool.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, PoolDelegate>{
    IBOutlet NSMenu *menu;
    NSStatusItem * statusItem;
    NSArray *pools;
}

@property (assign) IBOutlet NSWindow *window;

@end
