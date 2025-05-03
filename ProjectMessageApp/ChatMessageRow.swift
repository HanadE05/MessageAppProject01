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
        // Return nothing if both text and imageUrl are empty
        if (message.text.isEmpty && (message.imageUrl == nil || message.imageUrl?.isEmpty == true)) {
            EmptyView()
        } else {
            HStack {
                if isCurrentUser {
                    Spacer()
                    HStack(spacing: 6) {
                        // Only show timestamp if there's content
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
                        
                        // Only show timestamp if there's content
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

/*
 
 
 import SwiftUI
 struct ChatMessageRow: View {
     let message: Message
     let isCurrentUser: Bool
     var body: some View {
         HStack {
             if isCurrentUser {
                 Spacer() // Push content to the right
                 HStack(spacing: 6) {
                     // Message
                     if let imageUrl = message.imageUrl, !imageUrl.isEmpty {
                         MessageImageView(imageUrl: imageUrl)
                             .clipShape(RoundedRectangle(cornerRadius: 10))
                     } else {
                         // Timestamp on the left of the bubble (inside)
                         Text(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))
                             .font(.caption2)
                             .foregroundColor(.gray)
                             .padding(.bottom, 2)
                     }
                     Text(message.text)
                         .padding(10)
                         .background(Color.blue)
                         .foregroundColor(.white)
                         .cornerRadius(10)

                 }
             } else {
                 HStack(spacing: 6) {

                     // Message
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
                     
                     // Timestamp on the right of the bubble (inside)
                     Text(message.timestamp.dateValue().formatted(date: .omitted, time: .shortened))
                         .font(.caption2)
                         .foregroundColor(.gray)
                         .padding(.bottom, 2)
                 }
                 Spacer() // Push content to the left
             }
         }
         .padding(.horizontal)
     }
 }

 */
