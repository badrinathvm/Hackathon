//
//  Product.swift
//  HackathonMessage
//
//  Created by Badrinath on 11/11/17.
//  Copyright © 2017 Badrinath. All rights reserved.
//

import Foundation
import Alamofire

class Product{
    
    var brand:String?
    var subTitle:String?
    var mainImageURL:String?
    var price: String?
    
    init(brand:String, subTitle:String,price:String,mainImageURL:String) {
        self.brand = brand
        self.subTitle = subTitle
        self.price = price
        self.mainImageURL = mainImageURL
    }
}
