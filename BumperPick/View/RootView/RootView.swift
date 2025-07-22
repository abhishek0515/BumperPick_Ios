//
//  RootView.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/05/25.
//

import SwiftUI

//struct RootView: View {
//    @State private var showSplash = true
//    @EnvironmentObject var customerSession: CustomerSession
//
//    var body: some View {
//        ZStack {
//            if showSplash || !customerSession.isSessionLoaded {
//                LaunchView()
//                    .transition(.opacity)
//            } else {
//                if customerSession.isLoggedIn {
//                    // ✅ Wrap with NavigationStack here
//                    NavigationStack {
//                        HomeTabView(startingTab: .home)
//                    }
//                } else {
//                    NavigationStack {
//                        GetStartted()
//                    }
//                }
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                withAnimation {
//                    showSplash = false
//                }
//            }
//        }
//    }
//}

struct RootView: View {
    @State private var showSplash = true
    @EnvironmentObject var customerSession: CustomerSession

    var body: some View {
//        ZStack {
//            if showSplash || !customerSession.isSessionLoaded {
//                LaunchView()
//                    .transition(.opacity)
//            } else {
//                NavigationStack {
//                    if customerSession.isLoggedIn {
//                        HomeTabView(startingTab: .home)
//                    } else {
//                        GetStartted()
//                    }
//                }
//            }
//        }
        Group {
                   if !customerSession.isSessionLoaded {
                       LaunchView()
                   } else {
                       NavigationStack {
                           if customerSession.isLoggedIn {
                               HomeTabView(startingTab: .home)
                           } else {
                               GetStartted()
                           }
                       }
                   }
               }
        
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showSplash = false
                }
            }
        }
        .onChange(of: customerSession.isLoggedIn) { newValue in
            print("📣 isLoggedIn changed to:", newValue)
        }
    }
}



struct HideNavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func hideNavigationBar() -> some View {
        self.modifier(HideNavigationBarModifier())
    }
}
