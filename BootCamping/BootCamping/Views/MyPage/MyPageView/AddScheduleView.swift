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
    
    @State var startDate = Date()
    @State var endDate = Date()
    @State private var campingSpot: String = ""
    
    // 캠핑 종료일이 시작일보다 늦어야 하므로 종료일 날짜 선택 범위를 제한해준다.
    var dateRange: ClosedRange<Date> {
        let max = Calendar.current.date(
            byAdding: .year,
            value: 10,
            to: endDate
        )!
        return startDate...max
    }
    
    var body: some View {
        // FIXME: 여행 일정의 첫 날과 마지막 날을 선택하면 범위 선택이 가능해야 함
        VStack{
            Spacer()
            titleTextField
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
            Spacer()
            addScheduleButton
                .padding(.bottom, 50)
        }
        .padding(.horizontal)
    }
    
    // MARK: -View : 캠핑장 이름 titleTextField
    private var titleTextField : some View {
        VStack(alignment: .leading, spacing: 10){
            NavigationLink {
                SearchCampingSpotListView()
            } label: {
                HStack{
                    Text("캠핑장 이름 검색하기")
                        .font(.title3)
                        .bold()
                    Image(systemName: "magnifyingglass")
                }
            }
            
            TextField("캠핑장 이름 직접 입력하기", text: $campingSpot)
                .textFieldStyle(.roundedBorder)
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
                    print(day)
                    scheduleStore.addSchedule(Schedule(id: UUID().uuidString, title: campingSpot, date: calendar.date(byAdding: .day, value: day, to: startDate) ?? Date()))
                }
            } else {
                scheduleStore.addSchedule(Schedule(id: UUID().uuidString, title: campingSpot, date: startDate))
            }
        } label: {
            Text("등록")
                .modifier(GreenButtonModifier())
        }
    }
}



struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
    }
}
