//
//  FaceId.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/03.
//

import Foundation
import LocalAuthentication

class FaceId: ObservableObject {
    //false: 기본 faceID 설정 해제
    @Published var islocked: Bool = false
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                //인증 완료시
                DispatchQueue.main.async {
                    if success {
                        self.islocked = false
                    } else {
                        self.islocked = true
                    }
                }
                
            }
        } else {
            //인증 실패시
        }
    }
}


//faceid 참고링크
//https://dev.classmethod.jp/articles/ios-biometrics-authentication-kr/
//https://velog.io/@code_gg_/SwiftUI-FaceID-구현하기
