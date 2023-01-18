//
//  DiaryAddView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import PhotosUI

struct DiaryAddView: View {
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedImages = [UIImage]()
    @State private var diaryTilte: String = ""
    @State private var locationInfo: String = ""
    @State private var visitDate: String = ""
    @State private var isOpen: Bool = false
    @State private var diaryContent: String = ""

    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            HStack {
                VStack{
                    PhotosPicker(
                        selection: $selectedItems,
                        maxSelectionCount: 10,
                        matching: .any(of: [.images, .not(.videos)])) {
                            ZStack {
                                Image(systemName: "plus")
                                VStack{
                                    Spacer()
                                    Text("\(selectedImages.count) / 10")
                                        .padding(.bottom, 5)
                                }
                            }
                            .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                            .background {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(.gray, lineWidth: 2)
                            }
                        }
                        .onChange(of: selectedItems) { newValue in
                            Task {
                                selectedItems = []
                                for value in newValue {
                                    if let imageData = try? await value.loadTransferable(type: Data.self), let image = UIImage(data: imageData) {
                                        selectedImages.append(image)
                                    }
                                }
                            }
                        }
                }
                if selectedImages.count > 0 {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: UIScreen.screenWidth * 0.2, height: UIScreen.screenWidth * 0.2)
                            }
                        }
                    }
                }
                
            }
            .padding()
            Section {
                TextField("제목을 입력해주세요(최대 10자)", text: $diaryTilte)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .stroke(.gray, lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 1)
            } header: {
                Text("제목")
                    .padding(.horizontal)
            }
            Section {
                TextField("위치를 등록해주세요", text: $locationInfo)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .stroke(.gray, lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 1)
            } header: {
                Text("위치 등록하기")
                    .padding(.horizontal)
            }
            Section {
                TextField("방문일자를 등록해주세요", text: $visitDate)
                    .padding(6)
                    .background {
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .stroke(.gray, lineWidth: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 1)
            } header: {
                Text("방문일")
                    .padding(.horizontal)
            }
            
            Toggle(isOn: $isOpen) {
                Text("공개여부")
            }
            .padding(.horizontal)
            
            
            Divider()
            ScrollView {
                TextField("일기를 작성해주세요", text: $diaryContent)
                    .padding()
            }
        }
        
    }
}
struct DiaryAddView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryAddView()
    }
}
