//
//  ViewController.swift
//  Sample
//
//  Created by Omar Hassan  on 11/20/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import UIKit
import ImageCollectionLoader

class ViewController: UIViewController {
    
    @IBOutlet weak var tv1: UITableView!

    var failed : [Int] = []
    var dataSource = [String]()
    let imageCollectionLoader = ImageCollectionLoaderBuilder().defaultImp(ramMaxItemsCount: 30)
    var session : URLSession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
 let tvs = [tv1]
        tvs.forEach({
            $0?.delegate = self
            $0?.dataSource = self
            $0?.register(UINib(nibName: "cell", bundle: nil), forCellReuseIdentifier: "cell")
            $0?.rowHeight = UITableView.automaticDimension
            $0?.estimatedRowHeight = 100
        })
        
        let imageLoader = ImageLoaderBuilder().concrete(ramMaxItemsCount: 50).getImageFrom(urlString: "https://picsum.photos/id/20/200/200", completion: {
            image in
        }, fail: {
            failMessage , error in
        })
        
        
        for i in 0...1000 {
           dataSource.append("https://picsum.photos/id/\(i)/200/200")
           // dataSource.append(UITestsConstants.baseUrl + "\(i)")
           // dataSource.append(getTempAmazonUrlfrom(url: "\(i)"))
        }
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell
        let element = dataSource[indexPath.row]
        

        
            imageCollectionLoader.requestImage(requestDate: Date(), url: element, indexPath: indexPath, tag: "card", successHandler: {
                image , index , date in
                guard let visibleCell = tableView.cellForRow(at: index) as? cell else {return}
                visibleCell.iv.image = image
            }, failedHandler: {
               failedRequest,failedImage,requestState in
                print("failed request = \(failedRequest) , image = \(failedImage) , requestState = \(requestState)")
              
            })
     
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
    }
   
}
