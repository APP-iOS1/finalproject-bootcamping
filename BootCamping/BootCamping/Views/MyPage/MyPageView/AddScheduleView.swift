//
//  AddScheduleView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/20.
//

import SwiftUI

struct AddScheduleView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
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
            Group {
                HStack{
                    Button(action: {
                        // TODO: 시작일부터 종료일까지 각각의 날짜에 대해 캠핑 스케줄 추가해주어야 함
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("등록")
                    }
                    Spacer()
                        .frame(width: UIScreen.screenWidth*0.2)
                    Button(action: {
                        
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("닫기")
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: -View : updateUserPhoneNumberTextField
    private var titleTextField : some View {
        VStack(alignment: .leading, spacing: 10){
            Text("캠핑장 이름")
                .font(.title3)
                .bold()
            // TODO: autocomplete textfield,,? T^T
            TextField("캠핑장이름", text: $campingSpot)
        }
    }
}



struct AddScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        AddScheduleView()
    }
}
