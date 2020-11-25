//
//  PostView.swift
//  makeup
//
//  Created by Shwong on 2020-11-21.
//  Copyright © 2020 Shwong. All rights reserved.
//


import SwiftUI

struct PostView: View {
    
    let post: Post
    
    var body: some View {
            
        ScrollView(.vertical) {
            
            //text
            VStack(alignment: .leading) {
                
                Text(self.post.title)
                    //.foregroundColor(.fontColor)
                    .font(.custom("Lora-Regular", size: 18))
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                
                Divider().frame(width: UIScreen.main.bounds.width)
                
                Text(self.post.desc)
                    .foregroundColor(.fontColor)
                    .font(.custom("Lora-Regular", size: 14))
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                
                Divider().frame(width: UIScreen.main.bounds.width)
            }
            
            //pics and videos
            VStack(alignment:.center) {
                if #available(iOS 14.0, *) {
                    TabView() {
                        //bare image
                        Image(uiImage: self.post.firstPic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 300)
                            .clipped()
                        
                        ForEach(0..<self.post.videos.count, id: \.self) { i in
                            player(index: i)
                                .scaledToFill()
                                .frame(width: 300, height: 300)
                                .clipped()
                                .padding()
                        }
                        
                        Image(uiImage: self.post.lastPic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 300)
                            .clipped()
                    }
                    .tabViewStyle(PageTabViewStyle())
                }
            }
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostPreviewWrapper()
    }
}

struct PostPreviewWrapper: View {
    @State(initialValue: .init(id: "", firstPic:UIImage(), lastPic: UIImage(), videos: [], date: "", title: "", desc: "")) var p: Post
    
    var body: some View {
        PostView(post: p)
    }
}
