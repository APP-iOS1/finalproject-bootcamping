//
//  FaceId.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/03.
//

import Foundation
import LocalAuthentication

class FaceId: ObservableObject {
    @Published var islocked: Bool = true
    
    //    func auth() {
    //        let context = LAContext()
    //        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "인증이 필요합니다") {
    //            [weak self] (res, err) in
    //            DispatchQueue.main.async {
    //                self?.loggedIn = res
    //            }
    //        }
    //    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        self.islocked = false
                    } else {
                        // there was a problem
                        self.islocked = true
                    }
                }
                
            }
        } else {
            // no biometrics
        }
    }
}


//faceid 참고링크
//https://dev.classmethod.jp/articles/ios-biometrics-authentication-kr/
//https://velog.io/@code_gg_/SwiftUI-FaceID-구현하기
