//
//  TicketDetailView.swift
//  BumperPick
//
//  Created by tauseef hussain on 21/07/25.
//
import SwiftUI

struct TicketDetailView: View {
    @State private var messageText = ""
    @StateObject private var viewModel = SupportTicketDetailModel()
    @Environment(\.dismiss) private var dismiss
    @State private var shouldDismissAfterAlert = false

    
    let ticketID: String
    var body: some View {
        VStack(spacing: 0) {
            topBar
            // Messages
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.ticketList) { msg in
                        HStack {
                             ticketList(ticket: msg)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            bottomBar
        }
        .withLoader(viewModel.isLoading)
        .onAppear() {
            viewModel.getTicketDetail(ticketID: ticketID)
        }
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle ?? ""),
                message: Text(viewModel.alertMessage ?? ""),
                dismissButton: .default(Text("OK"), action: {
                    if shouldDismissAfterAlert {
                        dismiss()
                    }
                })
            )
        }
    }
    
    private func ticketList(ticket: TicketMessage) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Row: Avatar, Name, Date
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(ticket.author.type == "Customer" ? .gray : .blue)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ticket.author.type == "Customer" ? "You" : "Admin")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                }

                Spacer()
                
                Text(ticket.createdAt)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            // Message Body
            Text(ticket.body)
                .font(.body)
                .foregroundColor(.primary)
              //  .padding(12)
               // .background(Color.white)
                .cornerRadius(10)
        }
        .padding()
        .background(
            ticket.author.type == "Customer"
            ? Color.gray.opacity(0.1)
            : Color.blue.opacity(0.1)
        )
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
    
    private var topBar: some View {
        HStack(spacing: 12) {
            // Back button
            Button(action: {
                dismiss()
            }) {
               // Image(systemName: "chevron.left")
                Image("back")
                    .foregroundColor(.black)
                    .padding(8)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            
            // Title and status
            Text(viewModel.ticketResponse?.subject ?? "")
                .font(.headline)
                .foregroundColor(.black)
            Spacer()
            Text(viewModel.ticketResponse?.status ?? "")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var bottomBar: some View {
        // Bottom input
        HStack {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: messageText) {
                    // Optional: real-time validation or trimming logic here
                }

            Button(action: {

                if viewModel.isValidMessage(message: messageText) {
                     viewModel.replyTicket(ticketID: ticketID, message: messageText) { success in
                         if success {
                             viewModel.alertTitle = "Success"
                             viewModel.alertMessage = "Message sent successfully."
                             viewModel.showAlert = true
                             shouldDismissAfterAlert = true
                         }
                     }
                 } else {
                     viewModel.alertMessage = "Message must be at least 10 characters and 5 words."
                     viewModel.alertTitle = "Validation Error"
                     viewModel.showAlert = true
                     shouldDismissAfterAlert = false
                 }
            }) {
                Image(systemName: "paperplane.fill")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(viewModel.isValidMessage(message: messageText) ? appThemeRedColor : Color.gray)
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

