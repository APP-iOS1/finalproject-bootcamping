//
//  ContactUsView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/07.
//

import SwiftUI

struct ContactUsView: View {
    @State private var mailData = ComposeMailData(subject: "A subject",
                                                  recipients: ["contact@bootcamping.com"],
                                                  message: "문의사항을 작성해 주세요.",
                                                  attachments: [AttachmentData(data: "Some text".data(using: .utf8)!,
                                                                               mimeType: "text/plain",
                                                                               fileName: "text.txt")
                                                 ])
   @State private var showMailView = false
    
    var body: some View {
        VStack {
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
                
        }
    }
}
