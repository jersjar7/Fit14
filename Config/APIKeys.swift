//
//  APIKeys.swift
//  Fit14
//
//  Created by Jerson on 7/5/25.
//

import Foundation

struct APIKeys {
    // IMPORTANT: Replace with your REAL API key (keep it private!)
    // NEVER commit this to version control or share publicly
    static let googleGeminiAPIKey = "AIzaSyDKJzHzLrBIwxcH2GZA0VCcOD3TA-Ben5w"
    
    // Base URLs for different providers
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent"
}

// MARK: - Security Notes
/*
 🔐 SECURITY BEST PRACTICES:
 
 1. NEVER share your API key publicly
 2. Add APIKeys.swift to .gitignore if using version control
 3. Consider using Xcode build configurations for production
 4. Monitor your API usage in Google AI Studio dashboard
 5. Set up usage alerts if available
 
 🚨 IF YOU ACCIDENTALLY EXPOSE YOUR KEY:
 1. Revoke it immediately in Google AI Studio
 2. Generate a new one
 3. Update this file with the new key
 */
