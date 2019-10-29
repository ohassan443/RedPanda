//
//  ViewController.swift
//  Example
//
//  Created by Omar Hassan  on 10/23/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tv1: UITableView!
    @IBOutlet weak var tv2: UITableView!
    
    var dataSource = [String]()
    let imageCollectionLoader = ImageCollectionLoaderBuilder().defaultImp()
    var session : URLSession? = nil
    
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
        }
    }
    
    
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell
        let element = dataSource[indexPath.row]
        
        if let card = imageCollectionLoader.cacheQueryState(url: element).image{
			cell.set(image: card)
        }else {
            imageCollectionLoader.requestImage(requestDate: Date(), url: element, indexPath: indexPath, tag: "card", successHandler: {
                image , index , date in
                guard let visibleCell = tableView.cellForRow(at: index) as? cell else {return}
                visibleCell.set(image: image)
            })
        }
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
}
