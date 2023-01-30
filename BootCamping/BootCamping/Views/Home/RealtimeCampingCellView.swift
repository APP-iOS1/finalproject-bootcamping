//
//  RealtimeCampingCellView.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct RealtimeCampingCellView: View {
    
    @EnvironmentObject var authStore: AuthStore
    //선택한 다이어리 정보 변수입니다.
    var item: Diary
    
    //TODO: - 닉네임 필터링 변수 작동시키기...왜 안돼..
    //글 작성 유저 닉네임 필터링 변수입니다.
    var userNickName: String? {
        get {
            for user in authStore.userList {
                if user.id == item.uid {
                    return user.nickName
                }
            }
            return nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            diaryImage
            diaryTitle
            diaryContent
            diaryInfo
            Divider()
                .padding(.horizontal)
                .padding(.bottom)

        }
    }
}

private extension RealtimeCampingCellView {
    //MARK: - 메인 이미지
    var diaryImage: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(item.diaryImageURLs, id: \.self) { url in
                    WebImage(url: URL(string: url))
                        .resizable()
                        .frame(width: UIScreen.screenWidth * 0.9, height: UIScreen.screenWidth * 0.9)
                        .aspectRatio(contentMode: .fill)
                    
                }
            }
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.01)
    }
    
    //MARK: - 제목
    var diaryTitle: some View {
        Text(item.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding()
    }
    
    //MARK: - 내용
    var diaryContent: some View {
        Text(item.diaryContent)
            .lineLimit(3)
            .padding(.horizontal)
    }
    
    //MARK: - 좋아요, 댓글, 유저 닉네임, 타임스탬프
    var diaryInfo: some View {
        HStack {
            Text("좋아요 \(item.diaryLike)")
            Text("댓글 8")
            Spacer()
            Text("by \(userNickName ?? "닉네임")")
            Text("|")
            Text("\(TimestampToString.dateString(item.diaryCreatedDate)) 전")
        }
        .font(.system(.subheadline))
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

struct RealtimeCampingCellView_Previews: PreviewProvider {
    static var previews: some View {
        RealtimeCampingCellView(item: Diary(id: "", uid: "", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: "", diaryIsPrivate: true))
        .environmentObject(AuthStore())
        
    }
}
