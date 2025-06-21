//
//  VerifyOtp.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//

import SwiftUI

struct VerifyOtp: View {
    @StateObject private var viewModel: VerifyOtpViewModel
    @FocusState private var focusedField: Int?
    @Environment(\.dismiss) var dismiss
    @State private var showValidationError = false

    // Timer Logic omitted for brevity
    
    @State private var timerCount = 60
    @State private var isTimerRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(phoneNumber: String) {
        _viewModel = StateObject(wrappedValue: VerifyOtpViewModel(phoneNumber: phoneNumber))
    }
    func startTimer() {
        isTimerRunning = true
        timerCount = 60
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // Back Button
            HStack {
                Button(action: { dismiss() }) {
                    Image("back")
                        .renderingMode(.template)
                        .font(.title3)
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationBarHidden(true)

            VStack(alignment: .leading, spacing: 8) {
                Text(AppString.verifyYourOtp)
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack {
                    Text(AppString.sendTo)
                        .foregroundColor(.black)
                    +
                    Text(viewModel.phoneNumber)
                        .foregroundColor(Color(AppString.colorPrimaryColor))
                        .fontWeight(.semibold)

                    Button(action: { dismiss() }) {
                        Image(AppString.imageEdit)
                            .font(.title3)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal)

            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    TextField("", text: $viewModel.otpFields[index])
                        .keyboardType(.numberPad)
                        .frame(width: 50, height: 60)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .focused($focusedField, equals: index)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )

                        .onChange(of: viewModel.otpFields[index]) { newValue in
                            if newValue.count > 1 {
                                viewModel.otpFields[index] = String(newValue.prefix(1))
                            }
                            if !newValue.isEmpty && index < 3 {
                                focusedField = index + 1
                            }
                        }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)


            NavigationLink(destination: HomeTabView(startingTab: .home), isActive: $viewModel.navigateToHome) {
                EmptyView()
            }
        
            Spacer()
            Button(action: {
                viewModel.verifyOtp()
            }) {
                Text(AppString.verify)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(AppString.colorPrimaryColor))
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
            .padding(.top, -20)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("BumperPick"),
                      message: Text(viewModel.alertMessage),
                      dismissButton: .default(Text("OK")))
            }

            // Your timer and resend section here...
            
            HStack(spacing: 5) {
                Text(AppString.didNotReceiveOtp)
                    .foregroundColor(.black)

                if isTimerRunning {
                    Text("\(AppString.retryIn) \(timerCount)s")
                        .foregroundColor(Color(AppString.colorPrimaryColor))
                        .onReceive(timer) { _ in
                            if timerCount > 0 {
                                timerCount -= 1
                            } else {
                                isTimerRunning = false
                                timerCount = 60
                            }
                        }
                } else {
                    Button(action: {
                        // You can call resend OTP logic here
                        startTimer()
                        viewModel.resendOtp()
                        
                    }) {
                        Text(AppString.resend)
                            .foregroundColor(Color(AppString.colorPrimaryColor))
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(viewModel.isLoading)

           // Spacer()
        }
        .padding(.top)
        .hideKeyboardOnTap()
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                ProgressView("Verifying OTP...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
        }
        .onAppear {
            startTimer()
        }
        .onReceive(timer) { _ in
            guard isTimerRunning else { return }

            if timerCount > 0 {
                timerCount -= 1
            } else {
                isTimerRunning = false
            }
        }

    }
}

//struct VerifyOtp: View {
//    @StateObject private var viewModel: VerifyOtpViewModel
//    @FocusState private var focusedField: Int?
//    @Environment(\.dismiss) var dismiss
//    @EnvironmentObject var tabManager: TabManager
//
//    @State private var showValidationError = false
//    @State private var timerCount = 60
//    @State private var isTimerRunning = false
//
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//
//    init(phoneNumber: String) {
//        _viewModel = StateObject(wrappedValue: VerifyOtpViewModel(phoneNumber: phoneNumber))
//    }
//
//    func startTimer() {
//        isTimerRunning = true
//        timerCount = 60
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 30) {
//            topBar
//            titleSection
//            otpFields
//            navigateLink
//            Spacer()
//            verifyButton
//            resendSection
//        }
//        .padding(.top)
//        .hideKeyboardOnTap()
//        .overlay {
//            if viewModel.isLoading {
//                loadingOverlay
//            }
//        }
//    }
//
//    // MARK: - Components
//
//    private var topBar: some View {
//        HStack {
//            Button(action: { dismiss() }) {
//                Image("back")
//                    .renderingMode(.template)
//                    .foregroundColor(.black)
//            }
//            Spacer()
//        }
//        .padding(.horizontal)
//        .navigationBarHidden(true)
//    }
//
//    private var titleSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(AppString.verifyYourOtp)
//                .font(.title3)
//                .fontWeight(.semibold)
//
//            HStack {
//                Text(AppString.sendTo)
//                    .foregroundColor(.black)
//                +
//                Text(viewModel.phoneNumber)
//                    .foregroundColor(Color(AppString.colorPrimaryColor))
//                    .fontWeight(.semibold)
//
//                Button(action: { dismiss() }) {
//                    Image(AppString.imageEdit)
//                        .font(.caption)
//                }
//            }
//        }
//        .padding(.horizontal)
//    }
//
//    private var otpFields: some View {
//        HStack(spacing: 12) {
//            ForEach(0..<4, id: \.self) { index in
//                TextField("", text: $viewModel.otpFields[index])
//                    .keyboardType(.numberPad)
//                    .frame(width: 50, height: 60)
//                    .font(.title2)
//                    .multilineTextAlignment(.center)
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                    .focused($focusedField, equals: index)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
//                    )
//                    .onChange(of: viewModel.otpFields[index]) { newValue in
//                        if newValue.count > 1 {
//                            viewModel.otpFields[index] = String(newValue.prefix(1))
//                        }
//                        if !newValue.isEmpty && index < 3 {
//                            focusedField = index + 1
//                        }
//                    }
//            }
//        }
//        .padding(.horizontal)
//        .frame(maxWidth: .infinity, alignment: .center)
//    }
//
//    private var navigateLink: some View {
//        NavigationLink(
//            destination: HomeTabView(startingTab: .home)
//                .environmentObject(tabManager),
//            isActive: $viewModel.navigateToHome
//        ) {
//            EmptyView()
//        }
//      
//    }
//
//    private var verifyButton: some View {
//        Button(action: {
//            viewModel.verifyOtp()
//        }) {
//            Text(AppString.verify)
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color(AppString.colorPrimaryColor))
//                .cornerRadius(16)
//                .padding(.horizontal)
//        }
//        .padding(.top, -20)
//        .alert(isPresented: $viewModel.showAlert) {
//            Alert(
//                title: Text("BumperPick"),
//                message: Text(viewModel.alertMessage),
//                dismissButton: .default(Text("OK"))
//            )
//        }
//    }
//
//    private var resendSection: some View {
//        HStack(spacing: 5) {
//            Text(AppString.didNotReceiveOtp)
//                .foregroundColor(.black)
//
//            if isTimerRunning {
//                Text("\(AppString.retryIn) \(timerCount)s")
//                    .foregroundColor(Color(AppString.colorPrimaryColor))
//                    .onReceive(timer) { _ in
//                        if timerCount > 0 {
//                            timerCount -= 1
//                        } else {
//                            isTimerRunning = false
//                            timerCount = 60
//                        }
//                    }
//            } else {
//                Button(action: {
//                    startTimer()
//                    viewModel.resendOtp()
//                }) {
//                    Text(AppString.resend)
//                        .foregroundColor(Color(AppString.colorPrimaryColor))
//                        .fontWeight(.semibold)
//                }
//            }
//        }
//        .padding(.horizontal)
//        .frame(maxWidth: .infinity, alignment: .center)
//        .disabled(viewModel.isLoading)
//    }
//
//    private var loadingOverlay: some View {
//        ZStack {
//            Color.black.opacity(0.3).ignoresSafeArea()
//            ProgressView("Verifying OTP...")
//                .padding()
//                .background(Color.white)
//                .cornerRadius(12)
//                .shadow(radius: 10)
//        }
//    }
//}



//struct VerifyOtp_Previews: PreviewProvider {
//    static var previews: some View {
//        VerifyOtp(phoneNumber: "9876543210")
//    }
//}
