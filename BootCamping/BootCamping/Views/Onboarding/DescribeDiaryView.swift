//
//  DescribeDiaryView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import SwiftUI

struct DescribeDiaryView: View {
    @Binding var isFirstLaunching: Bool
    var body: some View {
        ZStack {
            Color.bcYellow
                .ignoresSafeArea()
            VStack {
                LottieView_onboard(filename: "diary_lottie")
                    .frame(width: 230, height: 230)
                //    .offset(x: 0, y: -50)
                VStack {
                    Text("프라이빗한 캠핑 일기장에")
                        .padding(.bottom, 1)
                    Text("내 캠핑 일기를 기록해봐요!")
                }
                .font(.title2)
                .kerning(-1)
                .padding(.top, 50)
                .padding(.bottom, 50)
                
                
                VStack {
                    Button {
                        isFirstLaunching = false
                    } label: {
                        Text("부트캠핑 시작하기")
                            .modifier(GreenButtonModifier())
                    }
                }
            }
        }
    }
}

struct DescribeDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DescribeDiaryView(isFirstLaunching: .constant(true))
    }
}
