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
