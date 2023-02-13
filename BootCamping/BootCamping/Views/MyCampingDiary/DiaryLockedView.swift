//
//  DiaryLockedView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/07.
//

import SwiftUI

struct DiaryLockedView: View {
    @EnvironmentObject var faceId: FaceId
    
    var body: some View {
        VStack(alignment: .center) {
            Text("일기가 잠겨있습니다.")
                .font(.title3)
                .padding()
            
            Button {
                faceId.authenticate()
            } label: {
                Label("잠금 해제하기", systemImage: "lock")
            }
            .modifier(GreenButtonModifier())
        }
    }
}
