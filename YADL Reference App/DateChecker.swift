//
//  DateChecker.swift
//  YADL Reference App
//
//  Created by shenxialin on 18/4/2018.
//  Copyright © 2018 Christina Tsangouri. All rights reserved.
//

import Foundation

enum Group: String {
    case Experimental_A = "Experimental_A"
    case Experimental_B = "Experimental_B"
    case Control = "Control"
}

enum UserDefaultsKey: String {
    case FIRSTRUNTIME
}

//let baseline_test_duration = 3
let transform_date_month = 4
let transform_date_day = 29
let group_type: Group = .Experimental_A

class DateChecker {
    static let sharedDateChecker = DateChecker()
    private let defaults = UserDefaults.standard
    private let calendar = NSCalendar.current
    
//    private func shouldTransform() -> Bool {
//        if let firstRunTime = getFirstRunTime() {
//            let currentTime = Date()
//            let dateA = calendar.component(.day, from: firstRunTime)
//            let dateB = calendar.component(.day, from: currentTime)
//            if dateB - dateA == baseline_test_duration {
//                return true
//            }
//        }
//        return false
//    }
    
    private func getDayAndMonth() -> (Int, Int) {
        let currentTime = Date()
        let day = calendar.component(.day, from: currentTime)
        let month = calendar.component(.month, from: currentTime)
        return (day, month)
    }
    
    private func shouldTransform() -> Bool {
        let current = getDayAndMonth()
        return (current.0 >= transform_date_day && current.1 >= transform_date_month)
    }
    
    func groupType() -> Group {
        if shouldTransform() {
            return group_type
        }
        return .Control
    }
    
    func shouldRunSurvey() -> Bool {
        let current = getDayAndMonth()
        let key = "key_\(100*current.1 + current.0)"
        let finished = defaults.bool(forKey: key)
        return !finished
    }
    
    func surveyDone() {
        let current = getDayAndMonth()
        let key = "key_\(100*current.1 + current.0)"
        defaults.set(true, forKey: key)
    }
    
//    private func getFirstRunTime() -> Date? {
//        if let firstRunTime = defaults.object(forKey: UserDefaultsKey.FIRSTRUNTIME.rawValue) as? Date {
//            return firstRunTime
//        }
//
//        return nil
//    }
}
