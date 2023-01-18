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
                VStack(alignment: .leading){
                    Image("9")
                        .resizable()
                        .frame(width: UIScreen.screenWidth*0.9, height: UIScreen.screenWidth*0.9)
//                        .aspectRatio(contentMode: .fill) 없어도 똑같이 나오네욥 ..~
                        .padding(.bottom, 5)
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 35, height: 20)
                        .foregroundColor(Color("BCGreen"))
                        .overlay{
                            Text("바다")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    Text("디노담양힐링파크")
                        .font(.title3.bold())
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.callout)
                            .padding(.trailing, -7)
                        Text("전남 담양군")
                            .font(.callout)
                    }
                    
                    .padding(.bottom, 5)
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
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("캠핑 모아보기")
            }
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
