//
//  AppDelegate.m
//  PoolSummary
//
//  Created by Mal Curtis on 25/05/13.
//  Copyright (c) 2013 Mal Curtis. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworking.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSDictionary *poolInfo = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Pools"];
    pools = [NSMutableArray arrayWithCapacity:[poolInfo count]];
    
    for (NSString *name in poolInfo) {
        Pool *pool = [[Pool alloc] initWithName:name URL:[poolInfo valueForKey:name]];
        [pools addObject:pool];
    }
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:menu];
    [statusItem setHighlightMode:NO];
    [statusItem setImage:[NSImage imageNamed:@"ltc-ring"]];
    [statusItem setAlternateImage:[NSImage imageNamed:@"ltc-ring-white"]];
    
    [menu removeAllItems];
    [menu setDelegate:self];
    
    for (Pool *pool in pools) {
        NSMenuItem *item = [menu addItemWithTitle:pool.name action:@selector(didSelectMenuItem:) keyEquivalent:@""];
        [item setEnabled:YES];
        [item setRepresentedObject:pool];
        [pool setDelegate:self];
        [self renderItem:item highlighted:[item isEqualTo:[menu highlightedItem]]];
    }
    
    [self loadPools];
}

-(void) renderItem:(NSMenuItem *)item highlighted:(BOOL)highlighted{
    Pool *pool = (Pool*) item.representedObject;
    NSColor *primaryColor = highlighted ? [NSColor selectedMenuItemTextColor] : [NSColor blackColor];
    NSColor *secondaryColor = highlighted ? [NSColor selectedMenuItemTextColor] : [NSColor disabledControlTextColor];
           
    NSMutableAttributedString *attributed_label = [[NSMutableAttributedString alloc] initWithString:pool.title];
    
    // This is the system default for controls. anything else and it looks off
    NSDictionary *title_options = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Lucida Grande" size:13.0f], NSFontAttributeName, primaryColor, NSForegroundColorAttributeName, nil];
    
    //make our subtitle a different color as it is just auxillary information
    NSDictionary *info_options = [NSDictionary dictionaryWithObjectsAndKeys:secondaryColor,NSForegroundColorAttributeName,nil];
    NSDictionary *refreshing_options = [NSDictionary dictionaryWithObjectsAndKeys:secondaryColor,NSForegroundColorAttributeName,nil];
    
    // apply our color attributes to the ranges of the string they are applicable to...
    [attributed_label addAttributes:title_options range:[pool.title rangeOfString:pool.name]];
    [attributed_label addAttributes:info_options range:[pool.title rangeOfString:pool.info]];
    [attributed_label addAttributes:refreshing_options range:[pool.title rangeOfString:pool.refreshing]];
    
    // finally set our attributed to the menu item
    [item setAttributedTitle:attributed_label];
    [item setRepresentedObject:pool];
}

-(void)didSelectMenuItem:(id)selector{
    // No-op
}

-(void)loadPools{
    // Most pools don't response with the correct content type
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    for (Pool *pool in pools){
        [pool load];
    }
}

#pragma mark - Pool Delegate

-(void)poolDataDidChange:(Pool *)pool{
    NSLog(@"Pool data did change %@", pool);
    for (NSMenuItem *item in [menu itemArray]) {
        Pool *itemPool = (Pool*)[item representedObject];
        if([itemPool isEqualTo:pool]){
            [self renderItem:item highlighted:[item isEqualTo:[menu highlightedItem]]];
        }
    }
}

#pragma mark - NSMenu Delegate

-(void)menuWillOpen:(NSMenu *)referencedMenu{
    [self loadPools];
    
    [statusItem setHighlightMode:YES];
    
    NSMenuItem *item = [referencedMenu highlightedItem];
    if (item != nil) {
        // Remove the highlight, and hackily deselect it
        [self renderItem:item highlighted:NO];
        int i = (int)[menu indexOfItem:item];
        [menu removeItemAtIndex:i];
        [menu insertItem:item atIndex:i];
    }
}

-(void)menuDidClose:(NSMenu *)referencedMenu{

    [statusItem setHighlightMode:NO];
}

- (void)menu:(NSMenu *)referencedMenu willHighlightItem:(NSMenuItem *)item {
    NSMenuItem *currentItem = [referencedMenu highlightedItem];
    if (currentItem != nil) {
        [self renderItem:currentItem highlighted:NO];
    }
    [self renderItem:item highlighted:YES];
}


@end
