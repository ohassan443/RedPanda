//
//  LocalServer.swift
//  ExampleUITests
//
//  Created by Omar Hassan  on 10/29/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import Foundation

import Embassy


class LocallServer {
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
    
    enum localServerRequestParams : String {
        case SERVER_NAME          	=     "SERVER_NAME"
        case EMBASSY_Connection   	=    "embassy.connection"
        case QUERY_String         	=      "QUERY_STRING"
        case SERVER_PROTOCOL      	=    "SERVER_PROTOCOL"
        case SERVER_PORT          	=    "SERVER_PORT"
        case REQUEST_METHOD       	=    "REQUEST_METHOD"
        case SCRIPT_NAME          	=     "SCRIPT_NAME"
        case PATH_INFO            	=   "PATH_INFO"
        case HTTP_HOST            	=   "HTTP_HOST"
        case HTTP_USER_AGENT      	=     "HTTP_USER_AGENT"
        case HTTP_ACCEPT_LANGUAGE 	=   "HTTP_ACCEPT_LANGU"
        case HTTP_CONNECTION      	=     "HTTP_CONNECTION"
        case HTTP_ACCEPT          	=     "HTTP_ACCEPT"
        case HTTP_ACCEPT_ENCODING 	=   "HTTP_ACCEPT_ENCOD"
        case swsgi_version        	=   "swsgi.version"
        case swsgi_input          	=     "swsgi.input"
        case swsgi_error          	=     "swsgi.error"
        case swsgi_multiprocess   	=    "swsgi.multiproces"
        case swsgi_multithread    	=   "swsgi.multithread"
        case swsgi_url_scheme     	=  "swsgi.url_scheme"
        case swsgi_run_once       	=    "swsgi.run_once"
    }
    
    
    //typealias requestParams = (String,String?, body:[String:Any]?)//path,queryString,body
    struct requestParams {
        var path : String
        var queryString : String?
        var body : Data?
        var headers : [String:String]
        var method 	 : String
        
        
        init(path : String, queryString : String?, body : Data?, headers : [String:String], method : String) {
            self.path  			= path
            self.queryString  	= queryString
            self.body 			= body
            self.headers 		= headers
            self.method      	= method
        }
    }
    

    
    class LocalServerCallBack {
        let stautsCode     : statusCode
        let headers      : [(String,String)]
        let body         : Data?
        init(statusCode:statusCode,headers:[(String,String)],body:Data?) {
            self.stautsCode = statusCode
            self.headers = headers
            self.body = body
        }
    }
    typealias wrappedResponse  =  ( (   requestParams, @escaping (LocalServerCallBack) -> Void ) -> Void )
    static func getInstance (response :  @escaping wrappedResponse)-> HTTPServer{
        
        
        
        
        let loop = try! SelectorEventLoop(selector: try! KqueueSelector())
        let server = DefaultHTTPServer(eventLoop: loop, port: 8080){
            (
            environ: [String: Any],
            startResponse: @escaping ((String, [(String, String)]) -> Void),
            sendBody: @escaping ((Data) -> Void)
            ) in
            // Start HTTP response
            
            let path          	= environ[localServerRequestParams.PATH_INFO.rawValue]!     		  as! String
            let queryStrings 	= environ[localServerRequestParams.QUERY_String.rawValue]     		  as? String
            let method             = environ[localServerRequestParams.REQUEST_METHOD.rawValue]!    	  as! String
            let headers 		=  (environ[localServerRequestParams.EMBASSY_Connection.rawValue]     as! HTTPConnection).getHeaders()
            let requestBody 	= (environ[localServerRequestParams.EMBASSY_Connection.rawValue] 	  as! HTTPConnection).getBody()
            
            
            let params = requestParams(path: path, queryString: queryStrings, body: requestBody, headers: headers, method: method)
            let startResponseMapper : (LocalServerCallBack) -> Void = {
                arg in
                
                if arg.stautsCode == LocallServer.statusCode.redirectToServer{
                    redirect(path: path, queryStrings: queryStrings, body: requestBody, headers: headers, httpMethod: method, completion: {
                        resultData,statusCode in
                        guard loop.running == true else {return}
                        guard let data = resultData else {
                            startResponse("\(statusCode)",[])
                            sendBody(Data())
                            return
                        }
                        startResponse(LocallServer.statusCode.s200.rawValue,[])
                        sendBody(data)
                        sendBody(Data())
                    })
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
        
        
        try! server.start()
        
        DispatchQueue.global().async {
            loop.runForever()
        }
        
        return server
    }
    
    static func redirect(path:String,queryStrings:String?,body:Data?,headers:[String:String],httpMethod:String,completion : @escaping (_ data:Data?,_ statusCode:Int)->())-> Void{
        
        var tempUrl = "http://pre.tabeebnet.com/index.php" + path
        if let query = queryStrings {
            tempUrl = tempUrl + "?" + query
        }
        guard let url = URL(string: tempUrl) else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if let body = body {
            request.httpBody = body
//            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
//            request.addValue("application/json",forHTTPHeaderField: "Accept")
        }
        
        
        let forbiddenHeaders = ["Host","Content-Length","Accept","Accept-Language","Accept-Encoding","Connection","User-Agent"]
        let config = URLSessionConfiguration.default
        
        for header in headers{
            guard forbiddenHeaders.contains(header.key) == false else {continue}
            config.httpAdditionalHeaders == nil ? (config.httpAdditionalHeaders = [:]) : ()
            config.httpAdditionalHeaders?[header.key] = [header.value]
        }
        
        config.timeoutIntervalForRequest = 60
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(configuration: config)
        
        
        
        session.dataTask(with: url, completionHandler: {data,response,error in
            let statusCode = ( response as? HTTPURLResponse )?.statusCode ?? 500
            completion(data,statusCode)
        }).resume()
    }
}
