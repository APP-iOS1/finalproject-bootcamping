//
//  AddScheduleView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/20.
//

import SwiftUI

struct AddScheduleView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var scheduleStore: ScheduleStore
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @State var startDate = Date()
    @State var endDate = Date()
    @State private var campingSpot: String = ""
    @State private var isAddingDisable = true
    @State private var isSettingNotification = true
    
    // 캠핑 종료일이 시작일보다 늦어야 하므로 종료일 날짜 선택 범위를 제한해준다.
    var dateRange: ClosedRange<Date> {
        let max = Calendar.current.date(
            byAdding: .year,
            value: 10,
            to: endDate
        )!
        return startDate...max
    }

    var alert: String {
        if campingSpot != "" {
            if isAddingDisable { return "날짜를 다시 선택해주세요\n하루에 한 개의 캠핑일정만 등록 가능합니다"}
            return ""
        }
        return "캠핑장 이름을 입력해주세요"
    }

    //onAppear 시 캠핑장 데이터 패치
    @EnvironmentObject var campingSpotStore: CampingSpotStore
    @State var page: Int = 2

    var body: some View {
        // FIXME: 여행 일정의 첫 날과 마지막 날을 선택하면 범위 선택이 가능해야 함
        VStack{
            Spacer()
            Divider()
            titleTextField
                .padding(.vertical, 10)
            Divider()
                .padding(.bottom, 10)
            DatePicker(
                "캠핑 시작일",
                selection: $startDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.automatic)
            DatePicker(
                "캠핑 종료일",
                selection: $endDate,
                in: dateRange,
                displayedComponents: [.date]
            )
            .datePickerStyle(.automatic)
            .onChange(of: startDate) { newStartDate in
                if endDate < newStartDate {
                    endDate = newStartDate
                }
            }
            setNotificationToggle
            Spacer()
                .frame(maxHeight: .infinity)
            alertText
            addScheduleButton
                .padding(.vertical, UIScreen.screenHeight*0.05)
        }
        .onAppear{
            isAddingDisable = checkSchedule(startDate: startDate, endDate: endDate)
            
            Task {
                campingSpotStore.campingSpotList = try await fetchData.fetchData(page: page)
            }
            
        }
        .onChange(of: [self.startDate, self.endDate]) { newvalues in
            isAddingDisable = checkSchedule(startDate: newvalues[0], endDate: newvalues[1])
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
    }
    
    func checkSchedule(startDate: Date, endDate: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let startDate = dateFormatter.string(from: startDate)
        let endDate = dateFormatter.string(from: endDate)
        
        if startDate > endDate {  return true }
        for schedule in scheduleStore.scheduleList{
            let scheduleDate = dateFormatter.string(from: schedule.date)
            if (startDate <= scheduleDate && scheduleDate <= endDate) {
                print("check Schedule returns true")
                return true
            }
        }
        print("check Schedule returns false")
        return false
    }
}

extension AddScheduleView {
    
    // MARK: -View : 캠핑장 이름 titleTextField
    private var titleTextField : some View {
        VStack {
            if campingSpot == "" {
                HStack{
                    NavigationLink {
                        SearchCampingSpotListView(campingSpotName: $campingSpot)
                    } label: {
                        HStack{
                            Text("캠핑장 추가하기")
                                .foregroundColor(.bcBlack)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.bcBlack)
                        }
                    }
                }
            } else {
                HStack {
                    Text("\(campingSpot)")
                        .lineLimit(1)
                    Spacer()
                    Button {
                        campingSpot = ""
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.bcBlack)

                    }

                }
                
            }
        }
    }
    // MARK: -View : setNotificationToggleButton
    private var setNotificationToggle: some View{
        Toggle(isOn: self.$isSettingNotification) {
                Text("스케줄에 대한 알림 수신")
        }
    }
    // MARK: -View : addScheduleButton
    private var addScheduleButton : some View {
        Button {
            let calendar = Calendar.current
            if endDate.timeIntervalSince(startDate) > 0 {
                let interval = endDate.timeIntervalSince(startDate)
                let days = Int(interval / 86400)
                for day in 0...days {
                    print(calendar.date(byAdding: .day, value: day, to: startDate) ?? Date())
                    scheduleStore.createScheduleCombine(schedule: Schedule(id: UUID().uuidString, title: campingSpot, date: calendar.date(byAdding: .day, value: day, to: startDate) ?? Date()))
                }
            } else {
                scheduleStore.createScheduleCombine(schedule: Schedule(id: UUID().uuidString, title: campingSpot, date: startDate))
            }
            if isSettingNotification{
                scheduleStore.setNotification(startDate: startDate)
            }
            dismiss()
        } label: {
            Text("등록")
                .bold()
            //                    .modifier(GreenButtonModifier())
        }
        .disabled(campingSpot == "" || isAddingDisable)        
    }
    // MARK: -View : alertText
    private var alertText : some View {
        Text(alert)
            .font(.caption)
            .foregroundColor(Color.bcDarkGray)
            .multilineTextAlignment(.center)
    }
}



struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
            .environmentObject(ScheduleStore())
            .environmentObject(CampingSpotStore())
    }
}
