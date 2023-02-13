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
            Text("다이어리가 비어있습니다.")
                .font(.title3)
                .padding()

            NavigationLink (destination: DiaryAddView()){
                Text("다이어리 작성하러 가기")
            }
            .modifier(GreenButtonModifier())
        }
    }
}
