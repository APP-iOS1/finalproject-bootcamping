//
//  TaskCellView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/03.
//

import SwiftUI

struct TaskCellView: View{
    @EnvironmentObject var scheduleStore: ScheduleStore
    @EnvironmentObject var localNotificationCenter: LocalNotificationCenter
    
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
            .alert("이 일정을 정말 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert, actions: {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    // 일정 삭제시, 파이어베이스 내에서 삭제하고, 연결된 푸시알림도 삭제한다.
                    scheduleStore.deleteScheduleCombine(schedule: schedule)
                    localNotificationCenter.removeNotifications(selectedDate: schedule.date.formatted()) }
            }
            , message: {
                Text("출발일에 해당되는 일정 삭제시, 관련 일정에 대한 알림 설정이 전체 초기화됩니다.")
            })
        }
        .frame(maxWidth: UIScreen.screenWidth)
        .padding(.vertical, UIScreen.screenHeight * 0.02)
    }
}

// MARK: - 일정 구분선
/// 달력 뷰에서 일정별로 구분해주는 선을 그려주는 구조체로 구분선의 색으로 사용되는 Color를 인자로 받는다
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
