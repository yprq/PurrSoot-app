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
    
    @Binding var isPresented: Bool
    
    @State private var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))
    
    @State private var selectedLocation: MapPin?
    @State private var address: String = "Tap on map to select location"
    
    @State private var selectedFood = "Select what did you feed"
    let foods = ["Dry food", "Wet food", "Water"]
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    
    var body: some View {
        ZStack {
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
            
            // 2. SCROLLABLE PANEL LAYER
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    
                    Color.clear
                        .frame(height: UIScreen.main.bounds.height * 0.50)
                        .allowsHitTesting(false)
                    
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
                                Text("Your Location")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(address)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            Divider().padding(.vertical, 5)
                            
                            Text("Save As")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
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
                                print("Location Saved!")
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
                        
                        Divider().padding(.vertical, 10)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Find Vets near you")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Vets that provide free care for emergencies near you")
                                    .font(.caption)
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            
                            HStack(spacing: 15) {
                                Image(systemName: "cross.case.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .padding(12)
                                    .background(Color.customDarkSage.opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text("Sunshine Clinic")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                VStack(alignment: .center, spacing: 2) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.customDarkSage)
                                    Text("200 meters").font(.system(size: 10, weight: .bold))
                                    Text("2 min walking").font(.system(size: 9)).foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                        }
                        .padding(.bottom, 60)
                    }
                    .padding(.horizontal, 24)
                    .background(Color.white)
                    .cornerRadius(32, corners: [.topLeft, .topRight])
                }
            }
            
            // 3. NAVIGATION LAYER (BACK BUTTON) - En üstte olmalı
            VStack {
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white.opacity(0.9))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                Spacer()
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    func getAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first {
                DispatchQueue.main.async {
                    self.address = "\(place.name ?? ""), \(place.locality ?? ""), \(place.administrativeArea ?? "")"
                }
            }
        }
    }
}

// MARK: - Helpers & Extensions
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
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
            parent.image = info[.originalImage] as? UIImage
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

// MARK: - Preview
#Preview {
    MapView(isPresented: .constant(true))
}
