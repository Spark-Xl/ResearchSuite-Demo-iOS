//
//  SettingsViewController.swift
//  YADL Reference App
//
//  Created by shenxialin on 19/4/2018.
//  Copyright © 2018 Christina Tsangouri. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss
import ResearchSuiteAppFramework
import UserNotifications

class MySettingsViewController: UIViewController {
    let fileUploader = FileUploader.sharedUploader
    let dateChecker = DateChecker.sharedDateChecker
    var fullAssessmentItem: RSAFScheduleItem!
    
    @IBAction func launchExpA(_ sender: Any) {
        launchFoodSurvey(type: "A")
    }
    
    @IBAction func launchExpB(_ sender: Any) {
        launchFoodSurvey(type: "B")
    }
    
    @IBAction func launchControl(_ sender: Any) {
        launchFoodSurveyControlGroup(type: "A")
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func launchFoodSurvey(type: String) {
        self.fullAssessmentItem = AppDelegate.loadScheduleItem(filename: "experiment_" + type)
        self.launchActivity(forItem: fullAssessmentItem)
    }
    
    func launchFoodSurveyControlGroup(type: String) {
        self.fullAssessmentItem = AppDelegate.loadScheduleItem(filename: "baseline_" + type)
        self.launchActivity(forItem: fullAssessmentItem)
    }
    
    func launchActivity(forItem item: RSAFScheduleItem) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let steps = appDelegate.taskBuilder.steps(forElement: item.activity as JsonElement) else {
                return
        }
        
        let task = ORKOrderedTask(identifier: item.identifier, steps: steps)
        
        let taskFinishedHandler: ((ORKTaskViewController, ORKTaskViewControllerFinishReason, Error?) -> ()) = { [weak self] (taskViewController, reason, error) in
            //when finised, if task was successful (e.g., wasn't canceled)
            if reason == ORKTaskViewControllerFinishReason.completed {
                self?.dateChecker.surveyDone()
                
                let taskResult = taskViewController.result
                do {
                    let jsonResult = try ORKESerializer.jsonObject(for: taskResult)
                    self?.fileUploader.uploadJson(json: jsonResult)
                }
                catch {
                    print(error)
                }
            }
            self?.dismiss(animated: true)
        }
        
        let tvc = RSAFTaskViewController(
            activityUUID: UUID(),
            task: task,
            taskFinishedHandler: taskFinishedHandler
        )
        self.present(tvc, animated: true, completion: nil)
    }
}
