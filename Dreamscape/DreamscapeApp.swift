//
//  DreamscapeApp.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/3.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import Combine

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

// A ViewModel to manage the User's authentication state
class AppViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
      self.isLoggedIn = Auth.auth().currentUser != nil
    }
}

@main
struct DreamscapeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            if appViewModel.isLoggedIn {
                MainTabView()
                    .environmentObject(appViewModel)
                    .preferredColorScheme(.dark) // Set the preferred color scheme to dark
            } else {
                AuthView()
                    .environmentObject(appViewModel)
                    .preferredColorScheme(.dark) // Set the preferred color scheme to dark
            }
        }
    }
}
