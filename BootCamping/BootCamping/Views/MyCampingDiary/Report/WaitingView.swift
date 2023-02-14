//
//  WaitingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/14.
//

import SwiftUI

struct WaitingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center, spacing: 50){
            Image(systemName: "exclamationmark.circle")
                .frame(width: UIScreen.screenWidth*0.3, height: UIScreen.screenWidth*0.3)
                .foregroundColor(Color.accentColor)
            Text("익명의 사용자에게 이미 신고되어 관리자의 검토를 기다리는 게시물입니다.")
        }
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView()
    }
}
