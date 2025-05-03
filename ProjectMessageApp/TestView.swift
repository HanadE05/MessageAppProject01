//
//  TestView.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 20/02/2025.
//


import SwiftUI
struct TestView: View {
   
  @State var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  @State var timeNow = ""
  let dateFormatter = DateFormatter()
   
   var body: some View {
    Text("Currently: " + timeNow)
      .onReceive(timer) { _ in
        self.timeNow = dateFormatter.string(from: Date())
      }
      .onAppear(perform: {dateFormatter.dateFormat = "LLLL dd, hh:mm:ss a"})
  }
}
