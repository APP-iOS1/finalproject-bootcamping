//
//  ReportUserView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/08.
//

import SwiftUI
import Firebase


struct ReportUserView: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var blockedUserStore: BlockedUserStore
    
    @State var blockUser: Bool = false
    @State private var diaryContent: String = ""
    
    @State private var shouldShowDropdown = false
    
    @State var placeholder: String
    private let buttonHeight: CGFloat = 45
    @State private var reason: DropdownMenuOption? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("신고 사유를 선택해 주세요.")
                .font(.title3)
                .padding(.top, 10)
                .padding(.bottom, 1)
            Text("* 회원님의 신고는 익명으로 처리됩니다. (지식재산권 침해의 경우 제외)")
                .foregroundColor(.gray)
                .font(.footnote)
                .kerning(-1)
                .padding(.bottom, 10)
            
            // MARK: - 신고 드롭다운 버튼
//            ReportUser(
//                selectedOption: self.$reason, placeholder: "이 게시물을 신고하는 이유", options: DropdownMenuOption.ReportReason)
//            .frame(width: UIScreen.screenWidth * 0.94, height: 35)
            
            // MARK: - 신고 사유 작성 텍스트필드
            reportUserField
                .padding(.vertical)
            
            Spacer()
            
            // MARK: - 신고하기 버튼
            VStack {
                Button {
                    // TODO: 이메일 전송 기능 추가
                    
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


// MARK: - 프리뷰, 드롭다운 신고사유 옵션
//struct ReportUserView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReportUserView(user: <#User#>, placeholder: <#String#>)
//    }
//}
