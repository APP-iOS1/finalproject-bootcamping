//
//  kakaoLoginViewTEST.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/20.
//

import SwiftUI
import KakaoSDKUser

struct kakaoLoginViewTEST: View {
    @StateObject var kakaoAuthStore: KakaoAuthStore = KakaoAuthStore()
    
    var loginStatusInfo: (Bool) -> String = { isLoggedIn in
        return isLoggedIn ? "로그인 상태" : "로그아웃 상태"
        
    }
    var body: some View {
        VStack{
            Text(loginStatusInfo(kakaoAuthStore.isLoggedIn))
                .padding()
            //카카오 버튼
            Button {
                kakaoAuthStore.handleKakaoLogin()
                // 카카오톡이 설치되어 있는지 확인하는 함수
                } label: {
                    Text("카카오 로그인")
                }
            
            Button {
                kakaoAuthStore.kakaoLogout()
            } label: {
                Text("카카오 로그아웃")
            }

            }
        }
    }


struct kakaoLoginViewTEST_Previews: PreviewProvider {
    static var previews: some View {
        kakaoLoginViewTEST()
    }
}
