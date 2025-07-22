//
//  EventsScreenView.swift
//  BumperPick
//
//  Created by tauseef hussain on 27/06/25.
//
import SwiftUI

struct CampaignRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var fullName: String = ""
    @State private var mobileNumber: String = ""
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    let campaignID: Int
    
    @StateObject private var viewModel = CampaignRegistrationViewModel()
    
    private var isFormFilled: Bool {
        return !fullName.isEmpty && !mobileNumber.isEmpty && !email.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 🔹 Header View
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image("back")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
                Text("Vision Eye care event")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            // 📝 Form Fields
            VStack(alignment: .leading, spacing: 20) {
                Text("Enter your details")
                    .font(.headline)
                    .padding(.top)
                LabeledTextField(label: "Your full name", text: $fullName, isRequiredField: true)
                LabeledTextField(label: "Mobile Number", text: $mobileNumber, keyboardType: .numberPad, isRequiredField: true)
                LabeledTextField(label: "Enter your email", text: $email, keyboardType: .emailAddress, isRequiredField: true)
                
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(12)
            
            Spacer()
            
            // 🔘 Submit Button
            VStack {
                Button(action: {
                    viewModel.submitForm(name: fullName, number: mobileNumber, email: email, campaignID: campaignID)
                }) {
                    Text("Submit now")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormFilled ? appThemeRedColor : Color.gray.opacity(0.5))
                        .cornerRadius(10)
                        .padding([.horizontal, .bottom])
                }
                .disabled(!isFormFilled)
                .padding()
            }
            .background(.white)
        }
        .hideKeyboardOnTap()
        .navigationBarHidden(true)
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.registrationSuccess ? "Success" : "Error"),
                message: Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    if viewModel.registrationSuccess {
                        dismiss() // dismiss the view on success
                    }
                }
            )
        }

        .withLoader(viewModel.isLoading)
    }
}

//
//#Preview {
//    EventRegistrationView()
//}
