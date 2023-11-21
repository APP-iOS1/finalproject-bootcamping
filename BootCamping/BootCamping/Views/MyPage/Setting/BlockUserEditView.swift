//
//  BlockUserEditView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/09.
//

import SwiftUI
import AlertToast

// MARK: - 사용자가 차단한 유저들을 확인하고 차단 해제할 수 있는 뷰
struct BlockUserEditView: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var blockedUserStore: BlockedUserStore

    @State private var blockedUIDs: [String] = []
    @State private var isShowingUnblockToast: Bool = false
    
    var body: some View {
        List {
            Section {
                let blockedUserList = (wholeAuthStore.userList.filter{ blockedUIDs.contains($0.id) })
                    if !blockedUserList.isEmpty{
                        ForEach(Array(zip(blockedUserList.indices, blockedUserList)), id: \.0) { index, blockedUser in
                            HStack {
                                Text("\(blockedUser.nickName)")
                                Spacer()
                                Button {
                                    blockedUIDs.remove(at: index)
                                    blockedUserStore.updateBlockedUserCombine(blockedUsers: blockedUIDs)
                                    wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
                                    isShowingUnblockToast.toggle()
                                } label: {
                                    Text("차단 해제")
                                        .foregroundColor(Color.bcGreen)
                                        .padding(8)
                                        .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.bcGreen, lineWidth: 1)
                                        )
                                        .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                
            } header: {
                Text("차단한 사용자 닉네임")
            } footer: {
                Text("차단 당한 사용자는 차단 여부를 알 수 없습니다.")
            }
        }
        .listStyle(.grouped)
        .toast(isPresenting: $isShowingUnblockToast) {
            AlertToast(type: .regular, title: "해당 사용자를 차단해제했습니다.", subTitle: "이 사용자의 글을 이제 확인할 수 있습니다.")
        }
        .onAppear{
            blockedUIDs = wholeAuthStore.currnetUserInfo!.blockedUser
        }
        .navigationTitle("차단한 사용자 관리")
    }
}
