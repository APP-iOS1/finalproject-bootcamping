//
//  AddScheduleView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/20.
//

import SwiftUI

struct AddScheduleView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var scheduleStore: ScheduleStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var localNotificationCenter: LocalNotificationCenter
    

    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var campingSpotItem: Item = CampingSpotStore().campingSpot
    
    @State private var campingSpot: String = ""
    @State private var ischeckingDate = true
    @State private var isSettingNotification = true
    
    @State private var selectedColor: String = "BCGreen"
    @State private var showColorPicker = false
    
    // 캠핑 종료일이 시작일보다 늦어야 하므로 종료일 날짜 선택 범위를 제한해준다.
    var dateRange: ClosedRange<Date> {
        let max = Calendar.current.date(
            byAdding: .year,
            value: 10,
            to: endDate
        )!
        return startDate...max
    }
    
    var isAddingDisable: Bool {
        return ischeckingDate
        // TODO: - 패치 함수 수정 후 campingSpot == "" || isAddingDisable로 수정해야 함
        //        return campingSpot == "" || ischeckingDate
    }
    
    var alert: String {
        if campingSpot != "" {
            if ischeckingDate { return "날짜를 다시 선택해주세요\n하루에 한 개의 캠핑일정만 등록 가능합니다"}
            return ""
        }
        return "캠핑장 이름을 입력해주세요"
    }
    
    //onAppear 시 캠핑장 데이터 패치
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
            VStack{
                DatePicker(
                    "캠핑 시작일",
                    selection: $startDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.automatic)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .environment(\.calendar, Calendar(identifier: .gregorian))
                .environment(\.timeZone, TimeZone(abbreviation: "KST")!)
                DatePicker(
                    "캠핑 종료일",
                    selection: $endDate,
                    in: dateRange,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.automatic)
                .environment(\.locale, Locale(identifier: "ko_KR"))
                .environment(\.calendar, Calendar(identifier: .gregorian))
                .environment(\.timeZone, TimeZone(abbreviation: "KST")!)
                .onChange(of: startDate) { newStartDate in
                    if endDate < newStartDate {
                        endDate = newStartDate
                    }
                }
                colorPicker
                setNotificationToggle
            }
            Spacer()
                .frame(maxHeight: .infinity)
            alertText
            addScheduleButton
                .padding(.vertical, UIScreen.screenHeight*0.05)
        }
        .onAppear{
            ischeckingDate = checkSchedule(startDate: startDate, endDate: endDate)
            campingSpot = campingSpotItem.facltNm
            //TODO: -패치데이터
            //            Task {
            //                campingSpotStore.campingSpotList = try await fetchData.fetchData(page: page)
            //            }
            
        }
        .onChange(of: [self.startDate, self.endDate]) { newvalues in
            ischeckingDate = checkSchedule(startDate: newvalues[0], endDate: newvalues[1])
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
                        SearchByCampingSpotNameView(campingSpot: $campingSpotItem)
                    } label: {
                        HStack{
                            Text("방문할 캠핑장 등록하러 가기")
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
                let interval = Int(endDate.timeIntervalSince(startDate))
                let days = (interval % 86400 == 0 ? (interval / 86400) : (interval / 86400) + 1)
                for day in 0...days {
                    print(calendar.date(byAdding: .day, value: day, to: startDate) ?? Date())
                    scheduleStore.createScheduleCombine(schedule: Schedule(id: UUID().uuidString, title: campingSpot, date: calendar.date(byAdding: .day, value: day, to: startDate) ?? Date(), color: selectedColor))
                }
            } else {
                scheduleStore.createScheduleCombine(schedule: Schedule(id: UUID().uuidString, title: campingSpot, date: startDate, color: selectedColor))
            }
            scheduleStore.readScheduleCombine()
//            if isSettingNotification{
//                localNotification.setNotification(startDate: startDate)
//            }
            dismiss()
        } label: {
            Text("등록")
                .font(.headline)
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.07)
                .foregroundColor(.white)
                .background(isAddingDisable ? Color.secondary : Color.bcGreen)
                .cornerRadius(10)
        }
        .disabled(isAddingDisable)
    }
    // MARK: -View : colorPicker
    private var colorPicker: some View{
        VStack(alignment: .leading){
            DisclosureGroup(isExpanded: $showColorPicker, content: {
                HStack(spacing: 10){
                    Group{
                        colorButton(selectedColor: $selectedColor, color: "taskRed")
                        colorButton(selectedColor: $selectedColor, color: "taskOrange")
                        colorButton(selectedColor: $selectedColor, color: "taskYellow")
                        colorButton(selectedColor: $selectedColor, color: "taskGreen")
                        colorButton(selectedColor: $selectedColor, color: "taskTeal")
                        colorButton(selectedColor: $selectedColor, color: "taskBlue")
                        colorButton(selectedColor: $selectedColor, color: "taskPurple")
                        Button {
                            selectedColor = "BCGreen"
                        } label: {
                            Circle()
                                .stroke(Color.bcGreen, lineWidth: 2)
                                .frame(width: 25, height: 25)
                                .overlay(
                                    Image(systemName: "xmark")
                                        .font(.headline)
                                )
                        }
                    }
                }
                .frame(width: UIScreen.screenWidth, height: 40)
            },label: {
                HStack {
                    Text("색상")
                        .foregroundColor(Color.bcBlack)
                    Image(systemName: "flag.fill")
                        .foregroundColor(Color[selectedColor])
                }
            })
        }
    }
    // MARK: -View : alertText
    private var alertText : some View {
        Text(alert)
            .font(.caption)
            .foregroundColor(Color.bcDarkGray)
            .multilineTextAlignment(.center)
    }
}

struct colorButton: View{
    @Binding var selectedColor: String
    let color: String
    
    var body: some View{
        Button {
            selectedColor = color
        } label: {
            Circle()
                .fill(Color[color])
                .frame(width: 25, height: 25)
                .overlay(
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color.white)
                        .opacity((selectedColor == color ? 1 : 0))
                        .font(.headline)
                )
        }
    }
}
