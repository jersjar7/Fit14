//
//  ContentView.swift
//  Fit14
//
//  Created by Jerson on 6/30/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            GoalInputView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
            
            PlanListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Plan")
                }
        }
    }
}

#Preview {
    ContentView()
}
