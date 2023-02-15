//
//  BusinessView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/15.
//

import SwiftUI

struct BusinessView: View {
    @State private var mailData = ComposeMailData(subject: "문의 제목을 입력해주세요.",
                                                  recipients: ["bootcampingteam@gmail.com"],
                                                  message: "문의사항 내용을 작성해주세요.")
    
    @State private var showMailView = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: UIScreen.screenWidth*0.03){
            Text("비즈니스 문의")
                .fontWeight(.heavy)
                .font(.title2)
            Divider()
            Text("광고, 입점 등의 문의는\n bootcampteam@gmail.com으로 연락주세요.")
                .padding(.bottom, 10)
            Link("홈페이지 링크", destination: URL(string: "https://www.notion.so/thekoon0456/BootCamping-5e0a340949c24aec8c76913a84407c52")!)
                .fontWeight(.heavy)
                .font(.title3)
            Spacer()
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
                        .foregroundColor(Color.bcGreen)
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

struct BusinessView_Previews: PreviewProvider {
    static var previews: some View {
        BusinessView()
    }
}
