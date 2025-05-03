//
//  ProfileImageView.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 02/03/2025.
//

import SwiftUI

struct MessageImageView: View {
    let imageUrl: String?

    var body: some View {
        if let url = URL(string: imageUrl ?? ""), !imageUrl!.isEmpty {
            AsyncImage(url: url) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill) 
                    .frame(width: 150, height:180)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .scaledToFit()
                    
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
            }
        } else {
            Image(systemName: "photo")
                .resizable()
        }
    }
}
