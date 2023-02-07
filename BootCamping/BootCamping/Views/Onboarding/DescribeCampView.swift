//
//  DescribeCampView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import SwiftUI

struct DescribeCampView: View {
    var body: some View {
        ZStack {
            Color.bcYellow
                .ignoresSafeArea()
            VStack {
                LottieView_onboard(filename: "tent")
                    .frame(width: 250, height: 250)
                    .offset(x: 0, y: -150)
                VStack {
                    Text("캠퍼들의 다양한 후기를 통해")
                        .padding(.bottom, 1)
                    Text("뷰 좋은 캠핑장을 찾아보세요!")
                }
                .font(.title2)
                .kerning(-1)
                .padding(.top, -80)
            }
        }
        
    }
}

struct DescribeCampView_Previews: PreviewProvider {
    static var previews: some View {
        DescribeCampView()
    }
}
