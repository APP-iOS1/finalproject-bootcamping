//
//  AuthKakaoService.swift
//  BootCamping
//
//  Created by 박성민 on 2023/02/06.
//

import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser
import Firebase
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// MARK: - 카카오 로그인 서비스

struct AuthKakaoService {
    
    // MARK: - 카카오 로그아웃
    
    func kakaoLogOutService() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            UserApi.shared.logout {(error) in
                if let error = error {
                    print("로그아웃 에러 : \(error)")
                    promise(.failure(AuthServiceError.signOutError))
                }
                else {
                    print("logout() success.")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 카카오 로그인
    
    func kakaoLogInService() -> AnyPublisher<Firebase.User, Error> {
        Future<Firebase.User, Error> { promise in
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        print(error)
                    } else {
                        _ = oauthToken
                        UserApi.shared.me { user, error in
                            if let error = error {
                                promise(.failure(AuthServiceError.signInError))
                                print("KAKAO : user loading failed")
                                print(error)
                            } else {
                                Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
                                    if let error = error {
                                        print("FB : signup failed")
                                        print(error)
                                        Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
                                            if let error = error {
                                                print(error)
                                                promise(.failure(AuthServiceError.signInError))
                                            } else {
                                                if result != nil {
                                                    promise(.success(result!.user))
                                                } else {
                                                    promise(.failure(AuthServiceError.signInError))
                                                }
                                            }
                                        }
                                    } else {
                                        Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
                                            if let error = error {
                                                print(error)
                                                promise(.failure(AuthServiceError.signInError))
                                            } else {
                                                if result != nil {
                                                    promise(.success(result!.user))
                                                } else {
                                                    promise(.failure(AuthServiceError.signInError))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        print(error)
                    } else {
                        _ = oauthToken
                        UserApi.shared.me { user, error in
                            if let error = error {
                                promise(.failure(AuthServiceError.signInError))
                                print("KAKAO : user loading failed")
                                print(error)
                            } else {
                                Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
                                    if let error = error {
                                        print("FB : signup failed")
                                        print(error)
                                        Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
                                            if let error = error {
                                                print(error)
                                                promise(.failure(AuthServiceError.signInError))
                                            } else {
                                                if result != nil {
                                                    promise(.success(result!.user))
                                                } else {
                                                    promise(.failure(AuthServiceError.signInError))
                                                }
                                            }
                                        }
                                    } else {
                                        Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
                                            if let error = error {
                                                print(error)
                                                promise(.failure(AuthServiceError.signInError))
                                            } else {
                                                if result != nil {
                                                    promise(.success(result!.user))
                                                } else {
                                                    promise(.failure(AuthServiceError.signInError))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

//
//    func handleKakaoLogin() {
//        if (UserApi.isKakaoTalkLoginAvailable()) {
//            UserApi.shared.loginWithKakaoTalk { oauthToken, error in
//                if let error = error {
//                    print(error)
//                } else {
//                    _ = oauthToken
//                    UserApi.shared.me { user, error in
//                        if let error = error {
//                            print("KAKAO : user loading failed")
//                            print(error)
//                        } else {
//                            Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
//                                if let error = error {
//                                    print("FB : signup failed")
//                                    print(error)
//                                    Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
//                                        if let error = error {
//                                            print(error)
//                                            promise(.failure(AuthServiceError.signInError))
//                                        } else {
//                                            if result != nil {
//                                                promise(.success(result!.user))
//                                            } else {
//                                                promise(.failure(AuthServiceError.signInError))
//                                            }
//                                        }
//                                    }
//                                } else {
//                                    Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
//                                        if let error = error {
//                                            print(error)
//                                            promise(.failure(AuthServiceError.signInError))
//                                        } else {
//                                            if result != nil {
//                                                promise(.success(result!.user))
//                                            } else {
//                                                promise(.failure(AuthServiceError.signInError))
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        } else {
//            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
//                if let error = error {
//                    print(error)
//                } else {
//                    _ = oauthToken
//                    UserApi.shared.me { user, error in
//                        if let error = error {
//                            print("KAKAO : user loading failed")
//                            print(error)
//                        } else {
//                            Auth.auth().createUser(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
//                                if let error = error {
//                                    print("FB : signup failed")
//                                    print(error)
//                                    Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
//                                        if let error = error {
//                                            print(error)
//                                            promise(.failure(AuthServiceError.signInError))
//                                        } else {
//                                            if result != nil {
//                                                promise(.success(result!.user))
//                                            } else {
//                                                promise(.failure(AuthServiceError.signInError))
//                                            }
//                                        }
//                                    }
//                                } else {
//                                    Auth.auth().signIn(withEmail: (user?.kakaoAccount?.email)!, password: "\(String(describing: user?.id))") { result, error in
//                                        if let error = error {
//                                            print(error)
//                                            promise(.failure(AuthServiceError.signInError))
//                                        } else {
//                                            if result != nil {
//                                                promise(.success(result!.user))
//                                            } else {
//                                                promise(.failure(AuthServiceError.signInError))
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
