//
//  Recorder.swift
//  aninative
//
//  Created by Andy Drizen on 03/01/2015.
//  Copyright (c) 2015 Andy Drizen. All rights reserved.
//

import UIKit

@objc public class Recorder: NSObject {
    var displayLink : CADisplayLink?
    
    var imageCounter = 0
    public var view : UIView?
    var outputPath : NSString?
    var referenceDate : NSDate?
    public var name = "image"
    public var outputJPG = false
    
    public func start() {
        
        if (view == nil) {
            //NSException(name: NSExceptionName(rawValue: "No view set") ?? <#default value#>, reason: "You must set a view before calling start.", userInfo: nil).raise()
            print("View is nil")
            return
        }
        else {
            displayLink = CADisplayLink(target: self, selector: "handleDisplayLink:")
            displayLink!.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
            
            referenceDate = NSDate()
        }
    }
    
    public func stop() {
        displayLink?.invalidate()
        
        let seconds = referenceDate?.timeIntervalSinceNow
        if (seconds != nil) {
            print("Recorded: \(imageCounter) frames\nDuration: \(-1 * seconds!) seconds\nStored in: \(outputPathString())")
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.andydrizen.test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as NSURL
        }()
    
    func handleDisplayLink(displayLink : CADisplayLink) {
        if (view != nil) {
            createImageFromView(captureView: view!)
        }
    }
    
    func outputPathString() -> String {
        if (outputPath != nil) {
            return outputPath! as String
        }
        else {
            return applicationDocumentsDirectory.absoluteString!
        }
    }
    
    func createImageFromView(captureView : UIView) {
        UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, false, 0)
        captureView.drawHierarchy(in: captureView.bounds, afterScreenUpdates: false)
        
        var fileExtension = "png"
        var data : Data?
        
        if let image = UIGraphicsGetImageFromCurrentImageContext() {
            if (outputJPG) {
                data = image.jpegData(compressionQuality: 1)
                fileExtension = "jpg"
            }
            else {
                data = image.pngData()
            }
            
            var path = outputPathString()
            path = path.appending("/\(name)-\(imageCounter).\(fileExtension)")
            //path.stringByAppendingPathComponent("/\(name)-\(imageCounter).\(fileExtension)")
            
            imageCounter = imageCounter + 1
            
            if let imageRaw = data {
                try? imageRaw.write(to: URL(string: path)!)
                //imageRaw.writeToURL(NSURL(string: path)!, atomically: false)
            }
        }
        
        
        
        
        UIGraphicsEndImageContext();
    }
}
