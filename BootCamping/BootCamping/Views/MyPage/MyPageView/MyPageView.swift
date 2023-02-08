//
//  MyPage.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import Firebase

enum TapMypage : String, CaseIterable {
    case myCamping = "나의 캠핑 일정"
    case bookmarkedCampingSpot = "북마크한 캠핑장"
}

// MARK: - 마이페이지 첫 화면에 나타나는 뷰
struct MyPageView: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore

    @State private var selectedPicker2: TapMypage = .myCamping
    //로그인 유무 함수
    @AppStorage("login") var isSignIn: Bool?
    
    @Namespace private var animation
    
    //글 작성 유저 닉네임 변수
    var userNickName: String? {
        for user in authStore.userList {
            if user.id == Auth.auth().currentUser?.uid {
                return user.nickName
            }
        }
        return nil
    }
    var userImage: String? {
        for user in authStore.userList {
            if user.id == Auth.auth().currentUser?.uid {
                return user.profileImageURL
            }
        }
        return nil
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                userProfileSection
                animate()
                    .padding(.top, UIScreen.screenHeight*0.02)
                myPageTap
            }
            .padding(.horizontal, UIScreen.screenWidth * 0.03)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("마이페이지")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingView()
                    } label: {
                        Image(systemName: "gearshape").foregroundColor(.bcBlack)
                    }
                }
            }
        .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear{
            authStore.fetchUserList()
        }
    }
    
}

extension MyPageView{
    // MARK: -View : 유저 프로필이미지, 닉네임 표시
    private var userProfileSection : some View {
        HStack{
            Image(systemName: userImage != "" ? userImage ?? "person.fill" : "person.fill")
                .resizable()
                .clipShape(Circle())
                .frame(width: 60, height: 60)
                
            Text("\(userNickName ?? "BootCamper") 님")
            NavigationLink {
                ProfileSettingView(user: User(id: "", profileImageName: "", profileImageURL: "", nickName: "\(userNickName ?? "")", userEmail: "", bookMarkedDiaries: [], bookMarkedSpot: []))
                
            } label: {
                Image(systemName: "chevron.right")
                    .bold()
            }
            Spacer()
        }
        
    }
    
    // MARK: -ViewBuilder : 탭으로 일정, 북마크 표시
    @ViewBuilder
    private func animate() -> some View {
        HStack {
            ForEach(TapMypage.allCases, id: \.self) { item in
                VStack {
                    Text(item.rawValue)
                        .font(.callout)
                        .kerning(-1)
                        .foregroundColor(selectedPicker2 == item ? .bcBlack : .gray)
                    
                    if selectedPicker2 == item {
                        Capsule()
                            .foregroundColor(.bcBlack)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "info", in: animation)
                    } else if selectedPicker2 != item {
                        Capsule()
                            .foregroundColor(.clear)
                            .frame(height: 2)
                    }
                }
                .frame(width: UIScreen.screenWidth * 0.47)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.selectedPicker2 = item
                    }
                }
            }
        }
    }
    
    // MARK: -View : 탭뷰에 따라 나의 캠핑 일정, 북마크한 캠핑장 표시
    private var myPageTap : some View {
        VStack {
            switch selectedPicker2 {
            case .myCamping:
                CalendarView()
            case .bookmarkedCampingSpot:
                VStack(spacing: 20){
                    ForEach(0..<5) { _ in
                        BookmarkCellView()
                    }
                }
            }
        }
    }
}


struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
