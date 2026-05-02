import SwiftUI
import PhotosUI

// --- POST MODELİ ---
struct UserPost: Identifiable {
    let id = UUID()
    let userName: String = "James Parlor"
    let userTitle: String = "Pet Owner"
    let petImage: String?
    let selectedImageData: Data?
    let description: String
    var isLiked: Bool = false
    var isSaved: Bool = false
    var likeCount: Int = 0
    var comments: [String] = [] // Yorumları tutacak yeni alan
}

struct Comment: Identifiable {
    let id = UUID()
    let user: String
    let text: String
}

struct MyProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCreatePostView = false
    
    @StateObject var profileService: ProfileService = ProfileService()
    
    // DÜZENLEME İÇİN GEREKLİ EKSİK DEĞİŞKENLER:
    @State private var showEditView = false
    @State private var editingPostID: UUID? = nil
    
    
    @State private var posts: [UserPost] = []
    
    var dynamicPostCount: Int {
        profileService.posts.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // 1. ÜST KISIM: PROFİL VE STATS
                        VStack(spacing: 20) {
                            HStack(alignment: .top, spacing: 15) {
                                Image("Robert_Pattinson")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(profileService.user?.username ?? "Yükleniyor...")
                                        .font(.system(size: 20, weight: .bold))
                                    
                                    HStack(spacing: 15) {
                                        StatView(value: profileService.user?.follower_count ?? 0, label: "Followers")
                                        StatView(value: profileService.user?.following_count ?? 0, label: "Following")
                                        StatView(value: profileService.user?.post_count ?? 0, label: "Posts")
                                        StatView(value: profileService.user?.adopted_count ?? 0, label: "Adopted")
                                    }                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // 2. POSTLAR
                        // MyProfileView içinde bu bloğu bul ve değiştir:
                        if profileService.posts.isEmpty {
                            VStack(spacing: 15) {
                                ProgressView()
                                Text("Gönderiler yükleniyor...")
                            }
                            .padding(.top, 50)
                        } else {
                            // BURASI ÖNEMLİ: Kendi yerel 'posts' dizine değil, servistekine bakmalı
                            // MyProfileView içindeki post döngüsü:
                            // MyProfileView içindeki 'else' bloğunun içini şununla değiştir:
                            ForEach(profileService.posts, id: \.id) { backendPost in
                                ProfilePostCard(
                                    // post: .constant kısmında direkt transformPost kullanıyoruz
                                    post: .constant(transformPost(backendPost)),
                                    profileService: profileService,
                                    backendPostId: backendPost.id,
                                    onDelete: { print("Silme tıklandı") },
                                    onEdit: { print("Düzenleme tıklandı") }
                                )
                            }
                            
                            // MyProfileView içine yardımcı fonksiyon:
                            
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editingPostID = nil // Yeni post eklerken ID'yi sıfırla
                        showCreatePostView = true
                    }) {
                        Image(systemName: "pencil.line")
                            .foregroundColor(.black)
                    }
                }
            }
        }
        // Düzenleme Sheet'i
        // MyProfileView içindeki .sheet kısmını bul ve değiştir:
        .sheet(isPresented: $showCreatePostView) {
            CreatePostView(posts: $posts, profileService: profileService)
        }
        
        // NavigationStack'in kapanış parantezinden hemen önceye ekle:
        .onAppear {
            profileService.fetchProfile(userId: 1)
            profileService.fetchUserPosts(userId: 1)
        }
        
        // MyProfile.swift dosyasının en altı (hiçbir struct içinde değil)
       
    }
    
    
    func transformPost(_ backend: Post) -> UserPost {
        UserPost(
            petImage: backend.image_url,
            selectedImageData: nil,
            description: backend.content,
            isLiked: backend.isLiked ?? false,
            isSaved: false,
            likeCount: backend.likes_count ?? 0,
            comments: []
        )
    }
    
    
    // --- YARDIMCI BİLEŞENLER ---
    
    struct StatView: View {
        let value: Int
        let label: String
        var body: some View {
            VStack(spacing: 2) {
                Text("\(value)").font(.system(size: 16, weight: .bold))
                Text(label).font(.system(size: 11)).foregroundColor(.gray)
            }
        }
    }
    
    struct ProfilePostCard: View {
        @Binding var post: UserPost
        @ObservedObject var profileService: ProfileService
        @State private var isCommenting: Bool = false
        @State private var commentText: String = ""
        let backendPostId: Int
        var onDelete: () -> Void
        var onEdit: () -> Void
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // --- HEADER ---
                HStack(alignment: .center) {
                    HStack(spacing: 10) {
                        Image("Robert_Pattinson")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 38, height: 38)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text(post.userName).font(.system(size: 14, weight: .bold))
                            Text(post.userTitle).font(.system(size: 12)).foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // SAĞ: Üç Nokta (Menü)
                    Menu {
                        Button(action: {
                            onEdit()
                        }) {
                            Label("Düzenle", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            onDelete()
                        }) {
                            Label("Sil", systemImage: "trash")
                        }
                    } label: {
                        ZStack(alignment: .trailing) {
                            Color.black.opacity(0.001)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "ellipsis")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                                .padding(.trailing, 6)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.leading, 15)
                .padding(.trailing, 8)
                .padding(.top, 15)
                .padding(.bottom, 12)
                
                // --- GÖRSEL ---
                Group {
                    if let data = post.selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage).resizable().scaledToFill()
                    } else if let assetImage = post.petImage {
                        Image(assetImage).resizable().scaledToFill()
                    } else {
                        Color.gray.opacity(0.1)
                    }
                }
                .frame(height: 220)
                .frame(maxWidth: .infinity)
                .cornerRadius(12)
                .clipped()
                .padding(.horizontal, 10)
                
                // --- ETKİLEŞİM BUTONLARI ---
                // --- ETKİLEŞİM BUTONLARI ---
                HStack(spacing: 22) {
                    // 1. LIKE BUTONU
                    Button(action: {
                        // UI'ı ve Servisteki veriyi anında güncelle
                        profileService.updateLocalLike(postId: backendPostId)
                        
                        // Backend'e (Python tarafına) haber ver
                        profileService.toggleLike(postId: backendPostId)
                    }) {
                        HStack(spacing: 4) {
                            // Burası kritik: Görüntüyü direkt servisteki veriden alıyoruz
                            if let currentPost = profileService.posts.first(where: { $0.id == backendPostId }) {
                                Image(systemName: (currentPost.isLiked ?? false) ? "heart.fill" : "heart")
                                    .foregroundColor((currentPost.isLiked ?? false) ? .red : .gray)
                                
                                if (currentPost.likes_count ?? 0) > 0 {
                                    Text("\(currentPost.likes_count ?? 0)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .buttonStyle(.borderless)
                    
                    // 2. YORUM BUTONU
                    Button(action: {
                        withAnimation(.easeInOut) {
                            isCommenting.toggle() // Yazma alanını aç/kapat
                        }
                    }) {
                        Image(systemName: "message")
                            .foregroundColor(isCommenting ? .blue : .gray) // Aktifken rengi değişsin
                    }
                    .buttonStyle(.borderless)
                    
                    // 3. PAYLAŞ BUTONU (Gerçek iOS Paylaşımı)
                    Button(action: {
                        sharePost(text: post.description)
                    }) {
                        Image(systemName: "paperplane")
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.borderless)
                    
                    Spacer()
                    
                    // 4. KAYDET BUTONU
                    Button(action: {
                        withAnimation {
                            post.isSaved.toggle()
                        }
                    }) {
                        Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(post.isSaved ? .black : .gray)
                    }
                    .buttonStyle(.borderless)
                }
                .font(.system(size: 20))
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                
                
                if isCommenting {
                    HStack {
                        TextField("Yorumunuzu yazın...", text: $commentText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 13))
                            .padding(8)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(8)
                        
                        Button(action: {
                            if !commentText.isEmpty {
                                withAnimation {
                                    post.comments.append(commentText) // Yorumu listeye ekler
                                    commentText = "" // Kutuyu temizler
                                    isCommenting = false // Yazma alanını kapatır
                                }
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal, 15)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .top).combined(with: .opacity)) // Şık bir açılış animasyonu
                }
                
                if !post.comments.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(post.comments, id: \.self) { comment in
                            HStack(alignment: .top, spacing: 5) {
                                Text("James Parlor").font(.system(size: 13, weight: .bold)) // Yorum yapanın adı
                                Text(comment).font(.system(size: 13))
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 10)
                }
                
                // --- AÇIKLAMA ---
                Text(post.description)
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 20)
            }
            .background(Color(red: 0.98, green: 0.92, blue: 0.90))
            .cornerRadius(24)
            .padding(.horizontal, 16)
        }
    }
    
    struct CreatePostView: View {
        @Environment(\.dismiss) var dismiss
        @Binding var posts: [UserPost]
        @ObservedObject var profileService: ProfileService
        var editingPostID: UUID? = nil
        var isEditing: Bool { editingPostID != nil }
        
        @State private var postText: String = ""
        @State private var selectedItem: PhotosPickerItem? = nil
        @State private var selectedImageData: Data? = nil
        
        var body: some View {
            NavigationStack {
                VStack(spacing: 20) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage).resizable().scaledToFill().frame(height: 250).cornerRadius(15).clipped()
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled").font(.largeTitle).foregroundColor(.gray)
                                Text(isEditing ? "Fotoğrafı Değiştir" : "Fotoğraf Seç").foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity).frame(height: 250).background(Color.gray.opacity(0.1)).cornerRadius(15)
                        }
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                    
                    TextEditor(text: $postText)
                        .frame(height: 120).padding(5).overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(isEditing ? "Gönderiyi Düzenle" : "Yeni Gönderi")
                .onAppear {
                    if let id = editingPostID, let post = posts.first(where: { $0.id == id }) {
                        postText = post.description
                        selectedImageData = post.selectedImageData
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(isEditing ? "Güncelle" : "Paylaş") {
                            if isEditing {
                                // Düzenleme kısmı (şimdilik aynı kalabilir)
                                if let index = posts.firstIndex(where: { $0.id == editingPostID }) {
                                    posts[index] = UserPost(
                                        petImage: posts[index].petImage,
                                        selectedImageData: selectedImageData,
                                        description: postText,
                                        isLiked: posts[index].isLiked,
                                        isSaved: posts[index].isSaved
                                    )
                                }
                            } else {
                                // --- DEĞİŞTİRDİĞİMİZ KISIM BURASI ---
                                
                                // 1. Backend'e (Docker/Python) gönder
                                profileService.uploadPost(
                                    userId: 1, // James'in ID'si
                                    description: postText,
                                    imageUrl: "dog_sample" // Şimdilik asset içindeki bu resmi kullansın
                                )
                                
                                // 2. Ekranın hemen güncellenmesi için yerel listeye ekle
                                let newPost = UserPost(petImage: nil, selectedImageData: selectedImageData, description: postText)
                                posts.insert(newPost, at: 0)
                            }
                            dismiss()
                        }
                        .fontWeight(.bold)
                    }
                }
            }
        }
        
    }
    struct MyProfileView_Previews: PreviewProvider {
        static var previews: some View {
            let mockService = ProfileService()
            
            // Mock verileri dolduruyoruz
            mockService.user = UserProfile(
                id: 1, username: "James Parlor", email: "james@test.com", profile_image: "James_Profile",
                follower_count: 72, following_count: 15, post_count: 2, adopted_count: 5,
                donation_total: "3k+", feeding_count: 72, title: "Pet Owner"
            )
            
            
            // Buradaki önemli nokta: profileService'i doğrudan içine veriyoruz
            return MyProfileView(profileService: mockService)
        }
    }
    
    
    
}

// MyProfile.swift dosyasının EN ALTI (Hiçbir struct'ın içinde değil)

func sharePost(text: String) {
    let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
    
    // Uygulamanın en üst ekranını bulup paylaşım sayfasını açar
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootVC = windowScene.windows.first?.rootViewController {
        rootVC.present(activityVC, animated: true, completion: nil)
    }
}
