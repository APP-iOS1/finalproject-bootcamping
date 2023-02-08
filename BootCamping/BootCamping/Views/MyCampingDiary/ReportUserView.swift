//
//  ReportUserView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/08.
//

import SwiftUI

struct ReportUserView: View {
    @State var blockUser: Bool = false
    @State private var diaryContent: String = ""
    
    @State private var shouldShowDropdown = false
    @State private var selectedOption: DropdownOption? = nil
    var placeholder: String
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    private let buttonHeight: CGFloat = 45
    
    
    var body: some View {
        VStack(alignment: .leading) {

                Text("신고 사유를 선택해 주세요.")
                .font(.title3)
                .padding(.bottom, 1)
                Text("* 회원님의 신고는 익명으로 처리됩니다. (지식재산권 침해의 경우 제외)")
                    .foregroundColor(.gray)
                    .font(.footnote)
                    .kerning(-1)
                    .padding(.bottom, 10)
            
            
            // MARK: - 신고 드롭다운 버튼
            Button(action: {
                self.shouldShowDropdown.toggle()
            }) {
                HStack {
                    Text(selectedOption == nil ? placeholder : selectedOption!.value)
                        .font(.callout)
                        .foregroundColor(selectedOption == nil ? Color.gray: Color.black)
                    
                    Spacer()
                    
                    Image(systemName: self.shouldShowDropdown ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 9, height: 5)
                        .font(.callout)
                        .foregroundColor(Color.black)
                }
            }
            .padding(.horizontal)
            .cornerRadius(5)
            .frame(width: UIScreen.screenWidth * 0.94, height: 45)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .overlay(
                VStack {
                    if self.shouldShowDropdown {
                        Spacer(minLength: buttonHeight + 5)
                        Dropdown(options: self.options, onOptionSelected: { option in
                            shouldShowDropdown = false
                            selectedOption = option
                            self.onOptionSelected?(option)
                        })
                    }
                }, alignment: .topLeading
            )
            .background(
                RoundedRectangle(cornerRadius: 5).fill(Color.bcWhite)
            )
            // MARK: - 신고 사유 작성 텍스트필드 : 반투명...문제로 지워둠
//                reportUserField
//                .padding(.vertical)
            
            // MARK: - 유저 차단 체크박스
           Spacer()
            VStack {
                Button {
                    blockUser.toggle()
                } label: {
                    HStack {
                        Image(systemName: blockUser ? "checkmark.square" : "square")
                        Text("이 사용자의 글 다시 보지 않기")
                    }
                    .foregroundColor(Color.bcBlack)
                    }
                .padding()
                
                // MARK: - 신고하기 버튼
                Button {
                    // TODO: 신고 기능 추가
                } label: {
                    Text("부트캠핑팀에 신고하기")
                        .modifier(GreenButtonModifier())
                }
            }
            Spacer()
        }
        .navigationTitle("신고하기")
    }
}


// MARK: - 신고사유작성 텍스트필드

private extension ReportUserView {
    var reportUserField: some View {
        VStack {
            TextField("신고 사유를 작성해주세요. (선택)", text: $diaryContent, axis: .vertical)
                .padding()
                .frame(width: UIScreen.screenWidth * 0.94, height: 250, alignment: .top)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .background {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(.gray, lineWidth: 1)
                }
                .submitLabel(.done)

        }
    }
}

// MARK: - 드롭다운, 옵션 구조체

struct DropdownOption: Hashable {
    let key: String
    let value: String
    
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }
}

struct Dropdown: View {
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.options, id: \.self) { option in
                    DropdownRow(option: option, onOptionSelected: self.onOptionSelected)
                }
            }
            .background(Color.bcWhite)
            .frame(width: UIScreen.screenWidth * 0.94, height: 210)
            .padding(.vertical, 5)
            .cornerRadius(5)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
//            // .background(.white)
        )
    }
}

struct DropdownRow: View {
    var option: DropdownOption
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    
    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.value)
                    .font(.callout)
                    .foregroundColor(Color.black)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}




// MARK: - 프리뷰, 드롭다운 신고사유 옵션
struct ReportUserView_Previews: PreviewProvider {
    static var uniqueKey: String {
        UUID().uuidString
    }
    
    static let options: [DropdownOption] = [
        DropdownOption(key: uniqueKey, value: "부적절한 홍보/도배"),
        DropdownOption(key: uniqueKey, value: "음란성/도박 등 불법성"),
        DropdownOption(key: uniqueKey, value: "비방/욕설"),
        DropdownOption(key: uniqueKey, value: "혐오 발언 또는 상징"),
        DropdownOption(key: uniqueKey, value: "지식재산권 침해"),
        DropdownOption(key: uniqueKey, value: "기타")
    ]
    
    static var previews: some View {
        Group {
            ReportUserView(
                placeholder: "이 게시물을 신고하는 이유",
                options: options,
                onOptionSelected: { option in
                    print(option)
                })
        }
    }
}
