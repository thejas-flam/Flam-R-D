//
//  ViewController.swift
//  InterviewTasks
//
//  Created by Admin on 28/03/24.
//

import UIKit

class AppViewController: UIViewController {
    
    @IBOutlet weak var sampleTableView: UITableView!
    
    @IBOutlet weak var searchField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .yellow
        registerCells()
        
    }
    
    func registerCells() {
        
        sampleTableView.register(UINib(nibName: SampleCell.nibName, bundle: Bundle(for:SampleCell.classForCoder() )), forCellReuseIdentifier: SampleCell.cellIdentifier)
        
    }


}

extension AppViewController : UITableViewDelegate , UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
}

extension AppViewController : UITextFieldDelegate {
    
    
    
}
