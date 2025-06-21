//
//  Login.swift
//  BumperPick
//
//  Created by tauseef hussain on 19/05/25.
//

import SwiftUI
import GoogleSignIn
import FirebaseAuth
import Firebase

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigateToOTP = false
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(alignment: .leading, spacing: 20) {
                    Spacer().frame(height: 40)

                    Image("BumperPick")
                        .padding(.leading, 20)

                    Text(AppString.loginWithYourMobileNumber)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.leading, 20)

                    
                    //from here
                
                    HStack(spacing: 8) {
                        TextField("+91", text: $viewModel.countryCode)
                            .keyboardType(.phonePad)
                            .frame(width: 50)
                            .padding(.leading, 4)
                            .onChange(of: viewModel.countryCode) { newValue in
                                // Ensure it starts with + and contains only digits after
                                if !newValue.hasPrefix("+") {
                                    viewModel.countryCode = "+" + newValue.filter { $0.isNumber }
                                } else {
                                    viewModel.countryCode = "+" + newValue.dropFirst().filter { $0.isNumber }
                                }
                            }

                        Divider()
                            .frame(height: 24)
                            .background(Color.gray.opacity(0.5))

                        TextField(AppString.enterYourMobileNumber, text: $viewModel.phoneNumber)
                            .keyboardType(.numberPad)
                            .onChange(of: viewModel.phoneNumber) { newValue in
                                if newValue.count > 10 {
                                    viewModel.phoneNumber = String(newValue.prefix(10))
                                }
                            }
                    }
                    .frame(height: 50)
                    .padding(.horizontal, 12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .cornerRadius(10)
                    .padding(.horizontal, 20)

                    //till
                    
//                    HStack(alignment: .center) {
//                        Button(action: {
//                            viewModel.isTermsAccepted.toggle()
//                        }) {
//                            Image(systemName: viewModel.isTermsAccepted ? "checkmark.square.fill" : "square")
//                                .foregroundColor(Color(AppString.colorPrimaryColor))
//                        }
//                        Text(AppString.termsAndConditions)
//                            .font(.footnote)
//                    }
//                    .padding(.horizontal, 20)
                    
                    HStack(alignment: .center) {
                        Button(action: {
                            viewModel.isTermsAccepted.toggle()
                        }) {
                            Image(systemName: viewModel.isTermsAccepted ? "checkmark.square.fill" : "square")
                                .foregroundColor(Color(AppString.colorPrimaryColor))
                                .padding(8) // Increase tap area
                                            .background(Color.clear)
                                            .contentShape(Rectangle())
                        }
                        Text(AppString.termsAndConditions)
                            .font(.footnote)
                    }
                    .padding(.horizontal, 20)


                    Button(action: {
                        viewModel.validateAndLogin()
                    }) {
                        Text(AppString.getOtp)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(AppString.colorPrimaryColor))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, -10)

                    Button(action: {
                        // Google Sign-In handler here
                        GoogleSignInManager.shared.signIn { result in
                            switch result {
                            case .success(let user):
                                if let email = user.email {
                                    viewModel.loginWithGoogle(email: email)
                                    print("emial tets :\(email)")
                                } else {
                                    print("❌ Google user email not available")
                                }

                            case .failure(let error):
                                print("❌ Google Sign-In Error: \(error.localizedDescription)")
                            }
                        }

                    }) {
                        HStack {
                            Image(AppString.imageGoogleIcon)
                            Text(AppString.signInWithGoogle)
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text(viewModel.alertTitle),
                        message: Text(viewModel.alertMessage),
                        dismissButton: .default(Text("OK"), action: {
                            if viewModel.shouldNavigateAfterAlert {
                                navigateToOTP = true
                                viewModel.shouldNavigateAfterAlert = false
                            } 
                        })
                    )
                }

                // Loader
                if viewModel.isLoading {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Please wait...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }

                // Hidden NavigationLink
                NavigationLink(destination:
                                // VerifyOtp(phoneNumber: viewModel.phoneNumber)
                               VerifyOtp(phoneNumber: "\(viewModel.countryCode)\(viewModel.phoneNumber)")
                    .navigationBarBackButtonHidden(true) // ⬅️ Hide back button on next screen
                               , isActive: $navigateToOTP) {
                    EmptyView()
                }
                
                NavigationLink(destination: HomeTabView(startingTab: .home), isActive: $viewModel.loginViaGmail) {
                    EmptyView()
                }

            }
            .toolbar(.hidden) // ⬅️ Hide nav bar
            .navigationBarBackButtonHidden(true) // ⬅️ Hide back button on LoginView
            .hideKeyboardOnTap()
        }.hideNavigationBar()
    }
}

//#Preview {
//    LoginView()
//}

final class GoogleSignInManager {
    static let shared = GoogleSignInManager()

    private init() {}
    
    func signIn(completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Missing Firebase clientID")
            return
        }
        guard let rootVC = UIApplication.shared.topViewController() else {
            print("❌ No root view controller")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error = error {
                print("❌ Sign in failed: \(error.localizedDescription)")
                return
            }

            guard let googleUser = result?.user,
                  let idToken = googleUser.idToken?.tokenString else {
                print("❌ Failed to get Google user or token")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: googleUser.accessToken.tokenString
            )

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in failed: \(error.localizedDescription)")
                    return
                }

                guard let firebaseUser = authResult?.user else { return }

                // ✅ Extract user info
                let fullName = googleUser.profile?.name ?? ""
                let firstName = googleUser.profile?.givenName ?? ""
                let lastName = googleUser.profile?.familyName ?? ""
                let email = googleUser.profile?.email ?? ""
                let phoneNumber = firebaseUser.phoneNumber ?? "Not Provided"

                print("✅ Google Sign-In Success:")
                print("👤 Name: \(fullName)")
                print("🧑 First Name: \(firstName)")
                print("👪 Last Name: \(lastName)")
                print("📧 Email: \(email)")
                print("📱 Phone: \(phoneNumber)")

                // If needed, call your backend API or pass this info forward
                completion(.success(firebaseUser))
            }
        }
    }


    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        try? Auth.auth().signOut()
    }
}

extension UIApplication {
    func topViewController(base: UIViewController? = UIApplication.shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController,
           let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
