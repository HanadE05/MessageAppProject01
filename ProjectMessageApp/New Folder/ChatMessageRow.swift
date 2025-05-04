//
//  ChatMessageRow.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 15/04/2025.
//
import SwiftUI
struct ChatMessageRow: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        if (message.text.isEmpty && (message.imageUrl == nil || message.imageUrl?.isEmpty == true)) {
            EmptyView()
        } else {
            HStack {
                if isCurrentUser {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                        
                        
                        if let imageUrl = message.imageUrl, !imageUrl.isEmpty {
                            MessageImageView(imageUrl: imageUrl)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Text(message.text)
                                .padding(10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    HStack(spacing: 6) {
                        if let imageUrl = message.imageUrl, !imageUrl.isEmpty {
                            MessageImageView(imageUrl: imageUrl)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Text(message.text)
                                .padding(10)
                                .background(Color.purple.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Text(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(.bottom, 2)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
}

