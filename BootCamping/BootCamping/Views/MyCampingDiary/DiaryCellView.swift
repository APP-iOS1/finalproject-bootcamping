//
//  DiaryCellView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI

import SwiftUI

struct DiaryCellView: View {
    var item: RealtimeCampingSampleData
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Circle()
                    .frame(width: 25)
                Text(item.user)
                Image(systemName: "lock")
                Spacer()
                //삭제 수정
                Image(systemName: "ellipsis")
            }
            .padding(3)
            Image(item.picture)
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
                .aspectRatio(contentMode: .fill)
            Text(item.title)
                .font(.system(.title3, weight: .semibold))
                .padding(3)
            HStack {
                Image("1")
                    .resizable()
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("충주호 캠핑장")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("충북 충주")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding(3)
            HStack {
                Image(systemName: "heart")
                Text("3")
                    .padding(.leading, -8)
                Image(systemName: "bubble.left")
                Text("8")
                    .padding(.leading, -8)
                Spacer()
            }
            .padding(3)
            Text(item.content)
                .padding(3)
            Text(item.date)
                .padding(3)
                .foregroundColor(.gray)

        }
    }
}

//struct DiaryCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        RealtimeCampingCellView()
//    }
//}
