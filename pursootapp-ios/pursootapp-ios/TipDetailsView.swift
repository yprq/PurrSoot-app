import SwiftUI

struct TipDetailsView: View {
    let tip: Tip
    @Environment(\.dismiss) var dismiss // Sayfayı kapatmak için ekledik
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
               
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(tip.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(tip.subtitle)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text(tip.content ?? "İçerik yüklenemedi.")
                        .font(.body)
                        .lineSpacing(6)
                }
                .padding()
            }
        }
        .navigationTitle("Tip Details")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // 
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss() // HomeView'a geri döner
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left") // Geri oku
                            .fontWeight(.bold)
                        Text("Back")
                    }
                    .foregroundColor(.primary) // Uygulama temanla uyumlu renk
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TipDetailsView(
            tip: Tip(
                id: 1,
                title: "Feeding 101",
                subtitle: "How to feed stray cats",
                image_name: "Frame 19",
                content: "Sokaktaki dostlarımızı beslerken yüksek kaliteli kuru mama kullanmak önemlidir. Daima temiz su bulundurmayı unutmayın. Mama kaplarını her beslemeden sonra temizleyerek hijyeni sağlayabilirsiniz."
            )
        )
    }
}
