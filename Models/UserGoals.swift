//
//  UserGoals.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import Foundation

struct UserGoals: Codable {
    let text: String
    let createdDate: Date
    
    init(text: String) {
        self.text = text
        self.createdDate = Date()
    }
}
