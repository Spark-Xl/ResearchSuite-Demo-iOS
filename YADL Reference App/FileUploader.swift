//
//  FileUploader.swift
//  YADL Reference App
//
//  Created by shenxialin on 17/4/2018.
//  Copyright © 2018 Christina Tsangouri. All rights reserved.
//

import Foundation
import Alamofire

class FileUploader {
    static let sharedUploader = FileUploader()
    let baseURLString = "https://slack.com/api/files.upload"
    let token = "xoxp-348703700373-348466047539-348024719761-9f5cfb5e46a5e305a25391919e88a153"
    let channel = "data"
    
    func stringify(json: Any) -> String {
        let options = JSONSerialization.WritingOptions.prettyPrinted
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        return ""
    }
    
    func getParameter(content: [AnyHashable: Any]) -> Parameters {
        let id = deviceId ?? "0000"
        let timestamp = NSDate().timeIntervalSince1970
        
        let parameters: Parameters = [
            "token": token,
            "channels": channel,
            "content": stringify(json: ["deviceId": deviceId]) + "\n\n" + stringify(json: content),
            "filename": group_type.rawValue + "_deviceid=\(id)_ts=\(timestamp)" + ".txt"
        ]
        return parameters
    }
    
    func uploadJson(json: [AnyHashable: Any]) {
        let parameters = getParameter(content: json)
        Alamofire.request(baseURLString, method: .post, parameters: parameters, encoding: URLEncoding.default).response { response in
            print("Request: \(String(describing: response.request))")
            print("Response: \(String(describing: response.response))")
            print("Error: \(String(describing: response.error))")
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
    }
}

