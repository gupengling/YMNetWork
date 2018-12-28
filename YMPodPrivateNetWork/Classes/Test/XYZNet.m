//
//  XYZNet.m
//  YiMiApp
//
//  Created by xieyan on 16/5/12.
//  Copyright © 2016年 xieyan. All rights reserved.
//

//static const DDLogLevel ddLogLevel = DDLogLevelVerbose;


#import "XYZNet.h"
#import "MBProgressHUD.h"
#import "DeepCopy.h"
#import "NSDictionary+YMJSON.h"

@implementation XYZNet
+(instancetype)instance{
    static XYZNet* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/json",@"text/javascript",@"application/x-javascript",@"text/plain",nil];
//        manager.securityPolicy = [self customSecurityPolicy];
    });
    return manager;
}

/**** SSL Pinning ****/
+(AFSecurityPolicy*)customSecurityPolicy{
    //    // 安全验证https
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode: AFSSLPinningModeCertificate];
    NSString *certificatePath = [[NSBundle mainBundle] pathForResource:@"YIMICertificate" ofType:@"cer"];
    NSData *certificateData = [NSData dataWithContentsOfFile:certificatePath];
    
    NSSet *certificateSet  = [[NSSet alloc] initWithObjects:certificateData, nil];
    [securityPolicy setPinnedCertificates:certificateSet];
    //是否允许不信任的证书（证书无效、证书时间过期）通过验证 ，默认为NO
    //    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    return securityPolicy;
}
- (void)resultGetResponse:(NSURLSessionDataTask *)dataTask
                    Parma:(NSDictionary* )parma
              HeaderParma:(NSDictionary* )headerParma
                    error:(NSError *)error
                 response:(NSURLResponse * __unused)response
                      url:(NSString*)url
           responseObject:(id)responseObject
                allString:(BOOL)allString
                cacheName:(NSString *)cachename success:(void (^)(NSURLSessionDataTask *task, id responseObject, int code))success
                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    if (error) {
        NSLog(@"\n接口:\n%@入参:\n%@\nheader:%@\n出参:\n%@",url,parma,headerParma,error);
        if (failure) {
            failure(dataTask, error);
        }
        NSMutableDictionary* repdic = @{@"url":url}.mutableCopy;
        if (response) {
            repdic[@"response"] = response.description;
        }
        if (parma) {
            repdic[@"parma"] = parma;
        }
        if (self.xyzDelegate && [self.xyzDelegate respondsToSelector:@selector(responseDataFailed:url:)]) {
            [self.xyzDelegate responseDataFailed:repdic url:url];
        }
    } else {

        if (success) {

            NSLog(@"\n接口:\n%@入参:%@\n出参:\n%@",url,parma,responseObject);

            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                int code = 0;
                // 兼容性处理 2.3以前返回的都是NSNumber类型 2.4以后是字符串.
                if ([responseObject[@"result"] isKindOfClass:[NSNumber class]]) { // 2.3版本处理
                    if (responseObject[@"result"]) {
                        code =[responseObject[@"result"] intValue];
                    }
                    if (responseObject[@"state"]) {
                        code =[responseObject[@"state"] intValue];
                    }
                    
                } else if ([responseObject[@"result"] isKindOfClass:[NSString class]]){ // 2.4 版本处理
                    if ([responseObject[@"result"] isEqualToString:@"success"]) {
                        code = 1;
                    }else {
                        code = [responseObject[@"code"] intValue];
                        if (self.xyzDelegate && [self.xyzDelegate respondsToSelector:@selector(checkDataForResponse:url:)]) {
                            [self.xyzDelegate checkDataForResponse:responseObject url:url];
                        }
                    }
                }
                if (code != 93) {
                    success(dataTask,[((NSDictionary*)responseObject) MutableDeepCopyToString:allString] ,code);
                }else {
                    
                }
                
            }else{
                success(dataTask,responseObject,-1);
                //                                       NSAssert(NO, @"XYZNet.m    不应该  参数返回不是json");
            }
            if (self.xyzDelegate && [self.xyzDelegate respondsToSelector:@selector(responseDataSuccess:url:)]) {
                [self.xyzDelegate responseDataSuccess:responseObject url:url];
            }
            
        }
    }
}
/**POST网络请求--上传下载*/
-(NSURLSessionDataTask* )POSTUrl:(NSString*)url
                                    Parma:(NSDictionary* )parma
                                BodyParma:(id )bodyParma
                              HeaderParma:(NSDictionary* )headerParma
                           uploadProgress:( void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                         downloadProgress:( void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                  success:(void (^)(NSURLSessionDataTask *task, id responseObject, int code))success
                                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                       hudInView:(UIView*)view
                       allString:(BOOL)allString
                       cacheName:(NSString*)cachename{
    if (!url) {
        NSLog(@"%@",parma);
        return nil;
    }
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = nil;
    
    if (bodyParma) {
        if ([bodyParma isKindOfClass:[UIImage class]]) {
            NSData* data = UIImageJPEGRepresentation(bodyParma, 0.8);
            request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:parma constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                [formData appendPartWithFileData:data name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            } error:&serializationError];
        }else if ([bodyParma isKindOfClass:[NSDictionary class]]) {
            request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:parma error:&serializationError];

            NSString* bodyJson = [NSDictionary jsonStringWithDictionary:bodyParma];
//            NSString* bodyJson = [bodyParma JSONString];

            request.HTTPBody = [bodyJson dataUsingEncoding:NSUTF8StringEncoding];
            
        }else if ([bodyParma isKindOfClass:[NSString class]]) {
            request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:parma error:&serializationError];
            request.HTTPBody = [bodyParma dataUsingEncoding:NSUTF8StringEncoding];
        }else if ([bodyParma isKindOfClass:[NSData class]]){
            request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:parma error:&serializationError];
            request.HTTPBody = bodyParma;
        }
    }else{
        request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:parma error:&serializationError];
    }
    if (!request) {
        return nil;
    }
    if (headerParma) {
        [headerParma enumerateKeysAndObjectsUsingBlock:^(id   key, id   obj, BOOL *  stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    if (view) {
        [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:uploadProgressBlock
                        downloadProgress:downloadProgressBlock
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (view) {
                               [MBProgressHUD hideHUDForView:view animated:YES];
                           }
                           [self  resultGetResponse:dataTask Parma:parma HeaderParma:headerParma error:error response:response url:url responseObject:responseObject allString:allString cacheName:cachename success:success failure:failure];
                       }];
    [dataTask resume];
    return dataTask;
}

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view
     cacheName:(NSString*)name
     allString:(BOOL)allString{
    
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:allString  cacheName:name];
}

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view
     cacheName:(NSString*)name{
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:NO  cacheName:name];
}

/**POST网络请求*/
-(NSURLSessionDataTask* )POSTUrl:(NSString *)url
                                    Parma:(NSDictionary *)parma
                                BodyParma:(NSDictionary *)bodyParma
                              HeaderParma:(NSDictionary *)headerParma
                                  success:(void (^ )( NSURLSessionDataTask *  task, id responseObject,int code))success
                                  failure:(void (^ )(NSURLSessionDataTask *  task, NSError *  error))failure
                                hudInView:(UIView* )view{
    return [self POSTUrl:url Parma:parma BodyParma:bodyParma HeaderParma:headerParma uploadProgress:nil downloadProgress:nil success:success failure:failure hudInView:view allString:YES cacheName:nil];
}


-(void)POSTUrl:(NSString *)url
   headerPsrma:(NSDictionary *)headerPsrma
         parma:(NSDictionary *)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView *)view{
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:headerPsrma uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:NO  cacheName:nil];
}

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view {
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:NO cacheName:nil];
}

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view
     allString:(BOOL)allString{
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:allString cacheName:nil];
}

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed {
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:nil allString:NO cacheName:nil];
}

- (void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     allString:(BOOL)allString {
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:nil allString:allString cacheName:nil];
}

- (void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response {
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:nil hudInView:nil allString:NO cacheName:nil];
}

- (void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
     allString:(BOOL)allString {
    [self POSTUrl:url Parma:parma BodyParma:nil HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:nil hudInView:nil allString:allString cacheName:nil];
}

/**GET网络请求--下载*/
-(NSURLSessionDataTask* )GETUrl:( NSString* )url
                                   Parma:(NSDictionary* )parma
                             HeaderParma:(NSDictionary* )headerParma
                        downloadProgress:( void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                 success:(void (^)(NSURLSessionDataTask *task, id responseObject, int code))success
                                 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
                      hudInView:(UIView*)view
                      allString:(BOOL)allString
                      cacheName:(NSString*)cachename{
    
//    // 获取缓存
//    NSDictionary* cacheDic = [XYZStorage getCachedDic:cachename];
//    if (cacheDic) {
//        if (success) {
//            int code = 0;
//            if (cacheDic[@"result"]) {
//                code =[cacheDic[@"result"] intValue];
//            }
//            if (cacheDic[@"state"]) {
//                code =[cacheDic[@"state"] intValue];
//            }
//            success(nil,cacheDic,code);
//        }
//    }

    // NSMutableURLRequest
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:url relativeToURL:self.baseURL] absoluteString] parameters:parma error:&serializationError];
    if (headerParma) {
        [headerParma enumerateKeysAndObjectsUsingBlock:^(id   key, id   obj, BOOL *  stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        return nil;
    }
    
    // 加载菊花
    if (view) {
        [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:nil
                        downloadProgress:downloadProgressBlock
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (view) {
                               [MBProgressHUD hideHUDForView:view animated:YES];
                           }
                           [self  resultGetResponse:dataTask Parma:parma HeaderParma:headerParma error:error response:response url:url responseObject:responseObject allString:allString cacheName:cachename success:success failure:failure];
                       }];
    [dataTask resume];
    return dataTask;
}


- (void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view
    cacheName:(NSString*)name
    allString:(BOOL)allString{
    [self GETUrl:url Parma:parma HeaderParma:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:allString cacheName:name];
}


- (void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view
    cacheName:(NSString*)name {
    [self GETUrl:url Parma:parma HeaderParma:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:NO cacheName:name];
}

- (void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view
    allSrting:(BOOL)allString {
    [self GETUrl:url Parma:parma HeaderParma:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:allString cacheName:nil];
}


-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view {
    [self GETUrl:url Parma:parma HeaderParma:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:NO cacheName:nil];
}

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
  HeaderParma:(NSDictionary*)headerParma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view {
    [self GETUrl:url Parma:parma HeaderParma:headerParma downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:view allString:NO cacheName:nil];
}
-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
  HeaderParma:(NSDictionary*)headerParma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed {
    [self GETUrl:url Parma:parma HeaderParma:headerParma downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:nil allString:NO cacheName:nil];
}

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed {
    [self GETUrl:url Parma:parma HeaderParma:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failed(error);
    } hudInView:nil allString:NO cacheName:nil];
}

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response{
    [self GETUrl:url Parma:parma HeaderParma:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, id responseObject, int code) {
        response(responseObject,code);
    } failure:nil hudInView:nil allString:NO cacheName:nil];
}

-(void)upLoadImage:(UIImage*)image
                      url:(NSString*)url
                    parma:(NSDictionary*)parma
                 response:(XYZHttpResponse)responseBlock
                   failed:(XYZHttpFailed)failed
                hudInView:(UIView*)view{
    
    if (view) {
        [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:parma constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //        [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:@"file" fileName:@"file.pdf" mimeType:@"application/pdf" error:nil];
        NSData* data = UIImageJPEGRepresentation(image, 0.9);
        [formData appendPartWithFileData:data name:@"file" fileName:@"file.jpg" mimeType:@"image/jpeg"];
    } error:nil];//application/pdf   image/png
    request.timeoutInterval = 600;
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:nil
                        downloadProgress:nil
                       completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                           if (view) {
                               [MBProgressHUD hideHUDForView:view animated:YES];
                           }
                           if (error) {
                               if (failed) {
                                   failed(error.description);
                               }
                           } else {
                               if (responseBlock) {
                                   if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                       if (response) {
                                           int code = [responseObject[@"state"] intValue];
                                           responseBlock(responseObject,code);
                                       }
                                   }else{
                                       responseBlock(responseObject,-1);
                                       NSAssert(NO, @"XYZNet.m    不应该  参数返回不是json");
                                   }
                               }
                           }
                       }];
    [dataTask resume];
}


- (void)downLoadFile:(NSString*)Url
             toPath:(NSURL*)pathUrl
           progress:(void(^)(CGFloat progress))progress
           complete:(void(^)(NSURL* fileUrl))complete
              failed:(void(^)(void))failed {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:Url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        CGFloat progresssss = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
        if (progress) {
            progress(progresssss);
        }
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        if (pathUrl) {
            return pathUrl;
        }else{
            NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
        }
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if (error) {
            NSLog(@"下载失败信息:\n%@",error);
            if (failed) {
                failed();
            }
        }else{
            if (complete) {
                complete(filePath);
            }
        }
    }];
   
    [downloadTask resume];
}
@end

@implementation XYZNet (ProtectedMethod)
- (void)checkDataForResponse:(id)responseObject {

}

@end
