//
//  PrivacyView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/02/06.
//

import SwiftUI

struct PrivacyView: View {
    @State var showingAlert: Bool = false
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var tabSelection: TabSelector
    @EnvironmentObject var faceId: FaceId
    @Environment(\.dismiss) private var dismiss
    //faceId 사용 여부 토글 변수
    @AppStorage("faceId") var usingFaceId: Bool = false
    //faceId 잠금 설정 변수
    @AppStorage("toggleUsingFaceId") var toggleUsingFaceId: Bool = false
    
    var body: some View {
        VStack {
            if faceId.islocked == false {
                List{
                    isUsingFaceIdSetting
                    
                    NavigationLink {
                        BlockUserEditView()
                    } label: {
                        Text("차단한 멤버 관리")
                    }
                    if wholeAuthStore.loginPlatform == "email" {
                        NavigationLink {
                            PasswordChangeView()
                        } label: {
                            Text("비밀번호 재설정")
                        }
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
                            diaryStore.updateDiarysNickNameCombine(userUID: wholeAuthStore.currentUser!.uid, nickName: "(사용자 정보 없음)")
                            wholeAuthStore.userWithdrawal()
                            dismiss()
                            tabSelection.screen = .one
                        })
                        )
                    }
                }
                .listStyle(.plain)
            } else {
                DiaryLockedView()
            }
        }
        .onAppear {
            faceId.islocked = true
            faceId.authenticate()
        }
    }
}

private extension PrivacyView {
    
    //MARK: - faceId On/Off 설정 버튼입니다
    var isUsingFaceIdSetting: some View {
        HStack {
            Toggle(isOn: $toggleUsingFaceId) {
                Text("내 캠핑 노트 잠그기")
            }
            .toggleStyle(SwitchToggleStyle(tint: .bcGreen))
            .onChange(of: toggleUsingFaceId) { _ in
                if toggleUsingFaceId {
                    usingFaceId = true
                    faceId.islocked = true
                } else {
                    usingFaceId = false
                    faceId.islocked = false
                }
            }
        }
    }
}

