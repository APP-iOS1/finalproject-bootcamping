//
//  DescribePictureView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import SwiftUI

struct DescribePictureView: View {
    var body: some View {
        ZStack {
            Color.bcYellow
                .ignoresSafeArea()
            VStack {
                LottieView_onboard(filename: "picture_lottie")
                    .frame(width: 250, height: 250)
                    .offset(x: 0, y: -150)
                VStack {
                    Text("나만 보기 아까운 내 캠핑 사진을")
                        .padding(.bottom, 1)
                    Text("캠퍼들과 공유할 수 있어요!")
                }
                .font(.title2)
                .kerning(-1)
                .padding(.top, -80)
            }
        }
    }
}
