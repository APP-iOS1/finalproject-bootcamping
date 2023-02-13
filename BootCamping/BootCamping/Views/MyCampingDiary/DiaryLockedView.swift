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
            Text("버튼을 눌러 잠금을 해제해주세요.")
                .font(.title3)
                .padding()
            
            Button {
                faceId.authenticate()
            } label: {
//                Label("잠금 해제하기", systemImage: "lock")
                Image(systemName: "faceid")
                    .resizable()
                    .frame(width: UIScreen.screenWidth / 4, height: UIScreen.screenWidth / 4)
            }

//            .modifier(GreenButtonModifier())
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
    }
}
