//
//  BlockUserEditView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/09.
//

import SwiftUI

struct BlockUserEditView: View {
    
    @Environment(\.editMode) var editMode
    
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var blockedUserStore: BlockedUserStore

    @State private var blockedUIDs: [String] = []
    
    var body: some View {
        List {
            Section{
                if let blockedUserList = (wholeAuthStore.userList.filter{ blockedUIDs.contains($0.id) }) {
                    if !blockedUserList.isEmpty{
                        ForEach(blockedUserList, id: \.self) { blockedUser in
                            Text("\(blockedUser.nickName)님")
                        }
                        .onDelete(perform: deleteUser)
                    }
                }
            } header: {
                Text("차단한 사용자 닉네임")
            } footer: {
                Text("차단 당한 사용자는 차단 여부를 알 수 없습니다.")
            }
        }
        .onAppear{
            blockedUIDs = wholeAuthStore.currnetUserInfo!.blockedUser
        }
        .toolbar {
            if editMode?.wrappedValue == .active {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // 완료 시 실행될 코드
                        Task{
                            blockedUserStore.updateBlockedUserCombine(blockedUsers: blockedUIDs)
                            wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!)
                        }
                        editMode?.animation().wrappedValue = .inactive
                    }
                }
            }
            else if editMode?.wrappedValue == .inactive {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        editMode?.animation().wrappedValue = .active
                    }
                }
            }
        }
        .navigationTitle("차단한 사용자 관리")
    }
    
    func deleteUser(at offsets: IndexSet) {
        blockedUIDs.remove(atOffsets: offsets)
    }
}
