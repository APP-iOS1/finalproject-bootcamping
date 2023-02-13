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
            //MARK: - 홈 상단 피커 애니메이션입니다.
            ToolbarItem(placement: .principal) {
                animate()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension HomeView {
    //MARK: - 홈 상단 탭 enum입니다.
    enum tapInfo : String, CaseIterable {
        case weeklyPopulerCamping = "주간 인기 캠핑"
        case realtimeCamping = "실시간 캠핑"
    }
    
    //MARK: - 홈 상단 탭
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
    
    //MARK: - 홈 상단 탭 피커 애니메이션 함수입니다.
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
                            .frame(maxWidth: 180, maxHeight: 30)
                            .foregroundColor(selectedPicker == item ? .bcBlack : .gray)
                            .padding(.top, 10)
                        
                        if selectedPicker == item {
                            Capsule()
                                .foregroundColor(.bcBlack)
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "info", in: animation)
                        } else {
                            Capsule()
                                .foregroundColor(.clear)
                                .frame(height: 2)
                        }
                    }
                    .frame(minWidth: 100)
                    .onTapGesture {
                        self.selectedPicker = item
                    }
                }
                
                Spacer()
            }
            .padding(15)
        }
        
    }
}
