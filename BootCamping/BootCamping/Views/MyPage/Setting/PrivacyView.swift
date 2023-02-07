//
//  PrivacyView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/02/06.
//

import SwiftUI

struct PrivacyView: View {
    @State var showingAlert: Bool = false
    @EnvironmentObject var faceId: FaceId
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("faceId") var usingFaceId: Bool = true

    var body: some View {
        List{
            isUsingFaceIdSetting
            NavigationLink {
                PasswordChangeView()
            } label: {
                Text("비밀번호 재설정")
            }
            Button {
                //TODO: 연결하기, 알럿도 띄우기
                showingAlert.toggle()
            } label: {
                Text("회원탈퇴")
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("회원 탈퇴하시겠습니까?"),
                      message: Text("회원 탈퇴 시 모든 데이터는 삭제되며\n" + "복원 불가능한 점을 알려드립니다."),
                      primaryButton: .default(Text("취소"), action: {} ),
                      secondaryButton: .destructive(Text("탈퇴하기"),action: {
                    // 탈퇴 시 무슨 액션?? 새로운 뷰 띄워서 동의하기 체크 후 최종 탈퇴??
                })
                )
            }
        }
        .listStyle(.plain)
    }
}

private extension PrivacyView {
    //MARK: - faceId 설정 토글입니다
    var isUsingFaceIdSetting: some View {
        Toggle(isOn: $usingFaceId) {
            Text("내 캠핑일기 잠그기")
        }
    }

}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
            .environmentObject(FaceId())
    }
}
