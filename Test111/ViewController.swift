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

    var failed : [Int] = []
    var dataSource = [String]()
    let imageCollectionLoader = ImageCollectionLoaderBuilder().defaultImp(ramMaxItemsCount: 60)
    var session : URLSession? = nil
    var server : HTTPServer! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let x = ImageLoaderBuilder().concrete(ramMaxItemsCount: 30)
         DiskCacheBuilder().concrete().cache(image: UIImage(), url: "asda", completion: {
            result in 
        })
        RamCacheBuilder().concrete(maxItemsCount: 20)
        
      
        
        
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
           // dataSource.append(UITestsConstants.baseUrl + "\(i)")
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
         let x = indexPath
            imageCollectionLoader.requestImage(requestDate: Date(), url: element, indexPath: indexPath, tag: "card", successHandler: {
                image , index , date in
                guard let visibleCell = tableView.cellForRow(at: index) as? cell else {return}
                visibleCell.iv.image = image
            }, failedHandler: {
                _,_,_ in
               
                self.failed.append(x.row)
            })
        ///}
        
        
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
