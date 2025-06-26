//
//  LabeledTextField.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/06/25.
//
import SwiftUI

//MARK: this component with one lable and textfield design as per this figma match
struct LabeledTextField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    let isRequiredField: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomLabel(label, required: isRequiredField).fontWeight(.medium)
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
        }
    }
}
//MARK: this component with one lable and textfield with edit image design as per this figma match
struct LabeledTextFieldWithEditImage: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    let isRequiredField: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomLabel(label, required: isRequiredField)
                .fontWeight(.medium)
            HStack {
                TextField("", text: $text)
                    .padding()
                    .keyboardType(keyboardType)
                Image("editBlack")
                    .foregroundColor(.gray)
                    .padding(.trailing, 12)
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
        }
    }
}

//MARK: this component with one lable and textEditor design as per this figma match
struct LabeledTextEditor: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    let isRequiredField: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomLabel(label, required: true)
                .fontWeight(.medium)
            TextEditor(text: $text)
                .frame(height: 80)
                .padding(8)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
        }
    }
}

//MARK:  common one loader we can call this on everywhere just with vStack {}.withLoader(.isloading)
struct LoadingViewModifier: ViewModifier {
    let isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                ProgressView("Loading...")
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
        }
    }
}
//MARK: we call this withLoader from vstack used loader view
extension View {
    func withLoader(_ isLoading: Bool) -> some View {
        self.modifier(LoadingViewModifier(isLoading: isLoading))
    }
}
