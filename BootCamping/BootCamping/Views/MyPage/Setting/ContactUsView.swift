//
//  ContactUsView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import SwiftUI

struct ContactUsView: View {
    let qnaList: [QnA] = [QnA(question: "이메일로 회원가입은 안 되나요?",
                              answer: """
                            네. 현재로서는 애플, 카카오, 구글을 통한 소셜 로그인만 가능합니다.
                            감사합니다.
                            """),
                          QnA(question: "운영중인 캠핑장을 등록하고 싶어요.",
                              answer: """
                            부트캠핑 입점 광고를 원하실 경우 우측 상단의 1:1 문의를 통해 메일 주시면 빠른 시일내로 답변 드리겠습니다.
                            감사합니다.
                            """)]
    
    
    @State private var mailData = ComposeMailData(subject: "문의 제목을 입력해주세요.",
                                                  recipients: ["bootcampingteam@gmail.com"],
                                                  message: "문의사항 내용을 작성해주세요.")
    @State private var showMailView = false
   
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIScreen.screenWidth*0.03){
            Text("자주 묻는 문의")
                .fontWeight(.heavy)
                .font(.title2)
            Divider()
            ScrollView(showsIndicators: false){
                LazyVStack{
                    ForEach(qnaList, id: \.self) { qna in
                        QuestionCell(qna: qna)
                        Divider()
                    }
                }
            }
            .padding(.horizontal, UIScreen.screenWidth*0.03)
        }
        .padding(UIScreen.screenWidth*0.03)
        .foregroundColor(Color.bcBlack)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showMailView.toggle()
                }) {
                    Text("1:1 문의")
                        .foregroundColor(Color.secondary)
                }.disabled(!MailView.canSendMail)
                    .sheet(isPresented: $showMailView) {
                        MailView(data: $mailData) { result in
                            print(result)
                        }
                    }
            }
        }
        .navigationTitle("고객 문의")
    }
}


struct QuestionCell: View{
    let qna: QnA
    @State private var isShowingAnswer = false
    
    var body: some View {
        VStack(alignment: .leading){
            Button {
                isShowingAnswer.toggle()
            } label: {
                HStack(alignment: .center) {
                    Text("\(qna.question)")
                    Spacer()
                    Image(systemName: isShowingAnswer == true ? "chevron.up" : "chevron.down")
                }
                .padding(.vertical, UIScreen.screenHeight*0.01)
            }
            if isShowingAnswer {
                Text("\(qna.answer)")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(Color.bcBlack.opacity(0.1))
                    )
                    .padding(.horizontal, UIScreen.screenWidth*0.03)
                    .padding(.bottom, UIScreen.screenHeight*0.01)
            }
        }
    }
}

struct QnA: Hashable {
    let question: String
    let answer: String
}
