//
//  ProfileImageView.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 02/03/2025.
//

import SwiftUI

struct ProfileImageView: View {
    let imageUrl: String?
    //let size: CGFloat

    var body: some View {
        if let url = URL(string: imageUrl ?? ""), !imageUrl!.isEmpty {
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            } placeholder: {
                Image(systemName: "person.circle.fill") 
                    .resizable()
            }
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                
        }
    }
}
/*
 import SwiftUI

 struct ProfileImageView: View {
     let imageUrl: String?
     let size: CGFloat

     var body: some View {
         if let url = URL(string: imageUrl ?? ""), !imageUrl!.isEmpty {
             AsyncImage(url: url) { image in
                 image.resizable()
                     .aspectRatio(contentMode: .fill)
                     .frame(width: size, height: size)
                     .clipShape(Circle())
             } placeholder: {
                 Image(systemName: "person.circle.fill") // Default icon while loading
                     .resizable()
                     .frame(width: size, height: size)
                     .foregroundColor(.gray)
             }
         } else {
             Image(systemName: "person.circle.fill") // Default icon if no image URL
                 .resizable()
                 .frame(width: size, height: size)
                 .foregroundColor(.gray)
         }
     }
 }
 */
