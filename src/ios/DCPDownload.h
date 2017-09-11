#import <Cordova/CDV.h>
#import "DownloadTools.h"

@interface DCPDownload : CDVPlugin

//Description:开始下载...
- (void) start:(CDVInvokedUrlCommand*)command;
//Description:暂停下载...
- (void) pause:(CDVInvokedUrlCommand*)command;
//Description:终止下载...
- (void) abort:(CDVInvokedUrlCommand*)command;
//Description:下载进度...
- (void) progress:(CDVInvokedUrlCommand*)command;


@property (nonatomic, strong) DownloadTools *downloadTools;


@end