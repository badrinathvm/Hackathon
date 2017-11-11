//
//  BagTableViewCell.swift
//  HackathonMessage
//
//  Created by Badrinath on 11/11/17.
//  Copyright © 2017 Badrinath. All rights reserved.
//

import UIKit

class BagTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImage: UIImageView!
    
    @IBOutlet weak var brand: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    
    var bagBrandTitlePriceInfo:Product!{
        didSet{
            self.brand.text = bagBrandTitlePriceInfo.brand
            self.subTitle.text = bagBrandTitlePriceInfo.subTitle
            
            if let thumbnailURL = bagBrandTitlePriceInfo.mainImageURL {
                if (thumbnailURL.contains("http://")){
                    let networkService = NetworkService(url: URL(string:thumbnailURL)!)
                    networkService.downloadImage({ (imageData) in
                        let image = UIImage(data: imageData as Data)
                        DispatchQueue.main.async(execute: {
                            self.mainImage.image = image
                        })
                    })
                }else{
                    self.mainImage.image = UIImage(named: "no_image.jpg")
                }
            }else{
                self.mainImage.image = UIImage(named: "no_image.jpg")
            }
        }
    }
}
