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
    
    @IBOutlet
    var tableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.store = RSStore()
        self.store.set(value: true as NSSecureCoding, key: "runA")
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let shouldDoSpot = self.store.get(key: "shouldDoSpot") as! Bool
//
//        if (shouldDoSpot) {
//
//            self.launchSpotAssessment()
//        }
//
//        self.shouldDoFullAssessment()
//        fileUploader.uploadJson(json: ["hello": "123", "what": "testing"])
        let runA = self.store.get(key: "runA") as! Bool
        
        if runA {
            self.launchFoodSurveyAssessment(type: "A")
            self.store.set(value: false as NSSecureCoding, key: "runA")
        } else {
            self.launchFoodSurveyAssessment(type: "B")
            self.store.set(value: true as NSSecureCoding, key: "runA")
        }
    }
    
    func shouldDoFullAssessment () {
        
        let currentDate = Date()
        
        // Implement should do full assessment
        let fullDate = self.store.valueInState(forKey: "dateFull")
        
        let calendar = NSCalendar.current
        let components = NSDateComponents()
        components.day = 28
        
        
        if(fullDate != nil){
            let futureDate = calendar.date(byAdding: components as DateComponents, to: fullDate as! Date)
            
            if futureDate! <= currentDate {
                
                self.launchFullAssessment()
                
            }
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
            //process results
            
            if reason == ORKTaskViewControllerFinishReason.discarded {
                self?.store.setValueInState(value: false as NSSecureCoding, forKey: "shouldDoSpot")
            }
            
            if reason == ORKTaskViewControllerFinishReason.completed {
                let taskResult = taskViewController.result
                //appDelegate.resultsProcessor.processResult(taskResult: taskResult, resultTransforms: item.resultTransforms)
                
                if(item.identifier == "yadl_spot") {
                    self?.store.set(value: false as NSSecureCoding, key: "shouldDoSpot")
                    self?.store.setValueInState(value: true as NSSecureCoding, forKey: "spotFileExists")

                }
                
                if(item.identifier == "food_survey_A"){
                    
                    // save date that full assessment was completed
                    
                    let date = Date()
                    
//                    self?.store.setValueInState(value: date as NSSecureCoding, forKey: "fullDate")
//                    self?.store.setValueInState(value: true as NSSecureCoding, forKey: "fullFileExists")
                    
                    // save for spot assessment
                    
//                    if let difficultActivities: [String]? = taskResult.results?.flatMap({ (stepResult) in
//                        if let stepResult = stepResult as? ORKStepResult,
//                            stepResult.identifier.hasPrefix("yadl_full."),
//                            let choiceResult = stepResult.firstResult as? ORKChoiceQuestionResult,
//                            let answer = choiceResult.choiceAnswers?.first as? String,
//                            answer == "hard" || answer == "moderate"
//                        {
//                            var tempResult = stepResult.identifier
//                            let index = tempResult.index(tempResult.startIndex, offsetBy: 10)
//                            tempResult = tempResult.substring(from:index)
//
//
//                            NSLog(tempResult)
//
//                            return tempResult.replacingOccurrences(of: "yadl_full.", with: "")
//
//                        }
//                        return nil
//                    }) {
//                        if let answers = difficultActivities {
//                            self?.store.setValueInState(value: answers as NSSecureCoding, forKey: "activity_identifiers")
//
//                            // save when completed full assessment
//
//
//                        }
//                    }
                    
//                    if let answers: [String]? = taskResult.results?.flatMap({ (stepResult) in
//                        if let stepResult = stepResult as? ORKStepResult {
//
//                            return ""
//                        }
//                    }) {
//
//                    }
                    do {
                        let jsonResult = try ORKESerializer.jsonObject(for: taskResult)
                        self?.fileUploader.uploadJson(json: jsonResult)
                    }
                    catch {
                        print(error)
                    }
                }
                
            }
            
            self?.dismiss(animated: true, completion: {
                
                if(item.identifier == "yadl_spot"){
                    self!.pamAssessmentItem = AppDelegate.loadScheduleItem(filename:"pam")
                    self?.launchActivity(forItem: (self?.pamAssessmentItem)!)
                }
                
            })
        }
        
        let tvc = RSAFTaskViewController(
            activityUUID: UUID(),
            task: task,
            taskFinishedHandler: taskFinishedHandler
        )
        
        self.present(tvc, animated: true, completion: nil)
        
    }
    




}
