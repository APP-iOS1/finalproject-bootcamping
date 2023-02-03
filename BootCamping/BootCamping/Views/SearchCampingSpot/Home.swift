//
//  Home.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/02/03.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct Home : View {
    
    @State var data : [Card] = []
    // for Tracking....
    @State var time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
    @State var lastDoc : QueryDocumentSnapshot!
    
    var body: some View{
        
        VStack(spacing: 0){
            
            HStack(spacing: 22){
                
                Button(action: {
                    
                }) {
                    
                    Image(systemName: "line.horizontal.3.decrease")
                        .font(.system(size: 23))
                        .foregroundColor(.white)
                }
                
                Text("Firebase")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer(minLength: 0)
            }
            .padding()
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .background(Color("Color"))
            
            if !self.data.isEmpty{
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 15){
                        
                        ForEach(self.data){i in
                            
                            ZStack{
                                
                                // Showing Only When Data Is Loading...
                                
                                // because show variable is animating...
                                
                                if i.name == ""{
                                    
                                    // Shimmer Card..
                                    
                                    HStack(spacing: 15){
                                        
                                        Circle()
                                            .fill(Color.black.opacity(0.09))
                                            .frame(width: 75, height: 75)
                                        
                                        VStack(alignment: .leading, spacing: 12) {
                                            
                                            Rectangle()
                                                .fill(Color.black.opacity(0.09))
                                                .frame(width: 250, height: 15)
                                            
                                            Rectangle()
                                                .fill(Color.black.opacity(0.09))
                                                .frame(width: 100, height: 15)
                                        }
                                        
                                        Spacer(minLength: 0)
                                    }
                                    
                                    // Shimmer Animation...
                                    
                                    HStack(spacing: 15){
                                        
                                        Circle()
                                            .fill(Color.white.opacity(0.6))
                                            .frame(width: 75, height: 75)
                                        
                                        VStack(alignment: .leading, spacing: 12) {
                                            
                                            Rectangle()
                                                .fill(Color.white.opacity(0.6))
                                                .frame(width: 250, height: 15)
                                            
                                            Rectangle()
                                                .fill(Color.white.opacity(0.6))
                                                .frame(width: 100, height: 15)
                                        }
                                        
                                        Spacer(minLength: 0)
                                    }
                                    // Masking View...
                                    .mask(
                                    
                                        Rectangle()
                                            .fill(Color.white.opacity(0.6))
                                            .rotationEffect(.init(degrees: 70))
                                        // Moving View....
                                            .offset(x: i.show ? 1000 : -350)
                                    )
                                }
                                else{
                                    
                                    // Show Original Data...
                                    
                                    // Going to track end of data...
                                    
                                    ZStack{
                                        
                                        if self.data.last!.id == i.id{
                                            
                                            GeometryReader{g in
  
                                                HStack(spacing: 15){
                                                    
                                                    AnimatedImage(url: URL(string: i.url)!)
                                                    .resizable()
                                                    .frame(width: 75, height: 75)
                                                    .clipShape(Circle())
                                                    
                                                    VStack(alignment: .leading, spacing: 12) {
                                                        
                                                        Text(i.name)
                                                    }
                                                    
                                                    Spacer(minLength: 0)
                                                }
                                                .onAppear{
                                                    
                                                    self.time = Timer.publish(every: 0.1, on: .main, in: .tracking).autoconnect()
                                                }
                                                .onReceive(self.time) { (_) in
                                                    
                                                    if g.frame(in: .global).maxY < UIScreen.main.bounds.height - 80{
                                                        
                                                        self.UpdateData()
                                                        
                                                        print("Update Data...")
                                                        
                                                        self.time.upstream.connect().cancel()
                                                    }
                                                }
                                            }
                                            .frame(height: 65)
                                            
                                        }
                                        else{
                                            
                                            
                                            HStack(spacing: 15){
                                                
                                                AnimatedImage(url: URL(string: i.url)!)
                                                .resizable()
                                                .frame(width: 75, height: 75)
                                                .clipShape(Circle())
                                                
                                                VStack(alignment: .leading, spacing: 12) {
                                                    
                                                    Text(i.name)
                                                }
                                                
                                                Spacer(minLength: 0)
                                            }
                                        }
                                    }
                                }
                                
                            }
                            .padding()
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .background(Color.black.opacity(0.05).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            
            self.loadTempData()
            
            // Loading Data...
            
            self.getData()
        }
    }
    
    // Intial Shimmer Card data
    // Showing Until Data Is Loading...
    
    func loadTempData(){
        
        for i in 0...19{
            
            let temp = Card(id: "\(i)", name: "", url: "", show: false)
            
            self.data.append(temp)
            
            // Enabling Animation..
            
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)){
                
                self.data[i].show.toggle()
            }
        }
    }
    
    // Loading Data...
    
    func getData(){
        
        let db = Firestore.firestore()
        // First 20 data....
        db.collection("Data").order(by: "name",descending: false).limit(to: 20).getDocuments { (snap, err) in
            
            if err != nil{
                
                print((err?.localizedDescription)!)
                return
            }
            
            // removing shimmer data...
            
            self.data.removeAll()
            
            for i in snap!.documents{
                
                let data = Card(id: i.documentID, name: i.get("name") as! String, url: i.get("url") as! String, show: false)
                
                self.data.append(data)
            }
            
            // Saving Last Doc..
            
            self.lastDoc = snap!.documents.last
        }
    }
    
    // Updating Next 20 Data...
    
    func UpdateData(){
        
        // Adding Loading Shimmer Card...
        
        self.data.append(Card(id: "\(self.data.count)", name: "", url: "", show: false))
        
        withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)){
            
            self.data[self.data.count - 1].show.toggle()
        }
        
        // Loading Data After One Second For Smooth Animation...
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            let db = Firestore.firestore()
            
            db.collection("Data").order(by: "name",descending: false).start(afterDocument: self.lastDoc).limit(to: 20).getDocuments { (snap, err) in
                
                if err != nil{
                    
                    print((err?.localizedDescription)!)
                    return
                }
                
                // removing loading animation....
                
                self.data.removeLast()
                
                if !snap!.documents.isEmpty{
                    
                    for i in snap!.documents{
                        
                        let data = Card(id: i.documentID, name: i.get("name") as! String, url: i.get("url") as! String, show: false)
                        
                        self.data.append(data)
                    }
                    
                    // Updating Last Doc...
                    
                    self.lastDoc = snap!.documents.last
                }
            }
        }
    }
}

// Data Model...

struct Card : Identifiable {
    
    var id : String
    var name : String
    var url : String
    var show : Bool
}
