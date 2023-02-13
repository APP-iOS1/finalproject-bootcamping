//
//  OnboardingTabView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import SwiftUI

struct OnboardingTabView: View {
    @Binding var isFirstLaunching: Bool
    
    var body: some View {
        TabView {
            // 페이지 1: 캠핑장
            DescribeCampView()
            
            // 페이지 2: 사진공유
            DescribePictureView()
            
            // 페이지 3: 캠핑일기
            DescribeDiaryView(isFirstLaunching: $isFirstLaunching)
            
        }
        .ignoresSafeArea()
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
