//
//  ViewController.swift
//  Test111
//
//  Created by Omar Hassan  on 11/4/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import UIKit
import ImageCollectionLoader
import Embassy

class ViewController: UIViewController {
    
    @IBOutlet weak var tv1: UITableView!
    @IBOutlet weak var tv2: UITableView!
    
    var dataSource = [String]()
    let imageCollectionLoader = ImageCollectionLoaderBuilder().defaultImp()
    var session : URLSession? = nil
    var server : HTTPServer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //
        //        var dict = Dictionary<String, Any>()
        //
        //        dict["username"] = "ohassan@noor.net"
        //        dict["password"] = "qwerty"
        //        dict["grant_type"] = "password"
        //        let body = try! JSONSerialization.data(withJSONObject: dict, options: [])
        //
        //
        //
        //        var request = URLRequest(url: URL(string: "http://[::1]:8080/token")! as URL)
        //        request.httpBody = body
        //        request.httpMethod = "POST"
        //        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        //        request.addValue("application/json",forHTTPHeaderField: "Accept")
        //
        //        let firstConfig = URLSessionConfiguration.default
        //        firstConfig.timeoutIntervalForRequest = 30
        //        firstConfig.httpAdditionalHeaders = ["Authorization" : "Basic aW9zYXBwOmlvc2FwcF9wYXNzMTIzIQ=="]
        //        session = URLSession(configuration: firstConfig)
        //
        //        session!.dataTask(with: request){data,response,error in
        //            if let error = error {
        //                print(error)
        //            }
        //        }.resume()
        
        
//        let response : LocallServer.wrappedResponse = {
//            params,callBack in
//            
//            
//                let data = UIImage(named: "testImage1")!.pngData()
//                    callBack(LocallServer.LocalServerCallBack(statusCode: .s200, headers: [], body: data!))
//        }
        
     
        
        
        let tvs = [tv1]
        tvs.forEach({
            $0?.delegate = self
            $0?.dataSource = self
            $0?.register(UINib(nibName: "cell", bundle: nil), forCellReuseIdentifier: "cell")
            $0?.rowHeight = UITableView.automaticDimension
            $0?.estimatedRowHeight = 100
        })
        
        
        
        
        for i in 0...1000 {
           dataSource.append("https://picsum.photos/id/\(i)/200/200")
           // dataSource.append(getTempAmazonUrlfrom(url: "\(i)"))
        }
    }
    
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell
        let element = dataSource[indexPath.row]
        
//        if let card = imageCollectionLoader.cacheQueryState(url: element).image{
//           cell.iv.image = card
//        }else {
            imageCollectionLoader.requestImage(requestDate: Date(), url: element, indexPath: indexPath, tag: "card", successHandler: {
                image , index , date in
                guard let visibleCell = tableView.cellForRow(at: index) as? cell else {return}
                visibleCell.iv.image = image
            }, failedHandler: nil)
        ///}
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
}
