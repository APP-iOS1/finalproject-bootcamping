//
//  AuthSignUpView.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import FirebaseAuth
import SwiftUI

struct AuthSignUpView: View {
    
    @State var userEmail: String = ""
    @State var nickName: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State var isAgree1: Bool = false
    @State var isAgree2: Bool = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var authStore: AuthStore
    
    var trimUserEmail: String {
        userEmail.trimmingCharacters(in: .whitespaces)
    }
    
    var trimnickName: String {
        nickName.trimmingCharacters(in: .whitespaces)
    }
    
    var isSignUpButtonAvailable: Bool {
        return !trimUserEmail.isEmpty && !trimnickName.isEmpty && authStore.checkAuthFormat(userEmail: userEmail) && isAgree1
    }
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                
                nickNameSection
                
                emailSection
                
                passwordSection
                
                Divider().padding(.vertical, 10)
                
                AgreeView
                
                Divider().padding(.vertical, 10)
                
                signUpButton
                
                Spacer()
                
            }
        }
        .foregroundColor(.bcBlack)
        .padding(.horizontal, UIScreen.screenWidth * 0.05)
    }
}

extension AuthSignUpView {
    
    // 닉네임 입력
    var nickNameSection: some View {
        VStack(spacing: 4) {
            HStack {
                Text("닉네임").font(.subheadline)
                Spacer()
            }
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    TextField("닉네임", text: $nickName)
                        .textCase(.lowercase)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                    
                }
                .padding(.bottom, 10)
        }
    }
    
    // 이메일 입력
    var emailSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("이메일").font(.subheadline)
                Spacer()
            }
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    HStack {
                        TextField("이메일", text: $userEmail)
                            .textCase(.lowercase)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        Spacer()
                    }.padding()
                }
            if authStore.checkAuthFormat(userEmail: userEmail) {
                Text("사용 가능").font(.footnote).foregroundColor(.green)
            } else if userEmail == "" {
                Text(" ").font(.footnote)
            } else if !authStore.checkAuthFormat(userEmail: userEmail) {
                Text("사용 불가능").font(.footnote).foregroundColor(.red)
            }
            
        }
        .padding(.bottom, 10)
    }
    
    // 패스워드 입력 및 확인
    var passwordSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("비밀번호").font(.subheadline)
                Spacer()
            }
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    SecureField("비밀번호", text: $password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                    
                }.padding(.bottom, 6)
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray)
                .frame(width: UIScreen.screenWidth * 0.9, height: 44)
                .overlay {
                    SecureField("비밀번호 확인", text: $confirmPassword)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .padding()
                }
            if authStore.checkPasswordFormat(password: password, confirmPassword: confirmPassword) {
                Text("일치").font(.footnote).foregroundColor(.green)
            } else if password == "" || confirmPassword == "" {
                Text("* 패스워드 양식은 영어 + 숫자 + 특수문자 최소 8자 이상입니다.\nex) password123!").font(.footnote).foregroundColor(.secondary)
            } else if !authStore.checkPasswordFormat(password: password, confirmPassword: confirmPassword) {
                Text("확인 필요").font(.footnote).foregroundColor(.red)
            }
        }
    }
    
    // 회원가입 확인 버튼
    var signUpButton: some View {
        Button {
            Task {
                let _ = try await authStore.authSignUp(userEmail: userEmail, password: password, confirmPassword: confirmPassword)
                try await authStore.authSignIn(userEmail: userEmail, password: password)
                authStore.addUserList(User(id: String(Auth.auth().currentUser!.uid), profileImage: "", nickName: nickName, userEmail: userEmail, bookMarkedDiaries: []))
                authStore.authSignOut()
            }
            self.presentationMode.wrappedValue.dismiss()
        } label: {
            Text("동의하고 계속하기")
                .font(.headline)
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenHeight * 0.07)
                .foregroundColor(.white)
                .background(isSignUpButtonAvailable ? Color.bcGreen : Color.secondary)
                .cornerRadius(10)
        }
        .disabled(!isSignUpButtonAvailable)
    }
    
    // 개인정보 수집 여부 뷰
    var AgreeView: some View {
        
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("개인정보 수집 및 이용에 동의합니다(필수).")
                    Spacer()
                    Button {
                        isAgree1.toggle()
                    } label: {
                        Image(systemName: isAgree1 ? "checkmark.square" : "square")
                    }
                }
                Text("1. 부트캠핑이 수집하는 개인정보 부트캠핑 플랫폼을 이용하는 데 필요한 정보 당사는 회원님이 부트캠핑 플랫폼을 이용할 때...\n").font(.subheadline)
                NavigationLink {
                    ScrollView {
                        Agree1View
                    }.padding(.horizontal, UIScreen.screenWidth * 0.05)
                } label: {
                    Text("더보기")
                        .font(.subheadline)
                        .underline()
                }
            }
            Divider()
            VStack(alignment: .leading) {
                HStack {
                    Text("마케팅 이메일 수신을 원합니다(선택).")
                    Spacer()
                    Button {
                        isAgree2.toggle()
                    } label: {
                        Image(systemName: isAgree2 ? "checkmark.square" : "square")
                    }
                }
                Text("부트캠핑 회원 전용 할인, 추천 여행정보, 마케팅 이메일, 푸시 알림을 보내드립니다. 계정 설정 또는 마케팅...\n").font(.subheadline)
                NavigationLink {
                    ScrollView {
                        Agree2View
                    }.padding(.horizontal, UIScreen.screenWidth * 0.05)
                } label: {
                    Text("더보기")
                        .font(.subheadline)
                        .underline()
                }
            }
        }
    }
    // 개인정보 수집 뷰
    var Agree1View: some View {
        Text("""
콘텐츠로 바로가기
법적 약관
한국 내 정보의 수집 및 사용

부트캠핑가 수집하는 개인 정보

부트캠핑 플랫폼을 이용하는 데 필요한 정보

당사는 회원님이 부트캠핑 플랫폼을 이용할 때 회원님의 개인 정보를 수집합니다. 그렇지 않은 경우, 부트캠핑는 요청하신 서비스를 회원님께 제공하지 못할 수 있습니다. 이러한 정보에는 다음이 포함됩니다.

연락처 정보, 계정, 프로필 정보. 회원님의 이름, 전화번호, 우편 주소, 이메일 주소, 생년월일, 프로필 사진 등. 이러한 정보 중 일부는 회원님이 사용하는 기능에 따라 달라질 수 있습니다.
본인 인증 및 결제 정보. (관련 법률에서 허용하는 경우) 정부가 발급한 신분증의 이미지, 신분증 번호 또는 기타 인증 정보, 은행 계좌 또는 결제 계좌 정보 등. 부트캠핑 사용자가 아닌 경우, 예컨대 부트캠핑 사용자가 예약을 완료하기 위해 귀하의 결제 카드를 제공했을 때 귀하와 관련된 결제 정보를 받을 수 있습니다. 회원님의 신분증 사본이 제출되는 경우, 신원 확인을 위해 신분증에 포함된 정보를 스캔, 이용 및 저장할 수 있습니다.
회원님이 자발적으로 부트캠핑에 제공하는 정보

회원님은 추가적인 개인 정보를 부트캠핑에 제공할 수 있습니다. 이러한 정보에는 다음이 포함될 수 있습니다.

추가적인 프로필 정보. 성별, 선호하는 언어, 도시, 인적 사항 등. 이러한 정보는 공개 프로필 페이지에 포함되며 다른 사람들이 볼 수 있습니다. 이러한 정보는 공개 프로필 페이지에 포함되며 다른 사람들이 볼 수 있습니다.
다른 사람에 대한 정보. 다른 사람 소유의 결제 수단 또는 동반 일행에 대한 정보. 타인에 대한 개인 정보를 제공함으로써, 회원님은 본 개인정보 처리방침에 명시된 목적을 위해 해당 정보를 부트캠핑에 제공할 수 있는 권한이 있음을 확인하고, 해당 타인에게 부트캠핑 개인정보 처리방침을 공유했으며, 해당 타인이 본 처리방침이 적용된다는 사실을 읽고 이해했음을 확인합니다.
주소록 연락처 정보. 회원님이 가져오기를 실행하거나 수동으로 입력한 주소록 연락처.
기타 정보. 예를 들어, 양식을 작성하거나, 계정에 정보를 추가하거나, 설문조사에 응답하거나, 커뮤니티 포럼에 게시글을 올리거나, 프로모션에 참여하거나, 당사의 고객지원팀 및 다른 회원들과 소통하거나, 본인의 경험을 당사와 공유하는 경우. 여기에는 회원님이 당사에 자발적으로 공유하는 건강 정보도 포함될 수 있습니다.
부트캠핑 플랫폼 및 당사 결제 서비스 사용 시 자동으로 수집되는 정보

당사는 회원님이 부트캠핑 플랫폼 및 결제 서비스를 이용할 때 개인 정보를 자동 수집합니다. 이러한 정보에는 다음이 포함될 수 있습니다.

위치 정보. 회원님 기기의 설정에 따라 IP 주소 또는 모바일 기기의 GPS를 이용해 판단하는 정확하거나 대략적인 위치 등. 설정이나 기기 사용 권한을 통해 해당 기능을 활성화하는 경우, 부트캠핑는 회원님이 앱을 사용하지 않는 동안에도 이 정보를 수집할 수 있습니다.
사용 정보. 회원님이 조회하는 페이지나 콘텐츠, 숙소 검색, 예약 내역, 부트캠핑 플랫폼에서 수행하는 기타 활동 등.
로그 데이터 및 기기 정보. 부트캠핑 플랫폼 사용 방식(제3자 애플리케이션으로 연결되는 링크를 클릭했는지 여부 등)에 관한 세부 정보, IP 주소, 접속 날짜 및 시간, 하드웨어 및 소프트웨어 정보, 기기 정보, 기기 이벤트 정보, 고유 식별자, 충돌 데이터, 쿠키 데이터, 부트캠핑 플랫폼 사용 이전 또는 이후에 조회하거나 이용한 페이지 등. 부트캠핑 계정을 만들지 않았거나 로그인하지 않은 경우에도 당사는 이러한 정보를 수집할 수 있습니다.
쿠키 정책에 설명된 쿠키 및 유사 기술.
결제 거래 정보. 사용된 결제 수단, 결제 날짜 및 시간, 결제 금액, 결제 수단 만료일, 청구 우편번호, 페이팔 이메일 주소, IBAN 정보, 회원님의 주소, 기타 거래 관련 세부 정보 등.
수집한 정보의 활용

부트캠핑 플랫폼의 제공, 개선, 개발

예:

회원님이 부트캠핑 플랫폼에 접속하고 결제를 하거나 대금을 수령할 수 있도록 지원.
회원님이 다른 회원과 커뮤니케이션할 수 있도록 지원.
회원님의 요청을 처리.
분석, 디버깅, 연구를 수행.
고객 서비스 교육 제공.
메시지, 업데이트, 보안 알림, 계정 알림 등의 발송.
회원님이 친구 또는 동반 일행 등 지인의 정보를 부트캠핑에 제공하는 경우, 부트캠핑는 (i) 회원님의 추천 초대 지원, (ii) 여행 세부 정보 공유 및 여행 계획 수립 지원, (iii) 사기 행위 탐지 및 예방, (iv) 회원님이 요청하거나 승인하는 기타 목적 지원을 위해 해당 정보를 처리할 수 있습니다.
회원님의 부트캠핑 플랫폼과의 상호작용, 검색 및 예약 이력, 프로필 정보 및 환경 설정, 기타 회원님이 제출하는 콘텐츠에 기반한 이용 경험의 개인화/맞춤화.
회원님의 당사 기업 상품 사용을 지원.
신뢰할 수 있고 더욱 안전한 환경의 조성 및 유지

예:

사기, 스팸, 악용, 보안 및 안전 사고, 기타 유해한 활동의 탐지 및 예방.
부트캠핑 차별 금지 정책에 따른 차별 연구 및 척결.
보안 조사 및 위험성 평가 실시.
회원님이 제공한 정보의 확인 또는 검증.
신원 조회 또는 경찰 기록 조회 등 데이터베이스 및 기타 정보 출처를 이용한 조회 수행.
법적 의무의 준수, 게스트와 호스트, 호스트의 피고용인, 일반 대중의 건강과 안전 도모.
회원님의 공동 호스트 또는 추가 게스트로서의 역할과 관련된 분쟁에 대해 회원님의 공동 호스트 또는 추가 게스트와 정보를 공유하는 것을 포함한 부트캠핑와 회원 사이의 분쟁 해결.
부트캠핑와 제3자 간의 계약을 이행.
법률 준수, 법적 요청에 대한 대응, 위해 방지, 당사의 권리 보호(제4.5조 참조).
부트캠핑 약관 및 기타 정책(예: 차별 금지 정책)의 시행.
부트캠핑는 상기 활동과 관련하여 회원님과 부트캠핑 플랫폼의 상호작용, 회원님이 부트캠핑에 제출하는 프로필 정보 및 기타 콘텐츠, 제3자로부터 입수한 정보에 기초하여 프로파일링을 수행할 수 있습니다. 제한적으로, 회원님의 부트캠핑 플랫폼 내 계정 및 활동, 부트캠핑 플랫폼 내/외부 활동 관련 정보를 분석하는 자동화된 프로세스가 부트캠핑, 부트캠핑 커뮤니티 또는 제3자에게 안전상 위험이나 기타 위험을 초래할 수 있는 활동을 감지하는 경우, 부트캠핑 플랫폼의 액세스를 금지하거나 이용 제한할 수 있습니다. 자동화된 프로세스에 기초한 의사 결정에 이의를 제기하려는 경우, 아래의 연락처 정보 항목을 참고해 연락해 주시기 바랍니다.
결제 서비스 제공

제3자가 결제 서비스를 이용할 수 있게 하거나 이용 권한을 부여하기 위해 다음과 같은 목적으로 개인 정보가 사용됩니다.

자금세탁, 사기, 악용 및 보안 사고를 탐지 및 예방.
보안 조사 및 위험성 평가 실시.
법적 의무(자금세탁 금지 규정 등)를 준수.
결제 약관및 기타 결제 정책을 집행.
회원님의 동의를 받은 경우, 회원님의 환경 설정에 따라 관심을 가질 만한 프로모션 메시지, 마케팅, 광고 및 기타 정보를 발송.
결제 서비스 제공 및 개선.
보유기간

기본적으로 사용자가 계정 삭제 또는 계정 탈퇴를 요청하는 경우 당사는 사용자의 개인정보를 삭제 처리합니다.

다만, 당사는 개인정보 처리방침 6.3 섹션에 설명된 바와 같이 당사의 정당한 사업상 이익 또는 법적 의무 준수를 위하여 필요한 일정 정보를 보유할 수 있습니다. 보유할 수 있는 정보의 구체적 내용은 자금세탁방지, 감사 및 금융규제 준수 등 법률 준수 목적으로 ‘지불수단 정보'(관련 법률: GDPR 5(1)(e), 아일랜드 세금통합법률 1997 및 관련 하위법령, EU 5번째 자금세탁방지법령 (EU 법령 2018/843) 및 관련 법령) 및 플랫폼 상 다수 당사자의 사기 시도 탐지를 위한 안전 및 보안 목적으로 보안 정보(로그인 및 관련 기기정보 등 활동 관련 정보) 및 보안 연결 정보(기기 및 계정 확인 관련 정보 및 지불 수단 구별 정보)(관련 법률: GDPR 5(1)(e))입니다.

계정 삭제, 서비스 종료와 같이 개인정보의 수집 및 이용목적이 달성된 개인정보는 재생이 불가능한 방법으로 파기하고 있습니다. 전자적 파일 형태의 경우 복구 및 재생이 되지 않도록 기술적인 방법을 이용하여 삭제합니다.

개인정보 수집 및 이용을 거부할 권리

사용자는 개인정보 수집 및 이용을 거부할 권리가 있습니다. 사용자가 회원 가입 과정에서 필수로 요구되는 최소한의 개인정보의 수집 및 이용을 거부하는 경우 부트캠핑 서비스 이용이 어려울 수 있습니다.

관련 도움말
한국 위치기반서비스 추가 이용약관
회원님의 거주국가가 대한민국인 경우, 아래 약관이 회원님에게 추가적으로 적용됩니다.
고아
부트캠핑를 통한 호스팅에 관심이 있으신가요? 거주 도시의 호스팅 관련 법규를 이해하는 데 도움이 되는 정보를 아래에서 확인해보세요.
하와이주 카우아이
부트캠핑를 통한 호스팅에 관심이 있으신가요? 거주 도시의 호스팅 관련 법규를 이해하는 데 도움이 되는 정보를 아래에서 확인해보세요.

""").font(.subheadline)
    }
    
    // 마케팅 이메일 수신 뷰
    var Agree2View: some View {
        Text("""
콘텐츠로 바로가기
법적 약관
한국 사용자 대상 마케팅 이메일

광고 및 마케팅의 제공, 맞춤화, 성과 측정 및 개선. 예: 회원님의 환경 설정에 따라 프로모션 메시지, 마케팅, 광고, 기타 정보를 발송하고, 소셜 미디어 플랫폼을 통해 소설 미디어 광고를 발송. 부트캠핑 광고의 맞춤화, 성과 측정, 개선. 부트캠핑 또는 제3자 파트너가 후원하거나 진행하는 추천 프로그램, 보상 프로그램, 설문조사, 경품 이벤트, 콘테스트, 기타 프로모션 활동이나 이벤트 관리. 회원님이 관심을 가질 만한 프로모션 메시지, 마케팅, 광고, 기타 정보를 발송하기 위한 특성 및 선호 사항 분석. 회원님을 이벤트 및 관련 기회에 초대.
관련 도움말
부탄에서 책임감 있는 호스팅하기
호스트가 호스팅에 따르는 책임을 숙지하고, 호스팅에 적용될 수 있는 각종 법규와 모범 사례에 대해 전반적으로 알아볼 수 있도록 도움말이 마련되어 있습니다.
프린스에드워드 카운티
부트캠핑 호스팅에 관심이 있으신가요? 호스팅할 도시의 호스팅 관련 법규를 이해하는 데 도움이 되는 정보를 아래에서 확인해보세요.
본
부트캠핑 호스팅에 관심이 있으신가요? 호스팅할 도시의 호스팅 관련 법규를 이해하는 데 도움이 되는 정보를 아래에서 확인해보세요.

""").font(.subheadline)
    }
}

struct AuthSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        AuthSignUpView()
    }
}
