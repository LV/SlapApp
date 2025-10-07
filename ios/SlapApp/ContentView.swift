//
//  ContentView.swift
//  SlapApp
//
//  Created by Luis Victoria on 10/6/25.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
