//
//  MapView.swift
//  pursootapp-ios
//
//  Created by Yaprak Aslan on 2.04.2026.
//
//reversegeocoding ve mapkit bedasva apple api onları kullancm
import SwiftUI
import MapKit
import CoreLocation
import UIKit

struct MapView: View {
    
    // MAP
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var selectedLocation: MapPin?
    @State private var address: String = "Tap on map to select location"
    
    // DROPDOWN
    @State private var selectedFood = "Select what did you feed"
    let foods = ["Dry food", "Wet food", "Water"]
    
    // IMAGE
    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    
    var body: some View {
        ZStack {
            
            // MAP
            Map(
                coordinateRegion: $region,
                annotationItems: selectedLocation.map { [$0] } ?? []
            ) { pin in
                MapMarker(coordinate: pin.coordinate)
            }
            .ignoresSafeArea()
            .gesture(
                TapGesture()
                    .onEnded {
                        let coord = region.center
                        selectedLocation = MapPin(coordinate: coord)
                        getAddress(from: coord)
                    }
            )
            
            
         
            
            
            VStack {
                Spacer()
             
                
                    VStack(spacing: 12) {
                       
                        ScrollView{
                          
                         
                       
                        Text("Select Location to feed")
                            .font(.headline)
                            .padding(.trailing,170)
                        
                       
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Location")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .padding(.trailing,280)
                            
                            Text(address)
                                .font(.caption2)
                        }
                        
                        
                        
                        Menu {
                            ForEach(foods, id: \.self) { food in
                                Button(food) {
                                    selectedFood = food
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedFood)
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.customOffWhite)
                            .cornerRadius(8)
                        }
                        
                        
                        // img upload
                        Button {
                            showPicker = true
                        } label: {
                            HStack {
                                Text(selectedImage == nil ? "Upload a photo" : "Photo selected")
                                
                                Spacer()
                                
                                Image(systemName: "camera")
                            }
                            .padding()
                            .background(Color.customOffWhite)
                            .cornerRadius(8)
                        }
                        
                        
                        // SUBMIT BUTTON
                        Button {
                            print("Location:", selectedLocation as Any)
                            print("Food:", selectedFood)
                            print("Image selected:", selectedImage != nil)
                        } label: {
                            Text("I Fed Them!")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.customDarkSage)
                                .cornerRadius(10)
                        }
                        
                    
                    }
                    .buttonStyle(.plain)
              
                    .padding(.top)
                    .padding([.leading, .trailing], 20)
                    .padding(.bottom)
                    .background(Color.white)
            
                    .cornerRadius(20)
                    
                    Spacer()
                }
                .frame(minHeight:300, maxHeight: 300)
                
            
                
            }
            .sheet(isPresented: $showPicker) {
                ImagePicker(image: $selectedImage)
                
                
            }
        }
    }
    
    // adres bulma fonk (chatyaptı)
    func getAddress(from coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let place = placemarks?.first {
                DispatchQueue.main.async {
                    let street = place.name ?? ""
                    let city = place.locality ?? ""
                    let country = place.country ?? ""
                    
                    self.address = "\(street), \(city), \(country)"
                }
            }
        }
    }
}
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
#Preview {
    MapView()
}
