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
//                                    .font(.title3)
                                    .padding(4)
                                    .foregroundColor(.white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.bcGreen)
                                    )
                                    .padding(3)
                            .opacity(index == 0 ? 1 : 0)
                        }
//                    Text("\(index+1)/\(diaryImages.count)")
//                        .padding(5)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color.bcDarkGray)
//                                .opacity(0.3)
//                        )
                }

            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(.page)
    }
}

//struct DiaryAddDetailImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        DiaryAddDetailImageView()
//    }
//}
