//
//  ReportView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/14.
//

import SwiftUI

struct ReportView: View {
    @EnvironmentObject var reportStore: ReportStore
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedOption: String? = nil
    
    let reportedDiaryId: String
    
    let reportOptions: [String] = [
        "나체 이미지 또는 성적 행위",
        "혐오 발언 또는 상징",
        "폭력 또는 위험한 단체",
        "지식재산권 침해",
        "부적절한 홍보/도배",
        "음란성/도박 등 불법성",
        "비방/욕설",
        "마음에 들지 않음",
        "기타"
    ]
    
    var body: some View {
        VStack{
            Text("신고")
                .font(.title3)
                .bold()
                .padding(.vertical, UIScreen.screenHeight*0.02)
            Divider()
            VStack(spacing: 5){
                Text("이 게시물을 신고하는 이유")
                    .font(.headline)
                Text("이 게시물에 대한 회원님의 신고는 익명으로 처리됩니다.")
                    .font(.caption)
                    .foregroundColor(Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, UIScreen.screenHeight*0.02)
            Divider()
            List {
                ForEach(0..<reportOptions.count, id: \.self) { index in
                    Button {
                        selectedOption = reportOptions[index]
                        reportStore.createReportCombine(reportedDiary: ReportedDiary(id: UUID().uuidString, reportedDiaryId: reportedDiaryId, reportOption: selectedOption ?? "기타"))
                        dismiss()
                    } label: {
                        HStack{
                            Text("\(reportOptions[index])")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .frame(height: UIScreen.screenHeight*0.05)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
