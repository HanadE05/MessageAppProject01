//
//  BottomSheetExample.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 10/03/2025.
//


import SwiftUI

struct ModalView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            
            
            Text("Close Modal")
              
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
        }
    }
}


struct ShowLicenseAgreement: View {
    @State var showModal = false

    var body: some View {
        Button(action: { showModal = true }) {
            Text("My Button")
              
        }
        .fullScreenCover(isPresented: $showModal) {
           
            ModalView()
        }
    }
}

#Preview {
    ShowLicenseAgreement()
}
