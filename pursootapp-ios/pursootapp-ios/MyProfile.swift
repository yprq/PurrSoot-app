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
    
    // MyProfileView içinde:
    @StateObject var profileService = ProfileService()
    
    // DÜZENLEME İÇİN GEREKLİ EKSİK DEĞİŞKENLER:
    @State private var showEditView = false
    @State private var editingPostID: UUID? = nil
    @State private var editingPost: Post? = nil
    
    
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
                                ZStack {
                                    // Arka planı koyu/orta gri yapıyoruz
                                    Circle()
                                        .fill(Color(.systemGray3))
                                    
                                    // Ortadaki insan silüetini tamamen beyaz yapıyoruz
                                    Image(systemName: "person.fill")
                                        .scaledToFit()
                                        .foregroundColor(.white) // İnsan kısmı beyaz oldu
                                        .padding(20) // İkonun yuvarlağın dışına taşmasını engeller
                                }
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
                        // MyProfileView içinde:
                        if profileService.posts.isEmpty {
                            ProgressView("Loading posts...")
                        } else {
                            ForEach(profileService.posts.indices, id: \.self) { index in
                                ProfilePostCard(
                                    post: $profileService.posts[index], // Canlı Binding
                                    profileService: profileService,
                                    backendPostId: profileService.posts[index].id,
                                    onDelete: { profileService.deletePost(postId: profileService.posts[index].id) },
                                    onEdit: { self.editingPost = profileService.posts[index] // Düzenlenecek postu seçtik
                                        self.showCreatePostView = true
                                        // Burada editingPostID'yi setleyip showCreatePostView = true yapabilirsin
                                        print("Düzenlenecek post: \(profileService.posts[index].id)") }
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
            let loggedInUserId = UserDefaults.standard.integer(forKey: "current_user_id")
                CreatePostView(
                    posts: $posts,
                    profileService: profileService,
                    currentUserId: loggedInUserId != 0 ? loggedInUserId : 1 // ID varsa onu, yoksa 1'i gönderir
                )
        }
        
        // NavigationStack'in kapanış parantezinden hemen önceye ekle:
        .onAppear {
            let loggedInUserId = UserDefaults.standard.integer(forKey: "current_user_id")
                print("DEBUG: MyProfileView açıldı. Okunan Kullanıcı ID -> \(loggedInUserId)")
                
                if loggedInUserId != 0 {
                    // Giriş yapan kullanıcının kendi bilgilerini ve kendi postlarını çekiyoruz
                    profileService.fetchProfile(userId: loggedInUserId)
                    profileService.fetchUserPosts(userId: loggedInUserId)
                } else {
                    // Eğer UserDefaults boşsa, sistemin kilitlenmemesi için 1 nolu test kullanıcısını çeker
                    print("DEBUG: Kullanıcı ID bulunamadı, test kullanıcısı (1) yükleniyor.")
                    profileService.fetchProfile(userId: 1)
                    profileService.fetchUserPosts(userId: 1)
                }
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
    }}
    
    
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
    @Binding var post: Post
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
                    ZStack {
                                ProfileImageView(imageName: profileService.user?.profile_image)
                                    .scaleEffect(0.55) // Büyük profil resmini header boyutuna küçültmek için (38x38 civarı)
                            }
                            .frame(width: 38, height: 38)
                            .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(profileService.user?.username ?? post.userName)
                                        .font(.system(size: 14, weight: .bold))
                                    
                                    Text(profileService.user?.title ?? "Pet Owner")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
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
                // ProfilePostCard içindeki yorum gönderme butonu (kağıt uçak ikonu)
                Button(action: {
                    withAnimation { isCommenting.toggle() }
                }) {
                    Image(systemName: "message")
                        .foregroundColor(isCommenting ? .blue : .gray)
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
                // KAYDET BUTONU (ProfilePostCard içinde)
                Button(action: {
                    withAnimation {
                        // Binding olduğu için $ ile erişiyoruz
                        let currentStatus = post.isSaved ?? false
                        post.isSaved = !currentStatus
                    }
                }) {
                    Image(systemName: (post.isSaved ?? false) ? "bookmark.fill" : "bookmark")
                        .foregroundColor((post.isSaved ?? false) ? .black : .gray)
                }
            }
            .buttonStyle(.borderless)
            
            .font(.system(size: 20))
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            
            
            if isCommenting {
                HStack {
                    TextField("Write comment...", text: $commentText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 13))
                        .padding(8)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(8)
                    
                    Button(action: {
                        if !commentText.isEmpty {
                            // 1. Backend'e gönder
                            profileService.addComment(postId: backendPostId, userId: 1, text: commentText)
                            
                            // 2. UI GÜNCELLEME (Güvenli Yol)
                            withAnimation(.spring()) {
                                // Eğer comments nil ise önce boş bir dizi oluştur, sonra ekle
                                if post.comments == nil {
                                    post.comments = [commentText]
                                } else {
                                    post.comments?.append(commentText)
                                }
                                
                                // Temizlik
                                commentText = ""
                                isCommenting = false
                            }
                        }
                    }) {
                        Text("Send")
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.bottom, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // ProfilePostCard.swift içinde etkileşim butonlarının hemen altına:
            
            if let comments = post.comments, !comments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(comments, id: \.self) { comment in // İndis yerine doğrudan metni kullanıyoruz
                        HStack(alignment: .top, spacing: 5) {
                            Text("James Parlor")
                                .font(.system(size: 13, weight: .bold))
                            Text(comment)
                                .font(.system(size: 13))// İndis ile veriyi alıyoruz
                                .font(.system(size: 13))
                                .foregroundColor(.black.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true) // Metnin kaybolmasını engeller
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.4)) // Yorum alanını biraz daha belirgin yapalım
                .cornerRadius(12)
                .padding(.horizontal, 10)
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
    }}
    
    
struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var posts: [UserPost]
    @ObservedObject var profileService: ProfileService
    var editingPostID: UUID? = nil
    var currentUserId: Int
    var isEditing: Bool { editingPostID != nil }
    
    @State private var postText: String = ""
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    let assetImages = ["Rectangle 49", "Rectangle 40", "Rectangle 45"]
    @State private var selectedAssetImage: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- GÖRSEL ÖNİZLEME ALANI ---
                    Group {
                        if let assetName = selectedAssetImage {
                            Image(assetName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .cornerRadius(15)
                                .clipped()
                        } else if let data = selectedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 220)
                                .cornerRadius(15)
                                .clipped()
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("Aşağıdan bir fotoğraf seçin")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                    .onTapGesture {
                        selectedAssetImage = nil
                        selectedImageData = nil
                    }
                    
                    // --- YATAY ASSET GÖRSEL SEÇİCİ ---
                    // --- 2. YATAY ASSET GÖRSEL SEÇİCİ (Enine Daraltılmış Sürüm) ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sistem Görsellerinden Seç:")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 5)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(assetImages, id: \.self) { imageName in
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 75, height: 75) // Görsel karelerini hafifçe küçülttük
                                        .cornerRadius(10)
                                        .clipped()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectedAssetImage == imageName ? Color.green : Color.clear, lineWidth: 3)
                                        )
                                        .shadow(radius: selectedAssetImage == imageName ? 3 : 0)
                                        .onTapGesture {
                                            selectedImageData = nil
                                            selectedAssetImage = imageName
                                        }
                                }
                                
                                PhotosPicker(selection: $selectedItem, matching: .images) {
                                    VStack {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                        Text("Galeriden")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(width: 75, height: 75)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 10) // İçeriden ekstra boşluk verdik
                        }
                    }
                    .padding(.horizontal, 15) // <--- İŞTE BURASI! Tüm seçici alanı enine daraltan can alıcı dokunuş.
                    .onChange(of: selectedItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                await MainActor.run {
                                    selectedAssetImage = nil
                                    selectedImageData = data
                                }
                            }
                        }
                    }
                    
                    // --- METİN GİRİŞ ALANI ---
                    TextEditor(text: $postText)
                        .frame(height: 100)
                        .padding(5)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle(isEditing ? "Gönderiyi Düzenle" : "Yeni Gönderi")
            .onAppear {
                if let id = editingPostID, let post = posts.first(where: { $0.id == id }) {
                    postText = post.description
                    selectedImageData = post.selectedImageData
                    selectedAssetImage = post.petImage
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Güncelle" : "Paylaş") {
                        // Derleyiciyi rahatlatmak için tüm lojiği aşağıdaki fonksiyona taşıdık
                        handlePostAction()
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    // --- DERLEYİCİYİ RAHATLATAN YARDIMCI FONKSİYON ---
    private func handlePostAction() {
            if isEditing {
                if let index = posts.firstIndex(where: { $0.id == editingPostID }) {
                    let currentImage = selectedAssetImage ?? posts[index].petImage
                    posts[index] = UserPost(
                        petImage: currentImage,
                        selectedImageData: selectedImageData,
                        description: postText,
                        isLiked: posts[index].isLiked,
                        isSaved: posts[index].isSaved
                    )
                }
            } else {
                let finalImageName = selectedAssetImage ?? "Rectangle 49"
                
                profileService.uploadPost(
                    userId: currentUserId,
                    description: postText,
                    imageUrl: finalImageName
                )
                
                let newPost = UserPost(
                    petImage: finalImageName,
                    selectedImageData: selectedImageData,
                    description: postText
                )
                posts.insert(newPost, at: 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    profileService.fetchProfile(userId: currentUserId)
                }
            }
        }
}
    struct MyProfileView_Previews: PreviewProvider {
        static var previews: some View {
            // Preview için bir instance oluşturuyoruz
            let view = MyProfileView()
            
            // Mock verileri dolduruyoruz
            view.profileService.user = UserProfile(
                id: 1, username: "James Parlor", email: "james@test.com", profile_image: "James_Profile",
                follower_count: 72, following_count: 15, post_count: 2, adopted_count: 5,
                donation_total: "3k+", feeding_count: 72, title: "Pet Owner"
            )
            
            // Mock bir post ekleyelim ki boş görünmesin
            view.profileService.posts = [
                Post(id: 1, user_id: 1, content: "Merhaba! Bu bir önizleme postudur.", image_url: "dog_sample", likes_count: 5, isLiked: true)
            ]
            
            return view
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
