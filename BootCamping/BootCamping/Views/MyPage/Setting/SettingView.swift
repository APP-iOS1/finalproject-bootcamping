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

    
    var body: some View {
        List{
            NavigationLink(destination: EmptyView()) {
                Text("공지사항")
            }
            NavigationLink(destination: EmptyView()) {
                Text("자주 묻는 질문")
            }
            NavigationLink(destination: ContactUsView()) {
                Text("고객센터")
            }
            NavigationLink(destination: EmptyView()) {
                Text("앱 정보")
            }
            NavigationLink(destination: EmptyView()) {
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
                    wholeAuthStore.googleSignOut()
                    wholeAuthStore.authSignOut()
                    wholeAuthStore.kakaoLogOutCombine()
                    isSignIn = false
                    tabSelection.change(to: .one)
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
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
