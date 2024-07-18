//
//  File.swift
//  InterviewTasks
//
//  Created by Thejas K on 16/07/24.
//

import Foundation
import UIKit

enum AppUserDefaults {
    
    case invocationUrl
    
    var key : String {
        switch self {
        case .invocationUrl : return "invocation_url_key"
        }
    }
    
    var value: Any? {
        return UserDefaults.standard.object(forKey: key) as Any?
    }
    
    public func setValue_(value:Any) {
        UserDefaults.standard.setValue(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func removeValue_() {
        switch self {
        case .invocationUrl:
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    static func getInvocationUrl() -> String? {
        
        if let value : String = AppUserDefaults.invocationUrl.value as? String {
            return value
        }
        
        return nil
    }
}
