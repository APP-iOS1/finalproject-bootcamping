//
//  BootCampingApp.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
      -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}


@main
struct BootCampingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("login") var isSignIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isSignIn {
            ContentView()
                .environmentObject(AuthStore())
                .environmentObject(DiaryStore())
                .onOpenURL { url in
                          GIDSignIn.sharedInstance.handle(url)
                        }
            } else {
                LoginView(isSignIn: $isSignIn)
                    .environmentObject(AuthStore())
            }

        }
    }
}
