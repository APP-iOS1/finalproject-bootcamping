//
//  AnnouncementView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/16.
//

import SwiftUI

// MARK: - View: AnnouncementView
/// 공지사항 뷰
struct AnnouncementView: View {
    let announcementList: [QnA] = [QnA(question: "부트캠핑 1.0 출시 소식",
                                       answer: """
                            이용해주셔서 감사합니다.
                            다음 업데이트 때 더 좋은 기능을 가지고 돌아올 수 있게 발전하는 부트캠핑이 되겠습니다.❤️
                            """)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIScreen.screenWidth*0.03){
            ScrollView(showsIndicators: false){
                LazyVStack{
                    ForEach(announcementList, id: \.self) { announcement in
                        QuestionCell(qna: announcement)
                        Divider()
                    }
                }
            }
            .padding(.horizontal, UIScreen.screenWidth*0.03)
        }
        .padding(UIScreen.screenWidth*0.03)
        .foregroundColor(Color.bcBlack)
        .navigationTitle("공지사항")
    }
}
