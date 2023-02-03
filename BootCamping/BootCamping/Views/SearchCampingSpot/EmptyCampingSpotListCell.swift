//
//  EmptyCampingSpotListCell.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/03.
//

import SwiftUI

struct EmptyCampingSpotListCell: View {
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color.bcBlack.opacity(0.1))
                .frame(maxWidth: .infinity, maxHeight: UIScreen.screenWidth*0.9)
            HStack {
                ForEach(0...2, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 40 ,height: 20)
                        .foregroundColor(Color.bcBlack.opacity(0.1))
                }
            }
            Rectangle()
                .fill(Color.bcBlack.opacity(0.1))
                .frame(width: UIScreen.screenWidth, height: 20)
            Rectangle()
                .fill(Color.bcBlack.opacity(0.1))
                .frame(width: UIScreen.screenWidth, height: 50)
        }
    }
}

struct EmptyCampingSpotListCell_Previews: PreviewProvider {
    static var previews: some View {
        EmptyCampingSpotListCell()
    }
}
