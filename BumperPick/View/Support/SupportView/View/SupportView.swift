//
//  SupportView.swift
//  BumperPick
//
//  Created by tauseef hussain on 17/07/25.
//

import SwiftUI
//import PhotosUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SupportViewModel()

    @State private var showAddTicketSheet = false
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                CustomHeaderViewNew(
                    title: "Support Tickets",
                    showBackButton: true,
                    backAction: { dismiss() },
                    searchText: .constant(""),
                    searchPlaceholder: "",
                    showSearchBar: false
                )

                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.ticketList) { ticket in
                            NavigationLink(destination: TicketDetailView(ticketID: "\(ticket.id)")) {
                                SupportTicketCell(ticket: ticket)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        //
                    }
                    .padding(.horizontal)
                }
                .padding(.top, -30)
            }
            
            // Floating Button
            Button(action: {
                showAddTicketSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(appThemeRedColor)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                    .padding()
            }
        }
        .withLoader(viewModel.isLoading)
        .onAppear() {
            viewModel.getTicket()
        }
        .sheet(isPresented: $showAddTicketSheet) {
            AddTicketSheet { newTicket in
                viewModel.ticketList.insert(newTicket, at: 0)
                showAddTicketSheet = false
            }
            .presentationDetents([.medium]) // 👈 Set sheet height to medium
             .presentationDragIndicator(.visible) 
        }
        .navigationBarHidden(true)
        .background(Color(.systemGroupedBackground))
    }
}

struct SupportTicketCell: View {
    let ticket: SupportTicketItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ticket.subject)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
                Text(ticket.status)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(10)
            }
            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                    .font(.caption)
                Text(ticket.createdAt)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct AddTicketSheet: View {
    @State private var subject = ""
    @State private var message = ""
    @Environment(\.dismiss) private var dismiss
    var onSubmit: (SupportTicketItem) -> Void
    @StateObject private var viewModel = SupportViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Subject", text: $subject)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                TextEditor(text: $message)
                    .frame(height: 120)
                    .padding(4)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                if viewModel.isLoading {
                    ProgressView("Submitting...")
                        .padding(.top)
                }

                Spacer()

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .padding()

                    Spacer()

                    Button("Submit") {
                        guard !subject.trimmingCharacters(in: .whitespaces).isEmpty,
                              !message.trimmingCharacters(in: .whitespaces).isEmpty else {
                            viewModel.alertMessage = "Please fill in all fields."
                            viewModel.showAlert = true
                            return
                        }

                        viewModel.submitTicket(subject: subject, message: message)
                    }
                    .disabled(viewModel.isLoading)
                    .padding()
                    .background((subject.isEmpty || message.isEmpty || viewModel.isLoading) ? Color.gray : appThemeRedColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("New Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("Error"), message: Text(viewModel.alertMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
            .onReceive(viewModel.$ticketResponse.compactMap { $0 }) { response in
                let ticket = SupportTicketItem(
                    id: response.data.id,
                    subject: response.data.subject,
                    status: response.data.status,
                    createdAt: response.data.createdAt,
                    sender: response.data.sender,
                    messages: [] // You don't get messages on create API, so pass empty list
                )
                onSubmit(ticket)
                dismiss()
            }
        }
    }
}



