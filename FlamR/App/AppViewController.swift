//
//  ViewController.swift
//  InterviewTasks
//
//  Created by Admin on 28/03/24.
//

import UIKit
import Combine

class AppViewController: UIViewController {
    
    @IBOutlet weak var holderStack: UIStackView!
    
    @IBOutlet weak var sampleTableView: UITableView!
    
    @IBOutlet weak var searchField: UITextField!
    
    var reactiveButton : UIButton?
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .yellow
        registerCells()
        
        sampleTableView.translatesAutoresizingMaskIntoConstraints = false
        self.sampleTableView.heightAnchor.constraint(equalToConstant: 0.0).isActive = true
        
        setupStackView()
        
        reactiveButton?.publisher(for: .touchUpInside)
                    .sink {
                        print("Button tapped!")
                        DispatchQueue.main.async {
                            self.searchField.text = "Button tapped!"
                        }
                    }
                    .store(in: &cancellables)
    }
    
    func setupStackView() {
        
        let topPadding = UIView(frame: .zero)
        topPadding.backgroundColor = .white
        self.holderStack.addArrangedSubview(topPadding)
        holderStack.setCustomSpacing(100.0, after: topPadding)
        
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        reactiveButton = UIButton(frame: .zero)
        reactiveButton?.backgroundColor = .gray
        reactiveButton?.setTitle("Tap", for: .normal)
        
        holderStack.addArrangedSubview(reactiveButton!)
        reactiveButton?.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let bottomPadding = UIView(frame: .zero)
        bottomPadding.backgroundColor = .white
        self.holderStack.addArrangedSubview(bottomPadding)
        holderStack.setCustomSpacing(20.0, after: bottomPadding)
        
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

struct UIControlPublisher: Publisher {
    
    typealias Output = Void
    typealias Failure = Never

    private let control: UIControl
    private let events: UIControl.Event

    init(control: UIControl, events: UIControl.Event) {
        self.control = control
        self.events = events
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        let subscription = UIControlSubscription(subscriber: subscriber, control: control, events: events)
        subscriber.receive(subscription: subscription)
    }
}

private final class UIControlSubscription<S: Subscriber>: Subscription where S.Input == Void {
    
    private var subscriber: S?
    private let control: UIControl

    init(subscriber: S, control: UIControl, events: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: events)
    }

    func request(_ demand: Subscribers.Demand) {
        // Demand handling can be implemented if needed
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(())
    }
}
