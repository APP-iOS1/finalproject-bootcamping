//
//  BlockUserEditView.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/09.
//

import SwiftUI

struct BlockUserEditView: View {
    
    @State private var selection = Set<String>()
    
    @State private var blockedUser = [
        "John", "Alice", "Bob", "Foo", "Bar"
    ]
    
    var body: some View {

            List {
                ForEach(blockedUser, id: \.self) { blockedUser in
                    Text(blockedUser)
                }
                .onDelete(perform: deleteUser)
                
            }
            .toolbar {
                EditButton()
            }
        .navigationTitle("차단한 멤버 관리")
        
        
    }
    
    func deleteUser(at offsets: IndexSet) {
        blockedUser.remove(atOffsets: offsets)
    }
}
