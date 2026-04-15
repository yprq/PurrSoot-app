
import SwiftUI
struct CustomSearchBar: View {
    
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search cats, places...", text: $text)
                .font(.subheadline)
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}
//searchbar için kullanın

