//
//  XYZNet.h
//  YiMiApp
//
//  Created by xieyan on 16/5/12.
//  Copyright © 2016年 xieyan. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#define XYZHttp [XYZNet instance]
#define NetFailed @"网络错误，请重试"

@protocol XYZNetDelegate <NSObject>

/** 2.4成功接受数据后的特殊数据处理*/
- (void)checkDataForResponse:(id)responseObject url:(NSString *)url;
- (void)responseDataSuccess:(id)responseObject url:(NSString *)url;
- (void)responseDataFailed:(id)responseObject url:(NSString *)url;

@end

typedef void(^XYZHttpResponse)(id response,int code);
typedef void(^XYZHttpFailed)(id response);
@interface XYZNet : AFHTTPSessionManager
+( instancetype)instance;
+(AFSecurityPolicy*)customSecurityPolicy;

@property (nonatomic, strong) id <XYZNetDelegate> xyzDelegate;


/**POST网络请求*/
-(NSURLSessionDataTask* )POSTUrl:( NSString* )url
                                    Parma:(NSDictionary* )parma
                                BodyParma:(id )body
                              HeaderParma:(NSDictionary* )headerParma
                                  success:(void (^ )( NSURLSessionDataTask *  task,  id    responseObject,int code))success
                                  failure:(void (^ )(NSURLSessionDataTask *  task, NSError *  error))failure
                                hudInView:(UIView* )view;
/**POST网络请求--上传下载*/
-(NSURLSessionDataTask* )POSTUrl:( NSString* )url
                                    Parma:(NSDictionary* )parma
                                BodyParma:(id )bodyParma
                              HeaderParma:(NSDictionary* )headerParma
                           uploadProgress:( void (^)(NSProgress * uploadProgress)) uploadProgressBlock
                         downloadProgress:( void (^)(NSProgress * downloadProgress)) downloadProgressBlock
                                  success:(void (^ )(NSURLSessionDataTask *  task, id   responseObject, int code))success
                                  failure:(void (^ )(NSURLSessionDataTask * task, NSError *  error))failure
                                hudInView:(UIView* )view
                                allString:(BOOL)allString
                                cacheName:(NSString*)cachename;

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view
     cacheName:(NSString*)name
     allString:(BOOL)allString;

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view
     cacheName:(NSString*)name;


-(void)POSTUrl:(NSString *)url
   headerPsrma:(NSDictionary *)headerPsrma
         parma:(NSDictionary *)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView *)view;

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view;

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     hudInview:(UIView*)view
     allString:(BOOL)allString;

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed;
-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
        failed:(XYZHttpFailed)failed
     allString:(BOOL)allString;

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response;

-(void)POSTUrl:(NSString*)url
         parma:(NSDictionary*)parma
      response:(XYZHttpResponse)response
     allString:(BOOL)allString;

/**GET网络请求--下载*/
-(NSURLSessionDataTask* )GETUrl:( NSString* )url
                       Parma:(NSDictionary* )parma
                 HeaderParma:(NSDictionary* )headerParma
            downloadProgress:( void (^)(NSProgress * downloadProgress)) downloadProgressBlock
                     success:(void (^ )(NSURLSessionDataTask *  task, id   responseObject, int code))success
                     failure:(void (^ )(NSURLSessionDataTask * task, NSError *  error))failure
                   hudInView:(UIView* )view
                  allString:(BOOL)allstring
                  cacheName:(NSString*)cachename;
/**
 *  GET 请求
 *
 *  @param url      请求地址，服务器地址不传，，，传路径  http://211.149.195.239:8000/mobile/user/consultant/64  只传 @"/mobile/user/consultant/64"  就行
 *  @param parma    参数
 *  @param response 返回值
 *  @param failed   网络错误
 *  @param view     hud 加载的地方
 *  @param headerParma     缓存数据
 */
-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
  HeaderParma:(NSDictionary*)headerParma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view;

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
  HeaderParma:(NSDictionary*)headerParma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed;

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view
    cacheName:(NSString*)name
    allString:(BOOL)allString;


-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view
    cacheName:(NSString*)name;

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view
    allSrting:(BOOL)allString;

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed
    hudInview:(UIView*)view;

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response
       failed:(XYZHttpFailed)failed;

-(void)GETUrl:(NSString*)url
        parma:(NSDictionary*)parma
     response:(XYZHttpResponse)response;

-(void)upLoadImage:(UIImage*)image
                      url:(NSString*)url
                    parma:(NSDictionary*)parma
                 response:(XYZHttpResponse)responseBlock
                   failed:(XYZHttpFailed)failed
                hudInView:(UIView*)view;

-(void)downLoadFile:(NSString*)Url
             toPath:(NSURL*)pathUrl
           progress:(void(^)(CGFloat progress))progress
           complete:(void(^)(NSURL* fileUrl))complete
             failed:(void(^)(void))failed;
@end
