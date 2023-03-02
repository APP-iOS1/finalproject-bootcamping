//
//  AddScheduleView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/20.
//

import SwiftUI

// MARK: - 달력에 캠핑 일정 추가하는 뷰
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
    
    var dateRange: ClosedRange<Date> {
        // 캠핑 종료일이 시작일보다 늦어야 하므로 종료일 날짜 선택 범위를 제한해준다.
        let max = Calendar.current.date(
            byAdding: .year,
            value: 10,
            to: endDate
        )!
        return startDate...max
    }
    
    // FIXME: - 현재 검색이 안 되는 캠핑장의 경우 저장할 수 없는데, 직접 입력이 가능하게 해야 할 것 같다
    // 캠핑장 이름이 비어있거나, 해당 날짜에 이미 캠핑 일정이 존재하는 경우 일정 추가 버튼을 disabled로 만들어 추가할 수 없게 하는 변수
    var isAddingDisable: Bool {
        return campingSpot == "" || ischeckingDate
    }
    
    // 일정 추가 버튼이 disabled 될 때, 일정 추가가 불가능한 사유를 보여주는 함수
    var alert: String {
        if campingSpot != "" {
            if ischeckingDate { return "날짜를 다시 선택해주세요\n하루에 한 개의 캠핑일정만 등록 가능합니다"}
            return ""
        }
        return "캠핑장 이름을 입력해주세요"
    }
    
    var body: some View {
        VStack{
            Spacer()
            Divider()
            titleTextField
                .padding(.vertical, 10)
            Divider()
                .padding(.bottom, 10)
            VStack{
                // FIXME: - DatePicker도 뷰 모디파이어로 설정할 수 있으면 하면 좋을 것 같다
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
            // 처음 선택된 날짜(당일)에 일정이 존재하는지 확인한다
            ischeckingDate = checkSchedule(startDate: startDate, endDate: endDate)
            
            campingSpot = campingSpotItem.facltNm
        }
        // 출발일과 도착일이 변경될 때마다 해당 날짜 내에 일정이 존재하는지 확인한다
        .onChange(of: [self.startDate, self.endDate]) { newvalues in
            ischeckingDate = checkSchedule(startDate: newvalues[0], endDate: newvalues[1])
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
    }
    
    // MARK: - 선택된 날짜에 스케줄 추가가 가능한지 체크해주는 함수
    /// 선택된 날짜 범위 내에 일정 추가가 불가능한(해당 날짜에 일정이 존재하는 경우) 날짜가 포함되어 있는 경우를 체크한다.
    /// 선택된 날짜에 이미 캠핑 일정이 존재하면 true를 반환하고, 존재하지 않으면 false를 반환하여 스케줄이 없음을 나타낸다.
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
        VStack (alignment: .leading){
            Toggle(isOn: self.$isSettingNotification) {
                Text("캠핑 일정에 대한 알림 수신")
            }
            .toggleStyle(SwitchToggleStyle(tint: .bcGreen))
            Text("*알림 수신을 위해 기기의 PUSH 알림 설정이 필요합니다.\n*알림 설정은 '설정 > 알림 > 부트캠핑 > 알림 허용'에서 변경 가능합니다.")
                .frame(height: 40)
                .foregroundColor(Color.secondary)
                .font(.caption)
        }
    }
    // MARK: -View : addScheduleButton
    private var addScheduleButton : some View {
        Button {
            let calendar = Calendar.current
            let interval = Int(endDate.timeIntervalSince(startDate))
            let days = (interval % 86400 == 0 ? (interval / 86400) : (interval / 86400) + 1)
            
            // 출발일과 도착일 사이의 날짜들 각각에 대해서 일정을 추가해준다
            for day in 0...days {
                scheduleStore.createScheduleCombine(schedule: Schedule(id: UUID().uuidString, title: campingSpot, date: calendar.date(byAdding: .day, value: day, to: startDate) ?? Date(), color: selectedColor))
                if day == 0 {
                    // 출발일을 기준으로 푸시 알림을 추가해준다
                    Task{
                        try await localNotificationCenter.addNotification(startDate: startDate)
                    }
                }
            }
            scheduleStore.readScheduleCombine()
            //탭틱
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            dismiss()
        } label: {
            Text("등록")
                .font(.headline)
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.07)
                .foregroundColor(.white)
                .background(isAddingDisable ? Color.secondary : Color.bcGreen)
                .cornerRadius(10)
        }
        // 캠핑장을 선택하지 않았거나, 선택한 날짜중 하루라도 캠핑 일정이 기존에 존재하는 경우 일정을 추가할 수 없다
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

// MARK: -View : 색상 선택 버튼
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
