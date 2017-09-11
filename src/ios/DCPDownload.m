#import "DCPDownload.h"

@implementation DCPDownload
//Description:开始下载...
- (void)start:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* downloadUrl = [command argumentAtIndex:0];
    NSString* targetPath = [command argumentAtIndex:1];
    NSDictionary* options = [command argumentAtIndex:2 withDefault:nil];
    BOOL isDebug = [options[@"debug"]  isEqualToString:@"true"];

    if(isDebug){
        NSLog(@"开始下载......");
        NSLog(@"downloadUrl: %@", downloadUrl);
        NSLog(@"targetPath: %@", targetPath);
        NSLog(@"options: %@", options);
    }

    if (self.downloadTools == nil) {
        self.downloadTools = [DownloadTools new];
    }

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"success": @"start success"}];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];


    [self.downloadTools start:downloadUrl
                   targetPath:targetPath
                      options:options];


}
//Description:暂停下载...
- (void)pause:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* downloadUrl = [command argumentAtIndex:0];
    NSDictionary* options = [command argumentAtIndex:1 withDefault:nil];
    BOOL isDebug = [options[@"debug"]  isEqualToString:@"true"];

    if(isDebug){
        NSLog(@"暂停下载......");
        NSLog(@"downloadUrl: %@", downloadUrl);
        NSLog(@"options: %@", options);
    }

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"success": @"pause success"}];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];

    [self.downloadTools pause:downloadUrl];
}
//Description:终止下载...
- (void)abort:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* downloadUrl = [command argumentAtIndex:0];
    NSDictionary* options = [command argumentAtIndex:1 withDefault:nil];
    BOOL isDebug = [options[@"debug"]  isEqualToString:@"true"];

    if(isDebug){
        NSLog(@"终止下载......");
        NSLog(@"downloadUrl: %@", downloadUrl);
        NSLog(@"options: %@", options);
    }

    CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"success": @"abort success"}];
    [self.commandDelegate sendPluginResult:result callbackId:callbackId];

    [self.downloadTools abort:downloadUrl];
}
//Description:下载进度...
- (void)progress:(CDVInvokedUrlCommand*)command
{
    NSString* callbackId = [command callbackId];
    NSString* downloadUrl = [command argumentAtIndex:0];
    NSDictionary* options = [command argumentAtIndex:1 withDefault:nil];
    BOOL isDebug = [options[@"debug"]  isEqualToString:@"true"];

    if(isDebug){
        NSLog(@"下载进度......");
        NSLog(@"downloadUrl: %@", downloadUrl);
        NSLog(@"options: %@", options);
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.downloadTools progress:downloadUrl progressCallback:^(long long loaded, long long total, double speed, long long freeDisk, long long totalDisk) {

            if(isDebug){
                NSLog(@"loaded=%lli,total=%lli,speed=%f,freeDisk=%lli,totalDisk=%lli", loaded,total,speed,freeDisk,totalDisk);
            }
            NSDictionary *dict = @{@"isCompletd":       [NSString stringWithFormat:@"%@", @"false"],
                                   @"loaded":       [NSString stringWithFormat:@"%lli", loaded],
                                   @"total":        [NSString stringWithFormat:@"%lli", total],
                                   @"speed":        [NSString stringWithFormat:@"%f", speed],
                                   @"freeDisk":     [NSString stringWithFormat:@"%lli", freeDisk],
                                   @"totalDisk":    [NSString stringWithFormat:@"%lli", totalDisk]};
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"data": dict}];
            [result setKeepCallbackAsBool:true];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];

        }];


        [self.downloadTools success:downloadUrl successCallback:^(NSString *targetFileName) {

            if(isDebug){
                NSLog(@"success = %@", targetFileName);
            }

            NSDictionary *dict = @{
                @"isCompletd":[NSString stringWithFormat:@"%@", @"true"]
            };
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"data": dict}];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];

        }];

        [self.downloadTools error:downloadUrl errorCallback:^(NSString *error) {
            if(isDebug){
                NSLog(@"error = %@", error);
            }

            NSDictionary *dict = @{
                @"error":[NSString stringWithFormat:@"%@", downloadUrl]
            };
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"data": dict}];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];

        }];

    });
}
@end
