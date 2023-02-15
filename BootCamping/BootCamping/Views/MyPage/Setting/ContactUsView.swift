//
//  ContactUsView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import SwiftUI

struct ContactUsView: View {
    @State private var mailData = ComposeMailData(subject: "문의 제목을 입력해주세요.",
                                                  recipients: ["thekoon0456+bootcamping@gmail.com"],
                                                  message: "문의사항 내용을 작성해주세요.")
   @State private var showMailView = false
    
    var body: some View {
        VStack {
            Text("자주 묻는 질문 넣어야해요~")
                .font(.title)
            
            Button(action: {
                showMailView.toggle()
            }) {
                Text("문의 메일 작성하기")
                    .modifier(GreenButtonModifier())
            }.disabled(!MailView.canSendMail)
                .sheet(isPresented: $showMailView) {
                    MailView(data: $mailData) { result in
                        print(result)
                    }
                }
                
        }.navigationTitle("Q&A")
    }
}
