import SwiftUI

// Tüm Auth ekranlarında ortak kullanılacak TextField
struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(Color.gray.opacity(0.8))
                .font(.custom("Poppins-Regular", size: 18))
        )
        .font(.custom("Poppins-Regular", size: 18))
        .foregroundColor(.black)
        .padding(.horizontal, 24)
        .frame(height: 74)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 236/255, green: 236/255, blue: 236/255))
        )
    }
}

// Tüm Auth ekranlarında ortak kullanılacak SecureField (Şifre için)
struct AuthSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(Color.gray.opacity(0.8))
                .font(.custom("Poppins-Regular", size: 18))
        )
        .font(.custom("Poppins-Regular", size: 18))
        .foregroundColor(.black)
        .padding(.horizontal, 24)
        .frame(height: 74)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 236/255, green: 236/255, blue: 236/255))
        )
    }
}
