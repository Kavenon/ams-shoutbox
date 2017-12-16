//
//  ShoutboxService.swift
//  ams-shoutbox
//
//  Created by Kamil on 12/16/17.
//  Copyright © 2017 Kamil. All rights reserved.
//

import Foundation
import Alamofire
class ShoutboxService {
    
    
    func send(name: text, message: text) -> Void {
    
        let Parameters: Parameters = [
            name: name,
            message: message
        ]
        
        Alamofire.request("https://requestb.in/rkmbzrk", method: .post, parameters: parameters);
    
    }
    
}
