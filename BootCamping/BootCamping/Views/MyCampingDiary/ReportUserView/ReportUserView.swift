//
//  ReportUserView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/08.
//

import SwiftUI

struct ReportUserView: View {
    @State private var selectedOption: String? = nil
    
    let reportOptions: [String] = [
        "부적절한 홍보/도배",
        "음란성/도박 등 불법성",
        "비방/욕설",
        "혐오 발언 또는 상징",
        "지식재산권 침해",
        "마음에 들지 않음",
        "기타"
    ]
    
    var body: some View {
        VStack{
            VStack{
                Text("이 게시물을 신고하는 이유")
                    .font(.headline)
                Text("어쩌고저쩌고샬라샬라\n어쩌고저쩌고샬라샬라\n어쩌고저쩌고샬라샬라")
                    .font(.caption)
            }
            .padding(.vertical, UIScreen.screenHeight*0.02)
            List {
                ForEach(0..<reportOptions.count, id: \.self) { index in
                    Button {
                        selectedOption = reportOptions[index]
                    } label: {
                        HStack{
                            Text("\(reportOptions[index])")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
