//
//  ContentView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/6/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @StateObject private var profileManager = ProfileManager()

    var body: some View {
        if isLoggedIn {
            HomeView()
                .environmentObject(profileManager)
        } else {
            LoginView()
                .environmentObject(profileManager)
        }
    }
}

#Preview {
    ContentView()
}
