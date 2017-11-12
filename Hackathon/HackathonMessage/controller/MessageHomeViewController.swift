//
//  MessageHomeViewController.swift
//  HackathonMessage
//
//  Created by Badrinath on 11/11/17.
//  Copyright © 2017 Badrinath. All rights reserved.
//

import Foundation
import Messages

class MessageHomeViewController: MSMessagesAppViewController{
    
    @IBOutlet weak var giftCardContainer: UIView!
    
    @IBOutlet weak var bagContainer: UIView!
    
    var viewWidth: CGFloat {
        return view.frame.width
    }
    
    @IBOutlet weak var segmentControl: HMSegmentedControl!
    
    override func viewDidLoad() {
        self.style1()
        
       //setting the current one to alpha for the first time.
       self.giftCardContainer.alpha = 1
       self.bagContainer.alpha = 0
    }
    
    func style1() {
        let segmentedControl = HMSegmentedControl(sectionTitles: ["Gift Cards", "What's New", "Bag"])
        
        segmentedControl.frame = CGRect(x: 0, y: 20, width: viewWidth, height: 40)
        segmentedControl.autoresizingMask = [.flexibleRightMargin, .flexibleWidth]
        segmentedControl.addTarget(self, action: #selector(segmentedControlChangedValue), for: .valueChanged)
        view.addSubview(segmentedControl)
    }
    
    
    @objc
    func segmentedControlChangedValue(_ segmentedControl: HMSegmentedControl) {
        print("Selected index \(segmentedControl.selectedSegmentIndex) (via UIControlEventValueChanged)")
        
        if segmentedControl.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.giftCardContainer.alpha = 1
                self.bagContainer.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.giftCardContainer.alpha = 0
                self.bagContainer.alpha = 1
            })
        }
    }
}
