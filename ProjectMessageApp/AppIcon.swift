//
//  AppIcon.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 29/12/2024.
//

import SwiftUI
struct AppIcon: View {
    var body: some View {
            VStack(spacing: 20) {
                    HStack(spacing: 10) {
                        Button(action: {
                            changeAppIcon(to: nil)
                        }) {
                            Image("bluelogo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        Button(action: {
                            changeAppIcon(to: "AppIcon1")
                        }) {
                            Image("redlogo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        Button(action: {
                            changeAppIcon(to: "AppIcon2")
                        }) {
                            Image("purplelogo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        Button(action: {
                            changeAppIcon(to: "AppIcon3")
                        }) {
                            Image("greenlogo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 70, height: 70)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                }
            
            .padding()
            Spacer() 

        }
    private func changeAppIcon(to iconName: String?) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Error setting alternate icon: \(error.localizedDescription)")
            } else {
                //pprint("Successfully changed app icon to \(iconName ?? "default")")
            }
        }
    }
}
#Preview {
    AppIcon()
}



