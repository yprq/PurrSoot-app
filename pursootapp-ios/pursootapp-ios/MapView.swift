import SwiftUI
import MapKit
import CoreLocation
import UIKit

// MARK: - MapPin Model
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

// MARK: - MapView
struct MapView: View {
    
    @Environment(\.dismiss) var dismiss // JUST ADDED THIS
    @Binding var isPresented: Bool
    
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.4237, longitude: 27.1428),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))
    
    @State private var selectedLocation: MapPin?
    @State private var address: String = ""
    
    @State private var selectedFood = "Select what did you feed"
    let foods = ["Dry food", "Wet food", "Water"]
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            // 1. MAP LAYER
            MapReader { proxy in
                Map(position: $position) {
                    if let pin = selectedLocation {
                        Marker("Selected Location", coordinate: pin.coordinate)
                            .tint(.gray)
                    }
                }
                .onTapGesture { screenPoint in
                    if let coordinate = proxy.convert(screenPoint, from: .local) {
                        selectedLocation = MapPin(coordinate: coordinate)
                        getAddress(from: coordinate)
                    }
                }
            }
            .ignoresSafeArea()
            
            // 2. PANEL LAYER (VStack + Spacer ile haritaya dokunma alanı açıldı)
            VStack(spacing: 0) {
                Spacer()
                    .frame(minHeight: UIScreen.main.bounds.height * 0.45)
                
                VStack(alignment: .leading, spacing: 20) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 5)
                        .padding(.top, 12)
                        .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Select Location to feed")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Search or Tap on Map")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack {
                                TextField("Enter an address...", text: $address)
                                    .textFieldStyle(.plain)
                                    .submitLabel(.search)
                                    .onSubmit { searchAddress() }
                                
                                if !address.isEmpty {
                                    Button { address = "" } label: {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                                    }
                                }
                            }
                            .padding(12)
                            .background(Color.customOffWhite)
                            .cornerRadius(10)
                        }
                        
                        Divider().padding(.vertical, 5)
                        
                        Menu {
                            ForEach(foods, id: \.self) { food in
                                Button(food) { selectedFood = food }
                            }
                        } label: {
                            HStack {
                                Text(selectedFood)
                                    .foregroundColor(selectedFood.contains("Select") ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down").font(.caption)
                            }
                            .padding()
                            .background(Color.customOffWhite)
                            .cornerRadius(12)
                        }
                        
                        Button { showPicker = true } label: {
                            HStack {
                                Text(selectedImage == nil ? "Upload a photo" : "Photo selected")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "camera").foregroundColor(.black)
                            }
                            .padding()
                            .background(Color.customOffWhite)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            Task { await saveFeedingActivity() }
                        } label: {
                            Text("I Fed Them!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.customDarkSage)
                                .cornerRadius(14)
                        }
                    }
                    .padding(.bottom, 60)
                }
                .padding(.horizontal, 24)
                .background(Color.white)
                .cornerRadius(32, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
            
            // 3. BACK BUTTON
            VStack {
                HStack {
                    Button {
                        dismiss() // UPDATED THIS
                        isPresented = false
                    } label: {
                        Image(systemName: "arrow.left")
                            .padding(10)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    Spacer()
                }
                .padding(.top, 50).padding(.horizontal, 20)
                Spacer()
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $selectedImage)
        }
        .alert("Status", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("Successfully") {
                    dismiss() // UPDATED THIS
                    isPresented = false
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Functions
    
    func searchAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, _ in
            if let coordinate = placemarks?.first?.location?.coordinate {
                DispatchQueue.main.async {
                    self.position = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)))
                    self.selectedLocation = MapPin(coordinate: coordinate)
                }
            }
        }
    }
    
    func getAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                DispatchQueue.main.async {
                    self.address = "\(place.name ?? ""), \(place.locality ?? "")"
                }
            }
        }
    }
    
    func saveFeedingActivity() async {
        guard let location = selectedLocation else {
            alertMessage = "Please select a location first!"
            showAlert = true
            return
        }
        
        if selectedFood.contains("Select") {
            alertMessage = "Please select what you fed them!"
            showAlert = true
            return
        }

        let feedingData: [String: Any] = [
            "pet_id": NSNull(),
            "food_type": selectedFood,
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "user_id": 1
        ]
        
        guard let url = URL(string: "http://localhost:8000/map/feed") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: feedingData)
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                await MainActor.run {
                    alertMessage = "Successfully recorded! Thank you for feeding the stray animals. 🐾"
                    showAlert = true
                }
            } else {
                let detail = String(data: data, encoding: .utf8) ?? "No detail"
                await MainActor.run {
                    alertMessage = "Error Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)\nDetail: \(detail)"
                    showAlert = true
                }
            }
        } catch {
            await MainActor.run {
                alertMessage = "Connection error: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

// MARK: - Helpers (Corners & ImagePicker aynen kalıyor)
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage { parent.image = uiImage }
            picker.dismiss(animated: true)
        }
    }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

#Preview {
    MapView(isPresented: .constant(true))
}
