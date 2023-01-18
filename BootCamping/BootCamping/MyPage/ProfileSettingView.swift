//
//  ProfileSettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI
import PhotosUI

struct ProfileSettingView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    
    var body: some View {
        VStack(spacing: 10){
            photoPicker
            // TODO: 개인정보 수정 텍스트 필드 추가해야 함
        }
    }
    
    // MARK: -View : PhotoPicker
    private var photoPicker : some View {
        VStack{
            ZStack{
                if let selectedImageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                }
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Image(systemName: "pencil.circle")
                            .font(.title)
                            .foregroundColor(.black)
                            .offset(x: 40, y: 40)
                            .frame(width: 100, height: 100)
                    }
                    .onChange(of: selectedItem) { newItem in
                        Task {
                            // Retrieve selected asset in the form of Data
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
            }
        }
    }
}

struct ProfileSettingView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingView()
    }
}
