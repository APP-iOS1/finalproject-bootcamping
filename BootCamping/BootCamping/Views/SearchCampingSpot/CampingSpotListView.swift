//
//  CampingSpotListView.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/18.
//

import SwiftUI
//import ExpandableText     // 패키지 또 추가하면 충돌날거같아서 일단 코드만 추가해둠~

struct CampingSpotListView: View {
    var body: some View {
        List{
            ForEach(0..<4) { i in
                ZStack{
                    NavigationLink {
                        CampingSpotDetailView()
                    } label: {
                        campingSpotListCell
                    }
                    .opacity(0)
                    campingSpotListCell
                        .padding(.horizontal, UIScreen.screenWidth*0.1)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("캠핑 모아보기")
            }
        }
    }
    
    
    //MARK: 캠핑장 리스트 셀 뷰
    private var campingSpotListCell: some View {
        VStack(alignment: .leading){
            
            // 캠핑장 사진
            Image("9")
                .resizable()
                .frame(width: UIScreen.screenWidth*0.9, height: UIScreen.screenWidth*0.9)
                .padding(.bottom, 5)
            
            // 전망 알려주는 라벨
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 35, height: 20)
                .foregroundColor(Color("BCGreen"))
                .overlay{
                    Text("바다")
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            
            // 캠핑장 이름
            Text("디노담양힐링파크")
                .font(.title3.bold())
            
            // 캠핑장 간단 주소
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .font(.callout)
                    .foregroundColor(.gray)
                    .padding(.trailing, -7)
                Text("전남 담양군")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 5)
            
            // 캠핑장 설명 3줄
            Text("그들은 이상이 청춘의 미인을 청춘이 품으며, 밝은 운다. 수 청춘 싶이 힘있다. 구할 얼마나 아니한 눈이 것이다. 일월과 꽃이 싶이 커다란 희망의 동력은 봄바람이다.")
                .font(.callout)
                .padding(.bottom)
            //                        .lineLimit(3)//optional
            //                        .expandButton(TextSet(text: "more", font: .body, color: .blue))//optional
            //                        .collapseButton(TextSet(text: "less", font: .body, color: .blue))//optional
            //                        .expandAnimation(.easeOut)//optional
            
        }
        
        
        
    }
    
}


struct CampingSpotListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CampingSpotListView()
        }
    }
}
