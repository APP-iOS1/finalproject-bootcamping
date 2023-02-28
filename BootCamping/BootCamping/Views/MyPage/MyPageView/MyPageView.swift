//
//  MyPage.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

// MARK: - 탭 설정을 위한 enum
enum TapMypage : String, CaseIterable {
    case myCamping = "나의 캠핑 일정"
    case bookmarkedCampingSpot = "북마크한 캠핑장"
}

// MARK: - 마이페이지 첫 화면에 나타나는 뷰
struct MyPageView: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    
    @State private var selectedPicker2: TapMypage = .myCamping
    //로그인 유무 함수
    @AppStorage("login") var isSignIn: Bool?
    
    @Namespace private var animation
    
    //글 작성 유저 닉네임 변수
    var userNickName: String? {
        for user in wholeAuthStore.userList {
            if user.id == Auth.auth().currentUser?.uid {
                return user.nickName
            }
        }
        return nil
    }
    var userImage: String? {
        for user in wholeAuthStore.userList {
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingView()
                    } label: {
                        Image(systemName: "gearshape").foregroundColor(.bcBlack)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                wholeAuthStore.readUserListCombine()
                campingSpotStore.campingSpotList.removeAll()
                campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: wholeAuthStore.currnetUserInfo?.bookMarkedSpot ?? []))
            }
        }
    }
}

extension MyPageView{
    // MARK: -View : 유저 프로필이미지, 닉네임 표시
    private var userProfileSection : some View {
        HStack{
            NavigationLink {
                ProfileSettingView()
                
            } label: {
                HStack(spacing: 20) {
                    if wholeAuthStore.currnetUserInfo?.profileImageURL != "" {
                        WebImage(url: URL(string: wholeAuthStore.currnetUserInfo!.profileImageURL))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } else {
                        Image("defaultProfileImage")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    }
                    
                    Text("\((wholeAuthStore.currnetUserInfo!.nickName)) 님")

                    Group{
                        switch wholeAuthStore.loginPlatform {
                        case "email":
                            Image(systemName: "")
                            
                        case "apple":
                            ZStack{
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 30)
                                Image(systemName: "apple.logo")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15)
                            }
                        case "google":
                            Image("g-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .clipShape(Circle())
                        case "kakao":
                            Image("k-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
                                .clipShape(Circle())
                        case "none":
                            Image(systemName: "")
                            
                        default:
                            Image(systemName: "")
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .bold()
                        .foregroundColor(.bcGreen)
                }
                .foregroundColor(.bcBlack)
            }
            Spacer()
        }
    }
    
    // MARK: 로그인 플랫폼?에 따른 로고
    private var loginLogo: some View {
        Group{
            switch wholeAuthStore.loginPlatform {
            case "email":
                Image(systemName: "")
                
            case "apple":
                ZStack{
                    Circle()
                        .fill(Color.black)
                        .frame(width: 30)
                    Image(systemName: "apple.logo")
                        .resizable()
                        .foregroundColor(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                }
            case "google":
                Image("g-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .clipShape(Circle())
            case "kakao":
                Image("k-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30)
                    .clipShape(Circle())
            case "none":
                Image(systemName: "")
                
            default:
                Image(systemName: "")
            }
        }
        
        
    }
    
    // MARK: -ViewBuilder : 탭으로 일정, 북마크 표시
    @ViewBuilder
    private func animate() -> some View {
        HStack {
            ForEach(TapMypage.allCases, id: \.self) { item in
                VStack {
                    Text(item.rawValue)
                        .font(.title3)
                        .bold()
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
                    self.selectedPicker2 = item
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
                if campingSpotStore.campingSpotList.isEmpty {
                    VStack(alignment: .center) {
                        Text("\n\n\n")
                        Text("캠핑장을 검색해서 북마크해주세요").foregroundColor(Color.bcBlack)
                    }
                } else {
                    VStack(spacing: 10){
                        ForEach(campingSpotStore.campingSpotList, id: \.contentId) { campingSpot in
                            NavigationLink {
                                CampingSpotDetailView(campingSpot: campingSpot)
                            } label: {
                                BookmarkCellView(campingSpot: campingSpot)
                            }
                        }
                    }
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                }
            }
        }
    }
}
