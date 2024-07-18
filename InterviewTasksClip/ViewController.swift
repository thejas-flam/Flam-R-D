//
//  ViewController.swift
//  InterviewTasksClip
//
//  Created by Thejas K on 16/07/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var appClipLabel: UILabel!
    
    @IBOutlet weak var invocationLabel: UILabel!
    
    @IBOutlet weak var resetCountLabel: UILabel!
    
    static var resetCount = 0
    
    var resetText : String {
        return "Reset count = \(ViewController.resetCount)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DispatchQueue.main.async {
            self.appClipLabel.text = "Invocation Url"
            self.resetCountLabel.text = self.resetText
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetInvocationUrl), name: AppDelegate.ClearInvocationUrlNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshViewAfterTokenReset), name: AppDelegate.RefreshViewAfterResetNotification, object: nil)
    }
    
    @objc func resetInvocationUrl() {
        DispatchQueue.main.async {
            self.invocationLabel.text = ""
            ViewController.resetCount += 1
        }
    }
    
    @objc func refreshViewAfterTokenReset() {
        
        DispatchQueue.main.async {
            
            if let url = AppUserDefaults.getInvocationUrl() {
                self.invocationLabel.text = url
                self.resetCountLabel.text = self.resetText
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var url = "Sample Url"
        
        if let value = AppUserDefaults.getInvocationUrl() {
            url = value
        }
        
        DispatchQueue.main.async {
            self.invocationLabel.text = url
        }
    }

}

