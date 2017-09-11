//
//  DownloadTools.h
//  networkTest
//
//  Created by KingSweet on 15/11/13.
//  Copyright © 2015年 KingSweet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

/**
 *  下载进度回调
 *
 *  @param loaded    已下载大小
 *  @param total     文件总大小
 *  @param speed     当前下载速度(byte/s)
 *  @param freeDisk  当前可用磁盘大小(byte)
 *  @param totalDisk 磁盘总大小(byte)
 */
typedef void(^ProgressCallback)(long long loaded, long long total, double speed, long long freeDisk, long long totalDisk);

/**
 *  下载成功
 *
 *  @param targetFileName 目标文件名
 */
typedef void(^SuccessCallback)(NSString *targetFileName);

/**
 *  下载失败
 *
 *  @param error 错误代码
 */
typedef void(^ErrorCallback)(NSString *error);

@interface DownloadTools : NSObject

/**
 *  开始下载
 *
 *  @param downloadUrl 下载地址
 *  @param targetPath  目标路径
 *  @param options     参数
 */
- (void)start:(NSString *)downloadUrl
   targetPath:(NSString *)targetPath
      options:(NSDictionary *)options;

/**
 *  暂停下载
 *
 *  @param downloadUrl 路径
 */
- (void)pause:(NSString *)downloadUrl;

/**
 *  恢复下载
 *
 *  @param downloadUrl 下载路径
 *  @param targetPath  文件地址
 *  @param options     参数
 */
- (void)resume:(NSString *)downloadUrl
    targetPath:(NSString *)targetPath
       options:(id)options;

/**
 *  取消下载, 删除targetPath的文件
 *
 *  @param downloadUrl 路径
 */
- (void)abort:(NSString *)downloadUrl;

/**
 *  下载进度
 *
 *  @param downloadUrl   下载地址
 *  @param progressCallback 进度回调
 */
- (void)progress:(NSString *)downloadUrl
progressCallback:(ProgressCallback)progressCallback;

/**
 *  成功
 *
 *  @param downloadUrl   下载地址
 *  @param progressCallback 成功回调
 */
- (void)success:(NSString *)downloadUrl
successCallback:(SuccessCallback)successCallback;

/**
 *  失败
 *
 *  @param downloadUrl   下载地址
 *  @param errorCallback 失败回调
 */
- (void)error:(NSString *)downloadUrl
errorCallback:(ErrorCallback)errorCallback;

@end






#pragma mark - 断点下载
@interface DownloadWork : NSObject

@property (nonatomic, strong) ProgressCallback progressCallback;
@property (nonatomic, strong) SuccessCallback successCallback;
@property (nonatomic, strong) ErrorCallback errorCallback;

@property (nonatomic, copy) NSString *cachePath;//文件缓存路径
@property (nonatomic, copy) NSString *dURL;//下载路径
@property (nonatomic , strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic , copy) void(^progressBlock)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

@property (nonatomic, assign) double speed;

/**
 *  开始断点续传
 *
 *  @param url           地址
 *  @param isPost        是否是POST请求
 *  @param HTTPHeadArray 请求头列表
 *  @param parasArray    参数列表
 *  @param cachePath     缓存路径
 *  @param progressBlock 进度回调
 *  @param success       成功
 *  @param failure       失败
 */
- (void)downloadWithURL:(NSString *)url
                 isPost:(BOOL)isPost
          HTTPHeadArray:(NSDictionary *)HTTPHeadDict
             parasArray:(NSDictionary *)parasDict
              cachePath:(NSString *)cachePath
          progressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

/**
 *  暂停下载
 */
- (void)pauseDownload;

/**
 *  恢复下载
 */
- (void)resumeDownload;


@end
#pragma mark - End


