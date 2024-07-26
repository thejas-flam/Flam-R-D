//
//  Extensions.swift
//  FlamR
//
//  Created by Thejas K on 26/07/24.
//

import Foundation
import UIKit
import Combine

extension UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher {
        return UIControlPublisher(control: self, events: events)
    }
}
