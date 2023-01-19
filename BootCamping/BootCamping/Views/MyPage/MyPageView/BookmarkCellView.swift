//
//  BookmarkCellView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI

// TODO: 유저 모델 받아와서 데이터 뿌려주기
// MARK: -View : 내가 북마크한 캠핑장을 보여주는 cell
struct BookmarkCellView: View {
    @State private var isBookmarked: Bool = true
    
    var body: some View {
        HStack(alignment: .top) {
            Image("b")
                .resizable()
                .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading, spacing: 5) {
                Text("서울대공원야영장")
                    .font(.title3)
                    .kerning(-0.5)
                Text("폐교를 리모델링한 임대 텐트 캠핑장")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                Spacer()
                Text("\(Image(systemName: "mappin.circle.fill")) 주소")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 5)
            Spacer()
            isBookmarked ? Image(systemName: "bookmark.fill")
                .font(.body)
                .foregroundColor(.secondary):
            Image(systemName: "bookmark")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: UIScreen.screenWidth, maxHeight: 150)
    }
}

struct BookmarkCellView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkCellView()
    }
}
