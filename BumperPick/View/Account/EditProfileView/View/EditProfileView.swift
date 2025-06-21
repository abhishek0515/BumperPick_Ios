//
//  EditProfileView.swift
//  BumperPick
//
//  Created by tauseef hussain on 18/06/25.
//


import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel = EditProfileViewModel()
    // MARK: - Profile and Picker State
    @State private var selectedImage: Image? = nil
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil

    // MARK: - Profile Fields
    @State private var fullName: String
    @State private var phoneNumber: String
    @State private var email: String
    var imageURL: String?

    init(name: String, phone: String, email: String, imageURL: String?) {
           _fullName = State(initialValue: name)
           _phoneNumber = State(initialValue: phone)
           _email = State(initialValue: email)
           self.imageURL = imageURL
       }
    
    
    var body: some View {
        ZStack {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image("back")
                        .foregroundColor(.black)
                }
                
                Text("Your Profile")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.leading, 8)
                Spacer()
            }
            .padding()
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
            
            // Scrollable content
            ScrollView {
                VStack(spacing: 20) {
                    profileImageSection
                    Text("Enter your details")
                        .font(.title3).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    formField("Your full name", text: $fullName)
                    phoneNumberField
                    emailField
                }
                .padding()
                .padding(.vertical)
            }
            
            // Bottom button
            VStack {
                Button(action: {
                    print("Update tapped")
                    if validateForm() {
                        viewModel.updateProfile(
                            token: CustomerSession.shared.token ?? "",
                            name: fullName,
                            phone: phoneNumber,
                            email: email,
                            imageData: imageData
                        )
                    } else {
                        viewModel.showAlert = true
                    }
                }) {
                    Text("Update Profile")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(appThemeRedColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .padding()
            .background(Color.white)
            // .frame(height: 100)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
            if viewModel.isLoading {
                Color.black.opacity(0.25)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("Loading...")
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
    }
        .hideKeyboardOnTap()
        .background(Color(.systemGray6))
        .ignoresSafeArea(edges: .bottom)
        .navigationBarHidden(true)
        .photosPicker(isPresented: .constant(false), selection: .constant(nil))
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Update Profile"),
                message: Text(viewModel.alerMessage ?? "Something went wrong"),
                dismissButton: .default(Text("OK")) {
                    if  viewModel.isSuccess {
                        dismiss()
                    }
                }
            )
        }

    }

    // MARK: - Profile Image Section
        
    private var profileImageSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            ZStack(alignment: .bottomTrailing) {
                if let selectedImage = selectedImage {
                    selectedImage
                        .resizable()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .padding(.top, 24)
                } else if let imageURL,
                          let url = URL(string: imageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .padding(.top, 24)

                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .padding(.top, 24)
                                .onAppear {
                                    // ✅ Set imageData from URL
                                    if imageData == nil {
                                        downloadImageData(from: url)
                                    }
                                }

                        case .failure:
                            Image("gallary")
                                .resizable()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .padding(.top, 24)

                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image("gallary")
                        .resizable()
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .padding(.top, 24)
                }

                // Pencil overlay
                Circle()
                    .fill(Color.white)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image("editBlack")
                            .font(.system(size: 14, weight: .medium))
                    )
                    .offset(x: -4, y: -4)
            }
        }
        .onChange(of: selectedItem) { newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    imageData = data
                    selectedImage = Image(uiImage: uiImage)
                }
            }
        }
    }



    // MARK: - Reusable Fields
    private func formField(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomLabel(label, required: true).fontWeight(.medium)
            TextField("", text: text)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
        }
    }

    private var phoneNumberField: some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomLabel("Mobile Number ", required: true).fontWeight(.medium)
            HStack {
                TextField("", text: $phoneNumber)
                    .padding()
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
                    .padding(.trailing, 12)
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            CustomLabel("Email ID", required: true).fontWeight(.medium)
            HStack {
                TextField("", text: $email)
                    .padding()
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
                    .padding(.trailing, 12)
            }
            .background(Color.white)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))
        }
    }
    
    //MARK: convert image url to image data
    private func downloadImageData(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, imageData == nil {
                DispatchQueue.main.async {
                    self.imageData = data
                }
            }
        }.resume()
    }
    
    private func validateForm() -> Bool {
        if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
            viewModel.alerMessage = "Full name is required."
            return false
        }
        if phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            viewModel.alerMessage  = "Phone number is required."
            return false
        }
        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            viewModel.alerMessage  = "Email is required."
            return false
        }
        if !isValidEmail(email) {
            viewModel.alerMessage  = "Please enter a valid email address."
            return false
        }
  
        return true
    }
}


//#Preview {
//    EditProfileView()
//}
