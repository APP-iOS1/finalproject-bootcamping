//
//  WeeklyPopulerCampingView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI

struct WeeklyPopulerCampingView: View {
    //예시 포토카드 사진
    var homePhotoCards = ["1", "2", "3", "4"]
    //예시 포토카드 글
    var photoCardTestData = [PhotoCardTestData(date: "2023.01.17", campingPlace: "충주호 캠핑월드", title: "충주호 보면서 불멍하기", user: "by User")]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack {
                
                ForEach(homePhotoCards, id: \.self) { item in
                    NavigationLink {
                        WeeklyPopulerCampingDetailView()
                    } label: {
                        ZStack(alignment: .leading) {
                            PhotoCardFrame(image: item)
                            photoMainStory
                                .offset(y: -150)
                        }
                        .modifier(PhotoCardModifier())
                    }
                }
                
            }
        }
    }
    
    //MARK: - 포토카드 위 글씨
    var photoMainStory: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(photoCardTestData[0].date)
                    .font(.subheadline)
                
                Text(photoCardTestData[0].campingPlace)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text(photoCardTestData[0].title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 3)
                Text(photoCardTestData[0].user)
                    .font(.subheadline)
                
            }
            .foregroundColor(.white)
            .kerning(-0.7)
            .padding(.horizontal)
        }
    }
}

//MARK: - 포토카드 프레임
struct PhotoCardFrame: View {
    var image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.screenWidth * 0.75, height: UIScreen.screenHeight * 0.7)
            .cornerRadius(20)
            .overlay(alignment: .bottomTrailing, content: {
                Text("자세히 보기 >")
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
            })
    }
}


//MARK: - 포토카드 테스트 구조체입니다.
struct PhotoCardTestData {
    var date: String
    var campingPlace: String
    var title: String
    var user: String
}

struct WeeklyPopulerCampingView_Previews: PreviewProvider {
    static var previews: some View {
        WeeklyPopulerCampingView()
    }
}
