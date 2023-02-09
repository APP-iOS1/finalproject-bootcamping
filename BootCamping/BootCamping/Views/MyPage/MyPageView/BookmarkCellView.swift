//
//  BookmarkCellView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI

// TODO: 유저 모델 받아와서 데이터 뿌려주기
// MARK: -View : 내가 북마크한 캠핑장을 보여주는 cell
struct BookmarkCellView: View {
    @State var isBookmarked: Bool = true
    var campingSpot: Item
    
    var body: some View {
        HStack(alignment: .top) {
            WebImage(url: URL(string: campingSpot.firstImageUrl))
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading, spacing: 5) {
                Text(campingSpot.facltNm)
                    .font(.title3)
                    .kerning(-0.5)
                Text(campingSpot.lineIntro)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
                Text("\(Image(systemName: "mappin.circle.fill")) \(campingSpot.addr1)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 5)
            Spacer()
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .bold()
                .foregroundColor(.white)
                .shadow(color: .black, radius: 10)
                .padding()
        }
        .frame(maxWidth: UIScreen.screenWidth, maxHeight: 150)
    }
}

struct BookmarkCellView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkCellView()
    }
}
