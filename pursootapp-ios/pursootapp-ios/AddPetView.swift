import SwiftUI
import PhotosUI

struct AddPetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PetManager
    
    // MARK: - Form Verileri
    @State private var name = ""
    @State private var species = "Dog"
    @State private var breed = ""
    @State private var gender = "Male"
    @State private var age = "1"
    @State private var description = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    private let primaryGreen = Color.customDarkSage
    private let backgroundColor = Color(red: 246/255, green: 246/255, blue: 246/255)

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Resim Seçme Alanı
                        imagePlaceholder
                        
                        // İsim ve Irk Bilgisi
                        customTextField(title: "Pet Name", text: $name, placeholder: "e.g. Pamuk")
                        customTextField(title: "Breed", text: $breed, placeholder: "e.g. Golden Retriever")
                        
                        // Tür ve Cinsiyet Seçimi
                        HStack(spacing: 15) {
                            customPicker(title: "Species", selection: $species, options: ["Dog", "Cat", "Others"])
                            customPicker(title: "Gender", selection: $gender, options: ["Male", "Female"])
                        }
                        
                        // Yaş Seçimi
                        customPicker(title: "Age", selection: $age, options: ["<1", "1", "2", "3", "4", "5+"])
                        
                        // Hakkında Kısmı
                        VStack(alignment: .leading, spacing: 8) {
                            Text("About Pet").font(.custom("Poppins-Medium", size: 16))
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(10)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Kaydet Butonu
                        Button(action: {
                            savePetAction()
                        }) {
                            Text("Save Pet")
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(primaryGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.top, 10)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    // MARK: - Functions
    func savePetAction() {
        guard !name.isEmpty else { return }
        
        // Giriş yapan kullanıcının ID'sini UserDefaults'tan alıyoruz
        let loggedInUserId = UserDefaults.standard.integer(forKey: "current_user_id")
        
        guard loggedInUserId != 0 else {
            print("HATA: Kullanıcı girişi bulunamadı.")
            return
        }
        
        // Fonksiyonu tüm parametrelerle ve doğru completion bloğuyla çağırıyoruz
        viewModel.postPet(
            owner_id: loggedInUserId,
            name: name,
            species: species,
            breed: breed,
            gender: gender,
            age: age,
            description: description,
            imageData: selectedImageData,
            completion: { success in
                if success {
                    dismiss()
                } else {
                    print("Pet eklenirken bir hata oluştu.")
                }
            }
        )
    }

    private var imagePlaceholder: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            VStack {
                if let data = selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipped()
                } else {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(primaryGreen)
                        Text("Add Photo")
                            .font(.custom("Poppins-Medium", size: 14))
                            .foregroundColor(primaryGreen)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(primaryGreen.opacity(0.1))
            .cornerRadius(18)
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(primaryGreen.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5])))
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }

    func customTextField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.custom("Poppins-Medium", size: 16))
            TextField(placeholder, text: text)
                .padding().background(Color.white).cornerRadius(12)
                .font(.custom("Poppins-Regular", size: 15))
        }
    }

    func customPicker(title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.custom("Poppins-Medium", size: 16))
            Menu {
                Picker(title, selection: selection) {
                    ForEach(options, id: \.self) { Text($0).tag($0) }
                }
            } label: {
                HStack {
                    Text(selection.wrappedValue)
                    Spacer()
                    Image(systemName: "chevron.down").font(.system(size: 12))
                }
                .padding().background(Color.white).cornerRadius(12)
                .foregroundColor(.black).font(.custom("Poppins-Regular", size: 15))
            }
        }
        .frame(maxWidth: .infinity)
    }
}
