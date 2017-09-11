//
//  DownloadTools.m
//  networkTest
//
//  Created by KingSweet on 15/11/13.
//  Copyright © 2015年 KingSweet. All rights reserved.
//

#import "DownloadTools.h"

@interface DownloadTools ()

@property (nonatomic, strong) NSMutableDictionary *workDict;

@end

@implementation DownloadTools

/**
 *  开始下载
 *
 *  @param downloadUrl 下载地址
 *  @param targetPath  目标路径
 *  @param options     参数
 */
- (void)start:(NSString *)downloadUrl
   targetPath:(NSString *)targetPath
      options:(NSDictionary *)options
{
    if (downloadUrl.length <= 0) {
        return;
    }

    NSDictionary *responseJSON = options;

    BOOL isPost = [responseJSON[@"method"] isEqualToString:@"post"];
    NSDictionary *headDict = responseJSON[@"header"];
    NSDictionary *parasDict = nil;

    __block DownloadWork *downloadWork = [DownloadWork new];
    //将工作线程加入管理字典
    if (self.workDict == nil) {
        self.workDict = [NSMutableDictionary new];
    }
    [self.workDict setObject:downloadWork forKey:downloadUrl];

    [downloadWork downloadWithURL:downloadUrl
                           isPost:isPost
                    HTTPHeadArray:headDict
                       parasArray:parasDict
                        cachePath:targetPath
                    progressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                        //进度
                        [self makeProgressDataWithBytesRead:bytesRead
                                             totalBytesRead:totalBytesRead
                                   totalBytesExpectedToRead:totalBytesExpectedToRead
                                                downloadUrl:downloadUrl];
                    }
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              //成功
                              NSArray *arr = [downloadWork.cachePath componentsSeparatedByString:@"/"];

                              if (downloadWork.successCallback != nil) {
                                  downloadWork.successCallback(arr.lastObject);
                              }

                              [downloadWork.requestOperation cancel];
                              [self.workDict removeObjectForKey:downloadWork.dURL];
                          }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                              //失败
                              if (downloadWork.errorCallback != nil) {
                                  downloadWork.errorCallback([NSString stringWithFormat:@"%@", error.localizedDescription]);
                              }

                          }
     ];




}

/**
 *  暂停下载
 *
 *  @param downloadUrl 路径
 */
- (void)pause:(NSString *)downloadUrl
{
    DownloadWork *currentWork = [self getRequestOperationWithURL:downloadUrl];
    [currentWork pauseDownload];
}

/**
 *  恢复下载
 *
 *  @param downloadUrl 下载路径
 *  @param targetPath  文件地址
 *  @param options     参数
 */
- (void)resume:(NSString *)downloadUrl
    targetPath:(NSString *)targetPath
       options:(id)options
{
    DownloadWork *currentWork = [self getRequestOperationWithURL:downloadUrl];
    if (currentWork != nil) {
        [currentWork resumeDownload];
    } else {
        [self start:downloadUrl targetPath:targetPath options:options];
    }

}

/**
 *  取消下载, 删除targetPath的文件
 *
 *  @param downloadUrl 路径
 */
- (void)abort:(NSString *)downloadUrl
{
    DownloadWork *currentWork = [self getRequestOperationWithURL:downloadUrl];
    [currentWork pauseDownload];
    //停止下载
    [currentWork.requestOperation cancel];
    //删除文件
    [self deleteDownloadWorkFile:currentWork];
    //从管理字典中删除
    [self.workDict removeObjectForKey:downloadUrl];
}

/**
 *  下载进度
 *
 *  @param downloadUrl   下载地址
 *  @param progressCallback 进度回调
 */
- (void)progress:(NSString *)downloadUrl
progressCallback:(ProgressCallback)progressCallback
{
    DownloadWork *currentWork = [self getRequestOperationWithURL:downloadUrl];
    currentWork.progressCallback = progressCallback;
}

/**
 *  成功
 *
 *  @param downloadUrl   下载地址
 *  @param progressCallback 成功回调
 */
- (void)success:(NSString *)downloadUrl
successCallback:(SuccessCallback)successCallback
{
    DownloadWork *currentWork = [self getRequestOperationWithURL:downloadUrl];
    currentWork.successCallback = successCallback;
}

/**
 *  失败
 *
 *  @param downloadUrl   下载地址
 *  @param errorCallback 失败回调
 */
- (void)error:(NSString *)downloadUrl
errorCallback:(ErrorCallback)errorCallback
{
    DownloadWork *currentWork = [self getRequestOperationWithURL:downloadUrl];
    currentWork.errorCallback = errorCallback;
}


#pragma mark - Private Function
/**
 *  获得下载对象
 *
 *  @param downloadUrl 下载地址
 *
 *  @return 下载对象
 */
- (DownloadWork *)getRequestOperationWithURL:(NSString *)downloadUrl
{
    DownloadWork *o = self.workDict[downloadUrl];
    return o;
}

/**
 *  删除缓存文件
 *
 *  @param downloadWork 工作对象
 */
- (void)deleteDownloadWorkFile:(DownloadWork *)downloadWork
{
    NSString *cachePath = downloadWork.cachePath;
    if (cachePath.length == 0) {
        return;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }

}

/**
 *  下载进度回调
 *
 *  @param bytesRead                当前读取字节
 *  @param totalBytesRead           当前总共读取的字节
 *  @param totalBytesExpectedToRead 文件总大小
 */
- (void)makeProgressDataWithBytesRead:(long long)bytesRead
                       totalBytesRead:(long long)totalBytesRead
             totalBytesExpectedToRead:(long long)totalBytesExpectedToRead
                          downloadUrl:(NSString *)downloadUrl
{
    //NSLog(@"bytes=%lli,total=%lli,Expected=%lli", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    //NSLog(@"progress=%f", (double)totalBytesRead/totalBytesExpectedToRead);

    DownloadWork *currentWork = [self getRequestOperationWithURL:downloadUrl];

    //已下载大小
    long long loaded = totalBytesRead;
    //文件总大小
    long long total = totalBytesExpectedToRead;
    //当前下载速度
    double speed = currentWork.speed;
    //当前可用磁盘大小
    long long freeDisk = [self freeDiskSpace];
    //当前磁盘总大小
    long long totalDisk = [self totalDiskSpace];

    if (currentWork.progressCallback != nil) {
        currentWork.progressCallback(loaded, total, speed, freeDisk, totalDisk);
    }

}

/**
 *  磁盘总大小
 *
 *  @return long long
 */
- (long long)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [[fattributes objectForKey:NSFileSystemSize] longLongValue];
}

/**
 *  剩余磁盘大小
 *
 *  @return long long
 */
- (long long)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    return [[fattributes objectForKey:NSFileSystemFreeSize] longLongValue];
}

@end



#pragma mark - 断点下载

@interface DownloadWork ()

//计算下载速度
@property (nonatomic, assign) long long totalDownloadRead;
@property (nonatomic, strong) __block NSDate *recordTime;

@end

@implementation DownloadWork

- (void)dealloc
{
    [self.requestOperation pause];
    [self.requestOperation cancel];
}

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
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    //缓存路径
    self.cachePath = cachePath;
    //缓存长度
    long long cacheLength = [[self class] cacheFileWithPath:self.cachePath];
    self.dURL = url;

    //请求
    NSMutableURLRequest *request = [[self class] requestWithUrl:url
                                                          Range:cacheLength
                                                         isPost:isPost
                                                  HTTPHeadArray:HTTPHeadDict
                                                     parasArray:parasDict];
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];

    self.requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];



    [self.requestOperation setOutputStream:[NSOutputStream outputStreamToFileAtPath:self.cachePath append:YES]];

    //处理流
    //[self readCacheToOutStreamWithPath:self.cachePath];

    //获取进度
    self.progressBlock = progressBlock;

    __weak DownloadWork *weakSelf = self;
    [self.requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //计算下载速度
        weakSelf.totalDownloadRead += bytesRead;
        NSDate *currentDate = [NSDate date];
        double intervalTime = [currentDate timeIntervalSinceDate:weakSelf.recordTime];
        if (intervalTime >= 1) {
            weakSelf.speed = self.totalDownloadRead / intervalTime;
            weakSelf.totalDownloadRead = 0;
            weakSelf.recordTime = currentDate;
        }
        //进度回调
        progressBlock(bytesRead, totalBytesRead + cacheLength, totalBytesExpectedToRead + cacheLength);
    }];

    //设置回调
    [self.requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        success(operation, responseObject);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        failure(operation, error);
    }];

    //初始化下载计量
    self.totalDownloadRead = 0;
    self.recordTime = [NSDate date];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.requestOperation start];
    });

}

/**
 *  暂停下载
 */
- (void)pauseDownload
{
    [self.requestOperation pause];
}

/**
 *  恢复下载
 */
- (void)resumeDownload
{
    [self.requestOperation resume];
}


#pragma mark - Private Function
/**
 *  获取本地缓存大小
 *
 *  @param path 缓存路径
 *
 *  @return 缓存大小
 */
+ (long long)cacheFileWithPath:(NSString*)path
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *contentData = [fileHandle readDataToEndOfFile];
    return contentData ? contentData.length : 0;
}

/**
 *  获得请求对象
 *
 *  @param url        地址
 *  @param length     长度
 *  @param isPost     是否是POST请求
 *  @param parasArray 参数数组
 *
 *  @return 请求对象
 */
+ (NSMutableURLRequest*)requestWithUrl:(id)url
                                 Range:(long long)length
                                isPost:(BOOL)isPost
                         HTTPHeadArray:(NSDictionary *)HTTPHeadDict
                            parasArray:(NSDictionary *)parasDict
{
    NSURL *requestURL = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:requestURL
                                    cachePolicy:NSURLRequestReloadIgnoringCacheData
                                    timeoutInterval:60];//超时间隔

    //请求体
    if (isPost) {
        request.HTTPMethod = @"POST";
        if (parasDict.count > 0) {
            NSData *data = [NSJSONSerialization dataWithJSONObject:parasDict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
            request.HTTPBody = data;
        }

    }

    //请求头
    if (HTTPHeadDict.count > 0) {
        for (NSString *key in HTTPHeadDict) {
            [request setValue:HTTPHeadDict[key] forHTTPHeaderField:key];
        }
    }
    if (length) {
        [request setValue:[NSString stringWithFormat:@"bytes=%lld-",length] forHTTPHeaderField:@"Range"];
    }

    //NSLog(@"request.head = %@",request.allHTTPHeaderFields);

    return request;
}

/**
 *  读取本地缓存入流
 *
 *  @param path 路径
 */
- (void)readCacheToOutStreamWithPath:(NSString*)path
{
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *currentData = [fh readDataToEndOfFile];

    if (currentData.length) {
        //打开流，写入data
        [self.requestOperation.outputStream open];

        NSInteger bytesWritten;
        NSInteger bytesWrittenSoFar;

        NSInteger  dataLength = [currentData length];
        const uint8_t *dataBytes  = [currentData bytes];

        bytesWrittenSoFar = 0;
        do {
            bytesWritten = [self.requestOperation.outputStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
            assert(bytesWritten != 0);
            if (bytesWritten == -1) {
                break;
            } else {
                bytesWrittenSoFar += bytesWritten;
            }
        } while (bytesWrittenSoFar != dataLength);

    }
}


@end
