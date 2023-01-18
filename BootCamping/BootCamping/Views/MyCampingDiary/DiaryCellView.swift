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
            HStack {
                Spacer()
                Image(systemName: "lock")
            }
            .padding(.horizontal)
            Image(item.picture)
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
                .aspectRatio(contentMode: .fill)
            
            Text(item.title)
                .font(.system(.title3, weight: .semibold))
                .padding(3)
            Text(item.content)
                .padding(3)
            HStack {
                Text(item.user)
                Text(item.date)
                Spacer()
                Text(item.like)
                Text(item.comment)
            }
            .padding(3)

        }
    }
}

//struct DiaryCellView_Previews: PreviewProvider {
//    static var previews: some View {
//        RealtimeCampingCellView()
//    }
//}
