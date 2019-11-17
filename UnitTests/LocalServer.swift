//
//  LocalServerWrapper.swift
//  ZabatneeUITests
//
//  Created by Omar Hassan  on 9/22/19.
//  Copyright © 2019 omar hammad. All rights reserved.
//


import Foundation

import Embassy


class LocalServer {
    enum statusCode : String {
        case s100 = "100 Continue"
        case s101 = "101 Switching Protocols"
        case s103 = "103 Early Hints"
        case s200 = "200 OK"
        case s201 = "201 Created"
        case s202 = "202 Accepted"
        case s203 = "203 Non-Authoritative Information"
        case s204 = "204 No Content"
        case s205 = "205 Reset Content"
        case s206 = "206 Partial Content"
        case s300 = "300 Multiple Choices"
        case s301 = "301 Moved Permanently"
        case s302 = "302 Found"
        case s303 = "303 See Other"
        case s304 = "304 Not Modified"
        case s307 = "307 Temporary Redirect"
        case s308 = "308 Permanent Redirect"
        case s400 = "400 Bad Request"
        case s401 = "401 Unauthorized"
        case s402 = "402 Payment Required"
        case s403 = "403 Forbidden"
        case s404 = "404 Not Found"
        case s405 = "405 Method Not Allowed"
        case s406 = "406 Not Acceptable"
        case s407 = "407 Proxy Authentication Required"
        case s408 = "408 Request Timeout"
        case s409 = "409 Conflict"
        case s410 = "410 Gone"
        case s411 = "411 Length Required"
        case s412 = "412 Precondition Failed"
        case s413 = "413 Payload Too Large"
        case s414 = "414 URI Too Long"
        case s415 = "415 Unsupported Media Type"
        case s416 = "416 Range Not Satisfiable"
        case s417 = "417 Expectation Failed"
        case s418 = "418 I'm a teapot"
        case s422 = "422 Unprocessable Entity"
        case s425 = "425 Too Early"
        case s426 = "426 Upgrade Required"
        case s428 = "428 Precondition Required"
        case s429 = "429 Too Many Requests"
        case s431 = "431 Request Header Fields Too Large"
        case s451 = "451 Unavailable For Legal Reasons"
        case s500 = "500 Internal Server Error"
        case s501 = "501 Not Implemented"
        case s502 = "502 Bad Gateway"
        case s503 = "503 Service Unavailable"
        case s504 = "504 Gateway Timeout"
        case s505 = "505 HTTP Version Not Supported"
        case s511 = "511 Network Authentication Required"
        
        
        case redirectToServer = "redirectToServer"
    }
    
    typealias requestParams = (String,String?, body:[String:Any]?)//path,queryString,body
    
    class LocalServerCallBack {
        let stautsCode 	: statusCode
        let headers  	: [(String,String)]
        let body 		: Data?
        init(statusCode:statusCode,headers:[(String,String)],body:Data?) {
            self.stautsCode = statusCode
            self.headers = headers
            self.body = body
        }
    }
    typealias wrappedResponse  =  ( (   requestParams, @escaping (LocalServerCallBack) -> Void ) -> Void )
    static func getInstance (response :  @escaping wrappedResponse)-> HTTPServer?{
        
        
        do{
            
                 
                 let loop = try SelectorEventLoop(selector: try KqueueSelector())
                 let server = DefaultHTTPServer(eventLoop: loop, port: 8080){
                     (
                     environ: [String: Any],
                     startResponse: @escaping ((String, [(String, String)]) -> Void),
                     sendBody: @escaping ((Data) -> Void)
                     ) in
                     // Start HTTP response
                     
                     let path = environ["PATH_INFO"]! as! String
                     let queryStrings = environ["QUERY_STRING"] as? String
                     
                     
                     let params = requestParams(path,queryStrings,nil)
                     let startResponseMapper : (LocalServerCallBack) -> Void = {
                         arg in
                         
                         if arg.stautsCode == LocalServer.statusCode.redirectToServer{
                             return
                         }
                         
                         
                         
                         startResponse(arg.stautsCode.rawValue,arg.headers)
                         if let data = arg.body {
                             sendBody(data)
                         }
                         sendBody(Data())
                     }
                     response(params,startResponseMapper)
                 }
                 
                 
                 try server.start()
                 
                 DispatchQueue.global().async {
                     loop.runForever()
                 }
                 
                 return server
        }catch {
            print("failed to start local server \(error)")
        }
        return nil
    }
    
    
    
}
