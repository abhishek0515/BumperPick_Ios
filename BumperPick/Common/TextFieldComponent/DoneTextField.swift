//
//  DoneTextField.swift
//  BumperPick
//
//  Created by tauseef hussain on 20/05/25.
//

import SwiftUI


struct DoneTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .submitLabel(.done)
            .onSubmit {
              //  hideKeyboard()
            }
    }
}

extension View {
    func doneTextField() -> some View {
        self.modifier(DoneTextFieldModifier())
    }
}


//#if canImport(UIKit)
//extension View {
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
//                                        to: nil, from: nil, for: nil)
//    }
//}
//#endif
