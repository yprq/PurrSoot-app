import SwiftUI

// --- BAŞKASI İÇİN PROFİL EKRANI (KESİN VE TAM HALİ) ---
struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    // --- PROFIL SAHİBİ BİLGİLERİ ---
    let profileOwnerName: String = "Alena Parlor"
    let profileOwnerTitle: String = "Pet Owner"
    let profileOwnerImage: String = "Robert_Pattinson"
    
    // --- DİNAMİK STATS (Birbirine Bağlı) ---
    @State private var isFollowing: Bool = false
    @State private var followerCount: Int = 124
    @State private var otherFollowingCount: Int = 56
    @State private var otherAdoptedCount: Int = 2
    
    // Profil sahibine ait örnek postlar
    @State private var otherUserPosts = [
        UserPost(petImage: "Rectangle 49", selectedImageData: nil, description: "I found this sweet dog and am looking for a loving home for them...", likeCount: 12),
        UserPost(petImage: "Rectangle 45", selectedImageData: nil, description: "This beautiful cat is looking for a home...", likeCount: 8)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // --- 1. ÖZEL HEADER BAR ---
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3).bold()
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44, alignment: .leading)
                        }
                        Spacer()
                        Text("Profile").font(.headline).bold()
                        Spacer()
                        Color.clear.frame(width: 44, height: 44) // Denge için
                    }
                    .padding(.horizontal)
                    .frame(height: 50)

                    ScrollView {
                        VStack(spacing: 25) {
                            
                            // --- 2. PROFİL BİLGİLERİ VE STATS ---
                            VStack(spacing: 20) {
                                HStack(spacing: 15) {
                                    Image(profileOwnerImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.1), radius: 4)
                                    
                                    HStack(spacing: 10) {
                                        OtherUserStatCell(value: otherUserPosts.count, label: "Posts")
                                        OtherUserStatCell(value: followerCount, label: "Followers")
                                        OtherUserStatCell(value: otherFollowingCount, label: "Following")
                                        OtherUserStatCell(value: otherAdoptedCount, label: "Adopted")
                                    }
                                }
                                .padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profileOwnerName).font(.system(size: 22, weight: .bold))
                                    Text(profileOwnerTitle).font(.system(size: 15)).foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            }
                            .padding(.top, 15)

                            // --- 3. ANA FOLLOW BUTONU ---
                            Button(action: { toggleFollowAction() }) {
                                Text(isFollowing ? "Following" : "Follow")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isFollowing ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(isFollowing ? Color.gray.opacity(0.15) : Color(red: 0.44, green: 0.54, blue: 0.47))
                                    .cornerRadius(14)
                            }
                            .padding(.horizontal)

                            // --- 4. POSTLAR ---
                            VStack(spacing: 20) {
                                ForEach(otherUserPosts.indices, id: \.self) { index in
                                    OtherUserProfilePostCard(
                                        post: $otherUserPosts[index],
                                        ownerName: profileOwnerName,
                                        ownerImage: profileOwnerImage,
                                        isFollowing: $isFollowing, // Takip durumunu bağladık
                                        toggleAction: toggleFollowAction // Fonksiyonu bağladık
                                    )
                                }
                            }
                            
                            Spacer(minLength: 50)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // Ortak Takip Fonksiyonu
    func toggleFollowAction() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isFollowing.toggle()
            followerCount += isFollowing ? 1 : -1
        }
    }
}

// --- STATS HÜCRESİ ---
struct OtherUserStatCell: View {
    let value: Int
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)").font(.system(size: 16, weight: .bold))
            Text(label).font(.system(size: 10)).foregroundColor(.gray).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// --- PROFIL SAHİBİNE ÖZEL POST KARTI ---
struct OtherUserProfilePostCard: View {
    @Binding var post: UserPost
    let ownerName: String
    let ownerImage: String
    @Binding var isFollowing: Bool // Üst barla senkronize
    var toggleAction: () -> Void   // Üstteki fonksiyonu tetikler
    
    @State private var isCommenting: Bool = false
    @State private var commentText: String = ""
    @State private var showPostOptions: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- HEADER ---
            HStack(spacing: 10) {
                Image(ownerImage)
                    .resizable().scaledToFill().frame(width: 38, height: 38).clipShape(Circle())
                VStack(alignment: .leading, spacing: 2) {
                    Text(ownerName).font(.system(size: 14, weight: .bold))
                    Text("Pet Owner").font(.system(size: 12)).foregroundColor(.gray)
                }
                Spacer()
                
                Button(action: { showPostOptions = true }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .frame(width: 44, height: 44, alignment: .trailing)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(15)
            .zIndex(1)
            
            // --- GÖRSEL ---
            Group {
                if let data = post.selectedImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                } else if let assetImage = post.petImage {
                    Image(assetImage).resizable().scaledToFill()
                }
            }
            .frame(height: 220).frame(maxWidth: .infinity).cornerRadius(15).clipped().padding(.horizontal, 10)
            
            // --- ETKİLEŞİM İKONLARI ---
            HStack(spacing: 22) {
                Button(action: {
                    withAnimation(.spring()) {
                        post.isLiked.toggle()
                        post.likeCount += post.isLiked ? 1 : -1
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart").foregroundColor(post.isLiked ? .red : .gray)
                        if post.likeCount > 0 { Text("\(post.likeCount)").font(.caption).foregroundColor(.gray) }
                    }
                }.buttonStyle(.borderless)
                
                Button(action: { withAnimation { isCommenting.toggle() } }) {
                    Image(systemName: "message").foregroundColor(isCommenting ? .blue : .gray)
                }.buttonStyle(.borderless)
                
                Button(action: { sharePost(text: post.description) }) {
                    Image(systemName: "paperplane").foregroundColor(.gray)
                }.buttonStyle(.borderless)
                
                Spacer()
                
                Button(action: { post.isSaved.toggle() }) {
                    Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark").foregroundColor(post.isSaved ? .black : .gray)
                }.buttonStyle(.borderless)
            }
            .font(.system(size: 20)).padding(.horizontal, 18).padding(.vertical, 12)

            // --- YORUM YAZMA ---
            if isCommenting {
                HStack {
                    TextField("Write a comment...", text: $commentText)
                        .font(.system(size: 13)).padding(8).background(Color.white.opacity(0.6)).cornerRadius(8)
                    Button(action: {
                        if !commentText.isEmpty {
                            withAnimation {
                                post.comments.append(commentText)
                                commentText = ""
                                isCommenting = false
                            }
                        }
                    }) { Image(systemName: "paperplane.fill").foregroundColor(.blue) }
                }.padding(.horizontal, 15).padding(.bottom, 10)
            }
            
            // --- YORUMLAR (Dinamik) ---
            if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(post.comments, id: \.self) { comment in
                        HStack(alignment: .top, spacing: 5) {
                            Text("James Parlor").font(.system(size: 13, weight: .bold))
                            Text(comment).font(.system(size: 13))
                        }
                    }
                }.padding(.horizontal, 18).padding(.bottom, 10)
            }
            
            // --- AÇIKLAMA ---
            Text(post.description).font(.system(size: 13)).padding(.horizontal, 18).padding(.bottom, 20)
        }
        .background(Color(red: 0.98, green: 0.92, blue: 0.90))
        .cornerRadius(24).padding(.horizontal, 16)
        // --- ÜÇ NOKTA MENÜSÜ (Bağlantılı) ---
        .confirmationDialog("Post Options", isPresented: $showPostOptions) {
            Button(isFollowing ? "Unfollow \(ownerName)" : "Follow \(ownerName)") {
                toggleAction() // Üstteki fonksiyonu tetikler, her yer güncellenir
            }
            Button("Report Post", role: .destructive) { }
            Button("Cancel", role: .cancel) { }
        }
    }
}

// --- PREVIEW ---
struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView()
    }
}
