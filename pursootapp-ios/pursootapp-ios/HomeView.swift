import SwiftUI

struct HomeView: View {
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // HEADER
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hello peln")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Find and feed cats around you")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image("bell")
                        .font(.title2)
                        .frame(width: 40, height: 40)
                    
                }
                .padding(.horizontal)
                
                
                // MAP PREVIEW CARD
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.customLightSage)
                        .frame(height: 180)
                    
                    
                }
                .padding(.horizontal)
                
                
                // SECTION TITLE
                HStack {
                    Text("Adoptees near you")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                
                // LIST (dummy şimdilik)
                VStack(spacing: 12) {
                    ForEach(0..<5) { index in
                        HStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                            
                            VStack(alignment: .leading) {
                                Text("Cat Spot \(index + 1)")
                                    .fontWeight(.semibold)
                                
                                Text("Food needed")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.05), radius: 5)
                    }
                }
                .padding(.horizontal)
                
            }
            .padding(.top)
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    HomeView()
}
