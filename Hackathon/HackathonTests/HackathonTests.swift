//
//  HackathonTests.swift
//  HackathonTests
//
//  Created by Badrinath on 11/8/17.
//  Copyright © 2017 Badrinath. All rights reserved.
//

import Quick
import Nimble

@testable import Hackathon

class HackathonTests: QuickSpec {
    
    var giftViewController: GiftTableViewController!
    
    override func spec() {
        
        describe(" Gift View Controller"){
            
            beforeEach{
                self.giftViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GiftTableViewController") as! GiftTableViewController
                
                let window = UIWindow(frame: UIScreen.main.bounds)
                window.makeKeyAndVisible()
                
                // Triggers viewWillAppear
                self.giftViewController.beginAppearanceTransition(true, animated: false)
                
                // Triggers viewDidAppear
                self.giftViewController.endAppearanceTransition()
            }
            
            context("When Table View is loaded"){
                it("Should be an instance of Gift TableViewcontroller"){
            expect(self.giftViewController).to(beAnInstanceOf(GiftTableViewController.self))
                    
                }
            }
        }
    }
}

