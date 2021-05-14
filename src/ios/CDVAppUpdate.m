//
//  CDVAppUpdate
//
//  Created by Austen Zeh <developerDawg@gmail.com> on 2020-03-16
//
#import "CDVAppUpdate.h"
#import <objc/runtime.h>
#import <Cordova/CDVViewController.h>

static NSString *const TAG = @"CDVAppUpdate";

@implementation CDVAppUpdate

-(BOOL) needsUpdate:(CDVInvokedUrlCommand*)command
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString* appIdArg = nil;
    NSString* currentVersionArg = nil;
    if ([command.arguments count] > 0) {
        if ([[command.arguments objectAtIndex:0] isKindOfClass:[NSString class]]) {
            appIdArg = [command.arguments objectAtIndex:0];
        }
        if ([[command.arguments objectAtIndex:1] isKindOfClass:[NSString class]]) {
            currentVersionArg = [command.arguments objectAtIndex:1];
        }
    }
    NSString* appID = appIdArg == nil ? infoDictionary[@"CFBundleIdentifier"] : appIdArg;
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?country=ru&bundleId=%@", appID]];
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSDictionary* lookup = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSMutableDictionary *resultObj = [[NSMutableDictionary alloc]initWithCapacity:10];
    NSNumber* update_avail = [NSNumber numberWithInt:0];
    NSString* appStoreVersion = @"";
    NSString* appStoreUr = @"";
    NSString* currentVersion = currentVersionArg == nil ? infoDictionary[@"CFBundleShortVersionString"] : currentVersionArg;

    NSLog(@"%@ Checking for app update", TAG);
    if ([lookup[@"resultCount"] integerValue] == 1) {
        appStoreVersion = lookup[@"results"][0][@"version"];
        appStoreUrl = lookup[@"results"][0][@"trackViewUrl"];
        NSArray* appStoreVersionArr = [appStoreVersion componentsSeparatedByString:@"."];
        NSArray* currentVersionArr = [currentVersion componentsSeparatedByString:@"."];

        for (int idx=0; idx<[appStoreVersionArr count]; idx++) {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            NSNumber* appStoreVersionNumber = [f numberFromString:[appStoreVersionArr objectAtIndex:idx]];
            NSNumber* currentVersionNumber = [f numberFromString:[currentVersionArr objectAtIndex:idx]];

            if ([currentVersionNumber compare:appStoreVersionNumber] == NSOrderedDescending) {
                NSLog(@"%@ Already has newer version [%@ < %@]", TAG, appStoreVersion, currentVersion);
                update_avail = [NSNumber numberWithInt:2];
                break;
            }
            if ([currentVersionNumber compare:appStoreVersionNumber] == NSOrderedAscending) {
                NSLog(@"%@ Need to update [%@ > %@]", TAG, appStoreVersion, currentVersion);
                update_avail = [NSNumber numberWithInt:1];
                break;
            }
        }
    } else {
        update_avail = [NSNumber numberWithInt:3];
    }

    [resultObj setObject:update_avail forKey:@"updateAvailable"];
    [resultObj setObject:currentVersion forKey:@"currentVersion"];
    [resultObj setObject:appID forKey:@"appId"];
    [resultObj setObject:appStoreVersion forKey:@"storeVersion"];
    [resultObj setObject:appStoreUrl forKey:@"storeUrl"];

    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultObj];
    [result setKeepCallbackAsBool:YES];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

@end
