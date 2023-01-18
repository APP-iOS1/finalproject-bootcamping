//
//  MyPlanCellView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI

// MARK: -View : 나의 캠핑 일정을 보여주는 cell
struct MyPlanCellView: View {
    // TODO: 캠핑장 데이터 받아와서 데이터 뿌려주기
    /// 캠핑장 데이터 받아와서 이미지, 이름, 주소 넣어주면 됩니다.
    /// D-Day는 생각해봐야 함
    var body: some View {
        VStack{
            Image("1")
                .resizable()
                .aspectRatio(contentMode: .fit)
            HStack{
                VStack{
                    Text("캠핑장 이름")
                    Text("캠핑장 주소")
                }
                Spacer()
                Text("D-21")
            }
        }
    }
}

struct MyPlanCellView_Previews: PreviewProvider {
    static var previews: some View {
        MyPlanCellView()
    }
}
