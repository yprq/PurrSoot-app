import SwiftUI

struct HomeView: View {
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack(spacing: 20) {
                    
                    // HEADER
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Hello name!")
                                .font(.subheadline)
                                .fontWeight(.thin)
                            
                            Text("Ready to Feed?")
                                .font(.headline)
                                .fontWeight(.bold)
                            
                                
                        }
                        
                        Spacer()
                        
                        Image("bell")
                            .font(.title2)
                            .frame(width: 40, height: 40)
                        
                    }
                    .padding(.horizontal)
                    
                    CustomSearchBar(text: $searchText)
                        .padding(.horizontal)
                
                   
                    ZStack {
                        VStack{
                            HStack{
                                NavigationLink(destination: AdoptView()) {
                                    
                                    ZStack{
                                        
                                        RoundedRectangle(cornerRadius: 0)
                                            .fill(Color.customLightSage)
                                            .frame(height: 180)
                                        
                                        
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.customDarkSage)
                                            .frame(width:55, height: 55)
                                            .padding(.init(top: 10, leading: 10, bottom: 100, trailing: 110))
                                        Image("faw-full-white")
                                            .padding(.init(top: 10, leading: 10, bottom: 100, trailing: 110))
                                        
                                        VStack(spacing:7){
                                            Spacer()
                                            Text("Adopt a Pet")
                                                .fontWeight(.semibold)
                                                .padding(.trailing,40)
                                            
                                            Text("Browse animals available for adoption")
                                                .fontWeight(.light)
                                                .font(.footnote)
                                            
                                        }
                                        
                                        .padding(.init(top: 10, leading: 5, bottom: 30, trailing: 30))
                                    }
                                }.buttonStyle(.plain)
                                
                                
                                NavigationLink(destination:AdoptView()) {
                                    //mapview ekleee
                                   
                                    ZStack{
                                        
                                        RoundedRectangle(cornerRadius: 0)
                                            .fill(Color.customLightSage)
                                            .frame(height: 180)
                                        
                                        
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.customDarkSage)
                                            .frame(width:55, height: 55)
                                            .padding(.init(top: 10, leading: 10, bottom: 100, trailing: 110))
                                        Image("map (1) 1")
                                            .padding(.init(top: 10, leading: 10, bottom: 100, trailing: 110))
                                        
                                        VStack(spacing:7){
                                            Spacer()
                                            Text("Places to Feed")
                                                .fontWeight(.semibold)
                                                .padding(.trailing,30)
                                            
                                            Text("Find the best places to feed the animals")
                                                .fontWeight(.light)
                                                .font(.footnote)
                                            
                                        }
                                        
                                        .padding(.init(top: 10, leading: 5, bottom: 30, trailing: 30))
                                    }
                                    
                                }
                            }.buttonStyle(.plain)
                            
                            
                            NavigationLink(destination:ChatView()) {

                            ZStack{
                                
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color.customLightSage)
                                    .frame(height: 100)
                                
                                
                                ZStack{
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.customDarkSage)
                                        .frame(width:55, height: 55)
                                        .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 300))
                                    
                                    Image("chat_bubble 1")
                                        .padding(.init(top: 10, leading: 10, bottom: 10, trailing: 300))
                                    
                                    
                                }
                                VStack(spacing:4){
                                    Text("Community")
                                        .fontWeight(.semibold)
                                        .padding(.trailing,120)
                                    
                                    Text("Share your knowlage about stray animals and make friends!")
                                        .fontWeight(.light)
                                        .font(.footnote)
                                        .padding(.leading,60)
                                }
                                
                                
                            }
                        }
                    }
                    .padding(.horizontal)
                        
                }.buttonStyle(.plain)
                    
                    
                    
                    
                    VStack (spacing:15){
                        HStack {
                            Text("Adoptees near you")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("see all")
                            
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<5) { index in
                                    
                                    VStack(alignment: .leading) {
                                        
                                        Image("dog-pic")
                                            .frame(width: 140, height: 140)
                                        
                                        Text("jodo \(index + 1)")
                                            .fontWeight(.semibold)
                                        
                                        Text("golden retriver")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 140)
                                    
                                }
                            }
                            
                            .padding(.horizontal)
                            .padding(.bottom)
                            
                        
                        }
                    
                        HStack  {
                            Text("Tips and tricks")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("see all")
                            
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<5) { index in
                                    
                                    VStack(alignment: .leading) {
                                        
                                        Image("Frame 19")
                                            .frame(width: 140, height: 140)
                                        
                                        Text("feeding \(index + 1)")
                                            .fontWeight(.semibold)
                                        
                                        Text("how to feed")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 140)
                                    
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                    
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
        }
        
    }
}

#Preview {
    HomeView()
}
