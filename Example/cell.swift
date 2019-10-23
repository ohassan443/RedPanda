//
//  cell.swift
//  trashPanda
//
//  Created by Omar Hassan  on 10/23/19.
//  Copyright © 2019 Omar Hassan. All rights reserved.
//

import UIKit

class cell: UITableViewCell {

    @IBOutlet weak var iv: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        iv.image = nil
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(image:UIImage?) -> Void {
        iv.image = image
    }
}
