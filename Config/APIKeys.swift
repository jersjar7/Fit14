//
//  APIKeys.swift
//  Fit14
//
//  Created by Jerson on 7/5/25.
//

import Foundation

struct APIKeys {
    static let googleGeminiAPIKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "GoogleGeminiAPIKey") as? String,
              !key.isEmpty else {
            fatalError("Could not find GoogleGeminiAPIKey in Info.plist")
        }
        return key
    }()
    
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
}
