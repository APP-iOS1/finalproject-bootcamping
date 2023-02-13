//
//  TaskCellView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/03.
//

import SwiftUI

struct TaskCellView: View{
    @EnvironmentObject var scheduleStore: ScheduleStore
    
    @State private var isShowingDeleteAlert = false
    
    let month: String
    let day: String
    let schedule: Schedule
    let color: String
    
    var body: some View {
        HStack {
            ExDivider(color: Color[color])
                .padding(.trailing, UIScreen.screenWidth*0.05)
            VStack(alignment: .leading, spacing: 5) {
                Text("\(month).\(day) 캠핑 일정")
                    .foregroundColor(Color.bcDarkGray)
                    .font(.body.bold())
                Text("\(schedule.title)")
                    .font(.title3.bold())
            }
            Spacer()
            Button {
                isShowingDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(Color[color])
            }
            /// ios15부터 .alert 형태로 사용
            .alert("이 일정을 정말 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    scheduleStore.deleteScheduleCombine(schedule: schedule)
                }
            }
        }
        .frame(maxWidth: UIScreen.screenWidth)
        .padding(.vertical, UIScreen.screenHeight * 0.02)
    }
}

//MARK: 일정 구분선
///달력 뷰에서 일정별로 구분해주는 선을 그려주는 구조체입니다. Color를 인자로 받습니다.
///해당 색은 구분선의 색으로 사용됩니다.
struct ExDivider: View {
    let color: Color
    let width: CGFloat = 5
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(color)
            .frame(width: width, height: 60)
        //            .edgesIgnoringSafeArea(.horizontal)
    }
}
