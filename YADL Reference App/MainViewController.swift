//
//  YADLViewController.swift
//  YADL Reference App
//
//  Created by Christina Tsangouri on 11/6/17.
//  Copyright © 2017 Christina Tsangouri. All rights reserved.
//

import UIKit
import ResearchKit
import ResearchSuiteTaskBuilder
import Gloss
import ResearchSuiteAppFramework

class MainViewController: UIViewController{
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    var store: RSStore!
    let kActivityIdentifiers = "activity_identifiers"
    let delegate = UIApplication.shared.delegate as! AppDelegate
    var fullAssessmentItem: RSAFScheduleItem!
    var spotAssessmentItem: RSAFScheduleItem!
    var pamAssessmentItem: RSAFScheduleItem!
    
    let fileUploader = FileUploader.sharedUploader
    let dateChecker = DateChecker.sharedDateChecker
    
    @IBOutlet
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.store = RSStore()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        launchSurveyIfNecessary()
    }
    
    func launchSurveyIfNecessary() {
        if !dateChecker.shouldRunSurvey() {
            return
        }
        switch dateChecker.groupType() {
        case .Control:
            self.launchFoodSurveyAssessment(type: "B")
        default:
            self.launchFoodSurveyAssessment(type: "A")
        }
    }
    
    func launchSpotAssessment() {
        self.spotAssessmentItem = AppDelegate.loadScheduleItem(filename: "yadl_spot")
        self.launchActivity(forItem: spotAssessmentItem)
    }
    
    func launchFullAssessment () {
        self.fullAssessmentItem = AppDelegate.loadScheduleItem(filename: "yadl_full")
        self.launchActivity(forItem: fullAssessmentItem)
    }
    
    func launchFoodSurveyAssessment (type: String) {
        self.fullAssessmentItem = AppDelegate.loadScheduleItem(filename: "food_survey_" + type)
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
            
            if reason == ORKTaskViewControllerFinishReason.discarded {
                self?.store.setValueInState(value: false as NSSecureCoding, forKey: "shouldDoSpot")
            }
            
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
