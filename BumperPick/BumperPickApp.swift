//
//  BumperPickApp.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//

import SwiftUI
import Firebase


//@main
//struct BumperPickApp: App {
//    init() {
//          FirebaseApp.configure()
//      }
//    var body: some Scene {
//
//        WindowGroup {
//            RootView().preferredColorScheme(.light)
//
//        }
//    }
//}


@main
struct BumperPickApp: App {
    init() {
          FirebaseApp.configure()
      }
    @StateObject private var customerSession = CustomerSession.shared

    var body: some Scene {

        WindowGroup {
            RootView().preferredColorScheme(.light)
                .environmentObject(customerSession)

        }
    }
}
