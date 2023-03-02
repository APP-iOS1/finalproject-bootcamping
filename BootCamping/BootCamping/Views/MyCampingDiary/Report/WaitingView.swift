//
//  WaitingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/14.
//

import SwiftUI

// MARK: - WaitingView
/// 중복신고가 불가능하도록 이미 신고된 게시물에 대해서 표시하는 뷰
struct WaitingView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .center, spacing: 20){
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .frame(width: UIScreen.screenWidth*0.2, height: UIScreen.screenWidth*0.2)
                .foregroundColor(Color.accentColor)
            Text("익명의 사용자에게 이미 신고되어 관리자의 검토를 기다리는 게시물입니다.")
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, UIScreen.screenWidth*0.1)
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView()
    }
}
