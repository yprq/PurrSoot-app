import SwiftUI

// --- 1. MODELLER ---
struct FeedPost: Identifiable {
    let id = UUID()
    let userName: String
    let userTitle: String
    let userProfileImage: String
    let postImage: String
    let description: String
    let category: String
    var isLiked: Bool = false
    var isSaved: Bool = false
    var likeCount: Int
    var comments: [String] = []
}

struct AdoptingPet: Identifiable {
    let id = UUID()
    let name: String
    let breed: String
    let image: String
    let description: String
}

// --- 2. ANA VIEW (FEEDS) ---
struct FeedsView: View {
    @State private var navigateToProfile = false
    @State private var selectedCategory = "All"
    let categories = ["All", "Adoption", "News", "Articles", "Lost & Found"]
    
    @State private var allPosts = [
        FeedPost(userName: "Alena Parlor", userTitle: "Pet Owner", userProfileImage: "Robert_Pattinson", postImage: "dog_sample_2", description: "Bu tatlı dostumuz yeni bir yuva arıyor. Çok oyuncu ve çocuklarla arası harika!", category: "Adoption", likeCount: 12),
        FeedPost(userName: "Gokul Harijan", userTitle: "Pet Owner", userProfileImage: "Gokul_Profile", postImage: "news_image", description: "Pet festivali bu hafta sonu İzmir'de gerçekleşecek! Kaçırmayın.", category: "News", likeCount: 45),
        FeedPost(userName: "Seda Demir", userTitle: "Vet", userProfileImage: "Seda_Profile", postImage: "lost_dog", description: "Bornova civarında köpeğimi kaybettim, görenlerin iletişime geçmesini rica ederim.", category: "Lost & Found", likeCount: 3),
        
        FeedPost(userName: "Alena Parlor", userTitle: "Pet Owner", userProfileImage: "Robert_Pattinson", postImage: "cat_sample_2", description: "Sahiplendirme ilanımız güncellenmiştir.", category: "Adoption", likeCount: 22)
    ]
    
    var filteredPosts: [FeedPost] {
        selectedCategory == "All" ? allPosts : allPosts.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    FeedsHeaderView()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            AdoptingCarouselView()
                                .padding(.top, 10)
                            
                            // FİLTRE BAR
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.self) { category in
                                        CategoryTagView(text: category, isSelected: category == selectedCategory)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                                    selectedCategory = category
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            // POSTLAR
                            if filteredPosts.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(filteredPosts) { post in
                                    FeedPostCardView(post: binding(for: post))
                                }
                            }
                            
                            Spacer(minLength: 120)
                        }
                    }
                }
                
                // SAĞ ALT KÖŞE: PROFELE GİTME BUTONU
                Button(action: {
                    navigateToProfile = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.44, green: 0.54, blue: 0.47))
                            .frame(width: 60, height: 60)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus.bubble.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 25)
                .padding(.bottom, 30)
            }
            .background(Color.white)
            .navigationDestination(isPresented: $navigateToProfile) {
                MyProfileView() // Tıklayınca buraya gider
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "magnifyingglass").font(.largeTitle).foregroundColor(.gray)
            Text("Bu kategoride henüz gönderi yok.").foregroundColor(.gray).padding()
        }.padding(.top, 50)
    }
    
    private func binding(for post: FeedPost) -> Binding<FeedPost> {
        guard let index = allPosts.firstIndex(where: { $0.id == post.id }) else {
            fatalError("Post not found")
        }
        return $allPosts[index]
    }
}

// --- 3. POST KARTI BİLEŞENİ ---
struct FeedPostCardView: View {
    @Binding var post: FeedPost
    @State private var isCommenting = false
    @State private var commentText = ""
    @State private var showOptions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // HEADER
            HStack {
                Image(post.userProfileImage).resizable().scaledToFill().frame(width: 40, height: 40).clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.userName).font(.system(size: 14, weight: .bold))
                    Text(post.userTitle).font(.system(size: 12)).foregroundColor(.gray)
                }
                Spacer()
                
                // ÜÇ NOKTA (Kesin tıklanır)
                Button(action: { showOptions = true }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(15).zIndex(1)
            
            // GÖRSEL
            Image(post.postImage).resizable().scaledToFill().frame(height: 220).cornerRadius(15).clipped().padding(.horizontal, 10)
            
            // ETKİLEŞİM BUTONLARI
            HStack(spacing: 22) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        post.isLiked.toggle()
                        post.likeCount += post.isLiked ? 1 : -1
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart").foregroundColor(post.isLiked ? .red : .black)
                        if post.likeCount > 0 { Text("\(post.likeCount)").font(.caption).foregroundColor(.gray) }
                    }
                }.buttonStyle(.borderless)

                Button(action: { withAnimation { isCommenting.toggle() } }) {
                    HStack(spacing: 4) {
                        Image(systemName: "message").foregroundColor(isCommenting ? .blue : .black)
                        if !post.comments.isEmpty { Text("\(post.comments.count)").font(.caption).foregroundColor(.gray) }
                    }
                }.buttonStyle(.borderless)

                Button(action: { sharingPost(text: post.description) }) {
                    Image(systemName: "paperplane").foregroundColor(.black)
                }.buttonStyle(.borderless)

                Spacer()

                Button(action: { withAnimation { post.isSaved.toggle() } }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark").foregroundColor(.black)
                }.buttonStyle(.borderless)
            }
            .font(.system(size: 20)).padding(18)
            
            // YORUM YAZMA
            if isCommenting {
                HStack {
                    TextField("Yorum ekle...", text: $commentText).font(.system(size: 13)).padding(8).background(Color.white.opacity(0.8)).cornerRadius(8)
                    Button(action: {
                        if !commentText.isEmpty {
                            withAnimation { post.comments.append(commentText); commentText = ""; isCommenting = false }
                        }
                    }) { Image(systemName: "arrow.up.circle.fill").font(.title2).foregroundColor(.blue) }
                }.padding(.horizontal, 15).padding(.bottom, 10)
            }
            
            // YORUM LİSTESİ
            if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(post.comments, id: \.self) { comment in
                        HStack(alignment: .top, spacing: 5) {
                            Text("James Parlor").bold()
                            Text(comment)
                        }.font(.system(size: 13))
                    }
                }.padding(.horizontal, 18).padding(.bottom, 8)
            }
            
            Text(post.description).font(.system(size: 13)).lineSpacing(4).padding(.horizontal, 15).padding(.bottom, 20)
        }
        .background(Color(red: 0.90, green: 0.92, blue: 0.88)).cornerRadius(24).padding(.horizontal, 16)
        .confirmationDialog("Seçenekler", isPresented: $showOptions) {
            Button("Rapor Et", role: .destructive) { }
            Button("Takibi Bırak") { }
            Button("Vazgeç", role: .cancel) { }
        }
    }
}

// --- 4. YARDIMCI BİLEŞENLER ---
struct AdoptingCarouselView: View {
    let pets = [
        AdoptingPet(name: "Luna", breed: "Golden", image: "puppy_banner", description: "3 aylık dost."),
        AdoptingPet(name: "Mochi", breed: "Scottish", image: "cat_banner", description: "Sakin bir yuva arıyor.")
    ]
    var body: some View {
        TabView {
            ForEach(pets) { pet in
                ZStack(alignment: .bottomLeading) {
                    Image(pet.image).resizable().scaledToFill().frame(height: 190).cornerRadius(20).clipped()
                    LinearGradient(gradient: Gradient(colors: [.clear, .black.opacity(0.7)]), startPoint: .top, endPoint: .bottom).cornerRadius(20)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(pet.name) - \(pet.breed)").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        Text(pet.description).font(.system(size: 12)).foregroundColor(.white.opacity(0.9))
                    }.padding(20)
                }
            }
        }.frame(height: 190).tabViewStyle(PageTabViewStyle()).padding(.horizontal)
    }
}

struct CategoryTagView: View {
    let text: String
    let isSelected: Bool
    var body: some View {
        Text(text).font(.system(size: 14, weight: isSelected ? .bold : .medium)).padding(.horizontal, 22).padding(.vertical, 10)
            .background(isSelected ? Color(red: 0.44, green: 0.54, blue: 0.47) : Color(red: 0.98, green: 0.92, blue: 0.90))
            .foregroundColor(isSelected ? .white : .black).cornerRadius(15)
    }
}

struct FeedsHeaderView: View {
    var body: some View {
        HStack {
            Image(systemName: "chevron.left").font(.title3).bold()
            Spacer()
            Text("Feeds").font(.headline).bold()
            Spacer()
            Image("Robert_Pattinson").resizable().scaledToFill().frame(width: 35, height: 35).clipShape(Circle())
        }.padding(.horizontal).padding(.vertical, 10)
    }
}

func sharingPost(text: String) {
    let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first?.rootViewController {
        rootVC.present(activityVC, animated: true, completion: nil)
    }
}
// --- 5. PREVIEW ---
struct FeedsView_Previews: PreviewProvider {
    static var previews: some View {
        FeedsView()
    }
}
