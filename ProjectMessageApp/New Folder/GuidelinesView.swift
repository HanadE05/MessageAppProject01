//
//  GuidelinesView.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 28/04/2025.
//

import SwiftUI

struct GuidelinesView: View {
    var body: some View {
            VStack {
                Text("Community Guidelines")
                    .font(.title).bold().underline()
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Be Respectful: Always be kind and respectful in your interactions with all users. Harassment, hate speech, and discrimination are strictly prohibited.")
                        Text("2. No Offensive Content: Avoid posting content that is offensive, explicit, or illegal.")
                        Text("3. Protect Privacy: Never share personal information,yours or theirs without consent.")
                        Text("4. Be On Topic: Be specific. Don't send Spam or repetitive messages, you might get deleted.")
                        Text("5. Report Incidents: If you notice any inappropriate content or behavior, please report it to our support team through hanad.eid@outlook.com.")
                    }
                .frame(maxWidth: .infinity)
               
                .cornerRadius(10)
                .padding()
            }
            .padding(.top, -220)
    }
}
#Preview {
    GuidelinesView()
}
