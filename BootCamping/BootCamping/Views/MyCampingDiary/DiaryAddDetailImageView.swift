//
//  DiaryAddDetailImageView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/02/14.
//

import SwiftUI

//
//  DiaryAddDetailImageView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/02/14.
//

import SwiftUI

struct DiaryAddDetailImageView: View {
    @Binding var diaryImages: [Data]
    @Binding var isImageView: Bool
    
    var body: some View {
        TabView{
            ForEach(Array(zip(0..<(diaryImages.count), diaryImages)), id: \.0) { index, image in
                VStack{
                    Image(uiImage: UIImage(data: image)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                        .clipped()
                        .overlay(alignment: .topLeading) {
                            Text("대표 이미지")
                                .padding(4)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.bcGreen)
                                )
                                .padding(3)
                                .opacity(index == 0 ? 1 : 0)    // 첫 번째 사진만 대표 이미지 표시 됨
                        }
                }
            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(.page)
    }
}

