import SwiftUI

struct ChatBackground: View {
    @AppStorage("chatBackgroundColor") private var chatBackgroundColor: String = "defaultBackground"
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Chat Background")
                .font(.title)
                .bold()

            HStack(spacing: 20) {
                Button(action: {
                    chatBackgroundColor = "brown-monolith-teal-gray-milky-way"
                }) {
                    Image("brown-monolith-teal-gray-milky-way")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                }

                Button(action: {
                    chatBackgroundColor = "mountain-range-beige-sky"
                }) {
                    Image("mountain-range-beige-sky")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                }

                Button(action: {
                    chatBackgroundColor = "brown-white-concrete-houses-near-body-water-mountain"
                }) {
                    Image("brown-white-concrete-houses-near-body-water-mountain")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                }
            }

            HStack(spacing: 20) {
                Button(action: {
                    chatBackgroundColor = "brown-green-trees-beside-river-daytime"
                }) {
                    Image("brown-green-trees-beside-river-daytime")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(radius: 5)
                }
                Button(action: {
                    chatBackgroundColor = "defaultBackground"
                }) {
                    Image(systemName: "trash.square.fill")
                        .resizable()
                                .scaledToFit()
                                .foregroundColor(.red)
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ChatBackground()
}
