//
//  APIKeys.swift
//  Fit14
//
//  Created by Jerson on 7/5/25.
//

import Foundation

struct APIKeys {
    static let googleGeminiAPIKey: String = {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let key = plist["GoogleGeminiAPIKey"] as? String else {
            fatalError("Could not find GoogleGeminiAPIKey in Info.plist")
        }
        return key
    }()
    
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
}
