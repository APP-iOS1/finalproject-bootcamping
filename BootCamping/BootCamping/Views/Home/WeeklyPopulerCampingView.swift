//
//  WeeklyPopulerCampingView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct WeeklyPopulerCampingView: View {
    //TODO: - 좋아요 많이 받은 글 10개만 뜰 수 있도록
    @EnvironmentObject var diaryStore: DiaryStore
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(diaryStore.diaryList, id: \.self) { item in
                        if item.diaryIsPrivate == false {
                            NavigationLink {
                                DiaryDetailView(item: item)
                            } label: {
                                ZStack(alignment: .leading) {
                                    PhotoCardFrame(image: item.diaryImageURLs[0])
                                    LinearGradient(gradient: Gradient(colors: [Color.bcBlack.opacity(0.3), Color.clear]), startPoint: .top, endPoint: .bottom)
                                        .cornerRadius(20)
                                    PhotoMainStory(item: item)
                                        .offset(y: -(UIScreen.screenHeight * 0.2))
                                }
                                .modifier(PhotoCardModifier())
                            }
                        } else {
                            EmptyView()
                        }
                        
                    }
                    
                }
            }
        }
    }
}

//MARK: - 포토카드 위 글씨
struct PhotoMainStory: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore

    var item: Diary
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("\(item.diaryVisitedDate.getKoreanDate())")
                    .font(.subheadline)
                    .padding(.bottom, 0.01)
                
                //TODO: -캠핑장 이름 연결
                Text("난지캠핑장")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom, UIScreen.screenHeight * 0.03)
                
                Text(item.diaryTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 0.01)
                
                Text("by \(item.diaryUserNickName)")
                    .font(.subheadline)
            }
            .foregroundColor(.white)
            .kerning(-0.7)
            .padding(.horizontal)
        }
//        .onAppear {
//            wholeAuthStore.readUserListCombine()
//        }
    }
}

//MARK: - 포토카드 프레임
struct PhotoCardFrame: View {
    var image: String
    
    var body: some View {
        WebImage(url: URL(string: image))
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.screenWidth * 0.75, height: UIScreen.screenHeight * 0.7)
            .clipped()
            .cornerRadius(20)
            .overlay(alignment: .bottomTrailing, content: {
                Text("자세히 보기 >")
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
            })
    }
}

//MARK: - 서버에서 받아오는 뷰라 프리뷰 불가능합니다.
//struct WeeklyPopulerCampingView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeeklyPopulerCampingView()
//            .environmentObject(DiaryStore())
//            .environmentObject(AuthStore())
//    }
//}
