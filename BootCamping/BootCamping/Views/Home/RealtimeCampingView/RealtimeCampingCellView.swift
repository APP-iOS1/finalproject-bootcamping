//
//  RealtimeCampingCellView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI

struct RealtimeCampingCellView: View {
    var item: RealtimeCampingSampleData
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(item.picture)
                .resizable()
                .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
                .aspectRatio(contentMode: .fill)
                .padding(.horizontal, UIScreen.screenWidth * 0.05)
            
            Text(item.title)
                .font(.system(.title3, weight: .semibold))
                .padding()
            Text(item.content)
                .padding(.horizontal)
            
            HStack {
                Text(item.user)
                Text(item.date)
                Spacer()
                Text(item.like)
                Text(item.comment)
            }
            .font(.system(.subheadline))
            .padding(.horizontal)
            .padding(.vertical, 5)
            
            Divider()
                .padding(.horizontal)
                .padding(.bottom)

        }
    }
}

struct RealtimeCampingCellView_Previews: PreviewProvider {
    static var previews: some View {
        RealtimeCampingCellView(item: RealtimeCampingSampleData(picture: "4", title: "충주호 보면서 불멍하기", user: "by User", date: "15분 전", like: "좋아요 3", comment: "댓글 8", content: "충주호 캠핑월드 겨우 한자리 잡았는데 후회없네요ㅠㅠ 뷰가 짱이라서 마음에 들...  더 보기"))
    }
}
