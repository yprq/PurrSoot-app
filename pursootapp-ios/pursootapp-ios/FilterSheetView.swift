import SwiftUI

struct FilterOptions {
    var city: String = "All"
    var maxDistance: Double = 50.0
    var selectedAge: String = "All"
    var selectedGender: String = "All"
}

struct FilterSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var filters: FilterOptions
    var onApply: () -> Void
    
    private let primaryGreen = Color.customDarkSage
    private let backgroundColor = Color(red: 246/255, green: 246/255, blue: 246/255)

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Şehir Seçimi
                        customPicker(title: "City", selection: $filters.city, options: ["All", "Istanbul", "Izmir", "Ankara"])
                        
                        // Mesafe Slider (Mesafe secelim demiştin)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Max Distance: \(Int(filters.maxDistance)) km")
                                .font(.custom("Poppins-Medium", size: 16))
                            Slider(value: $filters.maxDistance, in: 1...100, step: 1)
                                .tint(primaryGreen)
                        }
                        
                        // Yaş ve Cinsiyet (Hizalamalar AddPet ile aynı)
                        HStack(spacing: 15) {
                            customPicker(title: "Age", selection: $filters.selectedAge, options: ["All", "<1", "1", "2", "3", "4", "5+"])
                            customPicker(title: "Gender", selection: $filters.selectedGender, options: ["All", "Male", "Female"])
                        }
                        
                        Button(action: {
                            onApply()
                            dismiss()
                        }) {
                            Text("Apply Filters")
                                .font(.custom("Poppins-SemiBold", size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(primaryGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.top, 20)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        filters = FilterOptions()
                        onApply()
                        dismiss()
                    }.foregroundColor(.red)
                }
            }
        }
    }

    // AddPetView'daki ile aynı görsel yapı
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
