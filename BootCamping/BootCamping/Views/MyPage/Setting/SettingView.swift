//
//  SettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI

// TODO: 목업으로 뷰 추가해놓기
struct SettingView: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    
    //로그아웃 시 탭 변경하기 위한 변수
    @EnvironmentObject var tabSelection: TabSelector
    //로그아웃시 isSignIn을 false로 변경
    //로그아웃 알럿
    @State var showingAlertLogOut: Bool = false
    @AppStorage("login") var isSignIn: Bool?
    //보안설정 들어갈때 페이스id 사용
    @EnvironmentObject var faceId: FaceId
    @AppStorage("faceId") var usingFaceId: Bool?
    
    var body: some View {
        List{
            NavigationLink(destination: EmptyView()) {
                Text("공지사항")
            }
            NavigationLink(destination: ContactUsView()) {
                Text("자주 묻는 질문 FAQ")
            }
            NavigationLink(destination: EmptyView()) {
                Text("앱 정보")
            }
            NavigationLink(destination: NotificationSettingsView()) {
                Text("알림설정")
            }
            NavigationLink(destination: PrivacyView()) {
                Text("개인/보안설정") //페이스아이디, 비밀번호 수정, 회원탈퇴
            }
            Button {
                showingAlertLogOut.toggle()
            } label: {
                Text("로그아웃")
            }
            .alert(isPresented: $showingAlertLogOut) {
                Alert(title: Text("로그아웃하시겠습니까?"),
                      primaryButton: .default(Text("취소"), action: {} ),
                      secondaryButton: .destructive(Text("로그아웃"),action: {
                    tabSelection.screen = .one
                    wholeAuthStore.combineLogOut()
                })
                )
            }
//            Button {
//                // TODO: 회원 탈퇴
//                /// 얼럿 띄우고 탈퇴하는 뷰에 연결하기
//            } label: {
//                Text("회원 탈퇴")
//            }

        }
        .listStyle(.plain)
        .alert("로그아웃에 실패하였습니다. 다시 시도해 주세요.", isPresented: $wholeAuthStore.isError) {
            Button("확인", role: .cancel) {
                wholeAuthStore.isError = false
            }
        }
        
    }
}
