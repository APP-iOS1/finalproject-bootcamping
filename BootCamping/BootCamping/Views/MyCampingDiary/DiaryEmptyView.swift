//
//  DiaryEmptyView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/08.
//

import SwiftUI

struct DiaryEmptyView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "tray")
                .font(.largeTitle)
            Text("내 캠핑일기가 아직 없어요.")
                .font(.title3)
                .padding()
                .padding(.bottom, 50)

            NavigationLink (destination: DiaryAddView()){
                Text("캠핑일기 작성하러 가기")
                    .modifier(GreenButtonModifier())
            }
            Spacer()
        }
    }
}
