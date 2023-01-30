//
//  HomeView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI


struct HomeView: View {
    //상단 탭 뷰 선택변수
    @State private var selectedPicker: tapInfo = .weeklyPopulerCamping
    @Namespace private var animation
    
    var body: some View {
        VStack{
            //MARK: - 홈 상단 탭뷰입니다.
            mainTapView(mainTap: selectedPicker)
        }
        .toolbar {
            //TODO: - 앱 로고 위치입니다.
            ToolbarItem(placement: .navigationBarLeading) {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            //MARK: - 홈 상단 피커 애니메이션입니다.
            ToolbarItem(placement: .principal) {
                animate()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    //MARK: - 홈 상단 피커 애니메이션입니다.
    @ViewBuilder
    private func animate() -> some View {
        VStack {
            HStack {
                Spacer()
    
                ForEach(tapInfo.allCases, id: \.self) { item in
                    VStack {
                        Text(item.rawValue)
                            .font(.system(.title3, weight: .heavy))
                            .kerning(-1)
                            .frame(maxWidth: 200, maxHeight: 30)
                            .foregroundColor(selectedPicker == item ? .black : .gray)
                            .padding(.top, 10)
                        
                        if selectedPicker == item {
                            Capsule()
                                .foregroundColor(.black)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "info", in: animation)
                        } else {
                            Capsule()
                                .foregroundColor(.white)
                                .frame(height: 2)
                        }
                    }
                    .frame(width: 110)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            self.selectedPicker = item
                        }
                    }
                }
                
                Spacer()
            }
            .padding(15)
        }

    }

}

enum tapInfo : String, CaseIterable {
    case weeklyPopulerCamping = "주간 인기 캠핑"
    case realtimeCamping = "실시간 캠핑"
}

struct mainTapView : View {
    var mainTap : tapInfo
    var body: some View {
        VStack {
            switch mainTap {
            case .weeklyPopulerCamping:
                NavigationStack {
                    WeeklyPopulerCampingView()
                }
            case .realtimeCamping:
                NavigationStack {
                    RealtimeCampingView()
                }
            }
        }
        
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
