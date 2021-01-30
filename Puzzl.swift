//
//  Puzzl.swift
//  Puzzl-iOS
//
//  Created by Denis Butyletskiy on 21/4/20.
//  Copyright © 2020 Denis Butyletskiy. All rights reserved.
//

import UIKit

public enum PuzzlStatus {
    case success
    case error
}

public protocol PuzzlDelegate: class {
    func getStatus(status: PuzzlStatus)
}


struct ScreenToggle {
    var screen:UIViewController
    var toggle:Bool
    
    init(viewController:UIViewController, value:Bool) {
        screen = screen
        toggle = value
    }
}
public class Puzzl {
    
    static let shared = Puzzl()
    
    static var apiKey = String()
    static var companyID = String()
    static var employeeID = String()
    static var error = String()
    
    static weak var delegate: PuzzlDelegate?
    
    public class func setDelegate(from vc: UIViewController) {
        delegate = vc as! PuzzlDelegate
    }
    
    public class func showOnboardingWith(apiKey: String, companyID: String, employeeID: String, from vc: UIViewController) {
        
        var screenList:[ScreenToggle] = [ScreenToggle(.profileInformation, true), ScreenToggle(.createAccount, true), ScreenToggle(.veriff,true)]
        
        var screensToGo:[UIViewController] = []
        
        for screen in screenList {
            if screen.toggle {
                screensToGo.append(screen.screen)
                
            }
        }
        
        
        PassingData.shared.screensToGo = screensToGo
        
        self.apiKey = apiKey
        self.companyID = companyID
        self.employeeID = employeeID
        
        let group = DispatchGroup()
        
        group.enter()
        ResponseService.shared.getUserInfo { (response) in
            if let response = response.response {
                PassingData.shared.firstGetUserModel = response
                print("success getUserInfo")
            } else if let _ = response.error {
                self.error = "Error"
            }
            group.leave()
        }
        
        group.enter()
        ResponseService.shared.getEmployeeInfo { (response) in

            if let response = response.response {
                PassingData.shared.employeeModel = response
                print("success getEmployeeInfo")
                
//                PassingData.shared.signW2Model.createdAt = response.createdAt
            } else if let _ = response.error {
                print("failed to get EmployeeInfo")
                self.error = "Error"
            }
            group.leave()
        }
        
//        group.enter()
//        ResponseService.shared.generateSSCardPutURL { (response) in
//
//                    if let response = response.response {
//                        PassingData.shared.SSCardURL = response
//                        print("success created S3 URL")
//
//        //                PassingData.shared.signW2Model.createdAt = response.createdAt
//                    } else if let _ = response.error {
//                        print("failed to get S3")
//                        print("hmmmmm")
//                        self.error = "Error"
//                    }
//                    group.leave()
//                }
//
        group.notify(queue: .main, execute: {
            if self.error == "Error" {
                self.delegate?.getStatus(status: .error)
            } else {
                let startOnboarding: UIViewController = .start
                startOnboarding.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                vc.present(startOnboarding, animated: true, completion: nil)
            }
        })
    }
}
