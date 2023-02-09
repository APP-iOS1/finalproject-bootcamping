//
//  MyPage.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

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
        //        .onAppear{
        //            wholeAuthStore.readUserListCombine()
        //        }
    }
    
}

extension MyPageView{
    // MARK: -View : 유저 프로필이미지, 닉네임 표시
    private var userProfileSection : some View {
        HStack{
            if wholeAuthStore.currnetUserInfo?.profileImageURL != "" {
                WebImage(url: URL(string: wholeAuthStore.currnetUserInfo!.profileImageURL))
                    .resizable()
                    .clipShape(Circle())
                .frame(width: 60, height: 60)
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    
            }
            Text("\((wholeAuthStore.currnetUserInfo!.nickName)) 님")
            NavigationLink {
                ProfileSettingView()
                
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
                VStack(spacing: 20){
                    ForEach(campingSpotStore.campingSpotList, id: \.contentId) { campingSpot in
                        NavigationLink {
                            CampingSpotDetailView(places: campingSpot)
                        } label: {
                            BookmarkCellView(campingSpot: campingSpot)
                        }
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
