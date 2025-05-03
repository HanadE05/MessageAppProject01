import SwiftUI

struct ChatLogView: View {
    var detailView: some View {
        Text("This is detail view")
            .navigationBarTitle("Detail view title", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {}, label: {
                Image(systemName: "pencil.circle.fill")
            }))
    }

    var body: some View {
        NavigationView {
            NavigationLink(
                destination: detailView,
                label: {
                    Text("Open detail view")
                })
                .navigationBarTitle("Main view")
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}
#Preview {
    ChatLogView()
}
