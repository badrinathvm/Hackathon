//
//  MessagesViewController.swift
//  HackathonMessage
//
//  Created by Badrinath on 11/8/17.
//  Copyright © 2017 Badrinath. All rights reserved.
//

import UIKit
import Messages

class MessagesViewController: MSMessagesAppViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var viewWidth: CGFloat {
        return view.frame.width
    }
    
    struct Storyboard {
        static let BagTableViewCell = "BagTableViewCell"
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(25, 0, 0, 0)
    }
}

extension MessagesViewController: UITableViewDelegate ,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.BagTableViewCell, for: indexPath) as! BagTableViewCell
        
        //let icon = iconSet[indexPath.row]
//        cell.nameLabel.text = icon.name
//        cell.descriptionLabel.text = icon.description
//        cell.priceLabel.text = "$\(icon.price)"
//        cell.iconImageView.image = UIImage(named: icon.imageName)
        
        return cell
        
    }
    
    
}





//Unused code might require later

//extension MessagesViewController: UIScrollViewDelegate {
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let pageWidth = scrollView.frame.width
//        let page = Int(round(scrollView.contentOffset.x / pageWidth))
//        //segmentedControl4.setSelectedSegmentIndex(page, animated: true)
//    }
//}


//    private lazy var scrollView: UIScrollView = {
//
//        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 310, width: self.viewWidth, height: 210))
//        scrollView.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
//        scrollView.isPagingEnabled = true
//        scrollView.showsHorizontalScrollIndicator = false
//        scrollView.contentSize = CGSize(width: self.viewWidth * 3, height: 200)
//        scrollView.delegate = self as UIScrollViewDelegate
//        scrollView.scrollRectToVisible(CGRect(x: viewWidth, y: 0, width: viewWidth, height: 200), animated: false)
//
//        let texts = [
//            "Worldwide",
//            "Local",
//            "Headlines"
//        ]
//
//        for (i, text) in texts.enumerated() {
//            let label = UILabel(frame: CGRect(x: viewWidth * CGFloat(i), y: 0, width: viewWidth, height: 210))
//            label.text = text
//
//            let hue = CGFloat(arc4random() % 256 ) / 256.0 //  0.0 to 1.0
//            let saturation = CGFloat(arc4random() % 128) / 256.0 + 0.5  //  0.5 to 1.0, away from white
//            let brightness = CGFloat(arc4random() % 128) / 256.0 + 0.5  //  0.5 to 1.0, away from black
//
//            let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
//            label.backgroundColor = color
//            label.textColor = UIColor.white
//            label.font = UIFont.systemFont(ofSize: 21)
//            label.textAlignment = .center
//
//            scrollView.addSubview(label)
//        }
//
//        return scrollView
//    }()

