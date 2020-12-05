//
//  PostView.swift
//  makeup
//
//  Created by Shwong on 2020-11-21.
//  Copyright © 2020 Shwong. All rights reserved.
//

import AVFoundation
import AVKit
import SwiftUI

struct PostView: View {
    
    let post: Post
    
    var body: some View {
            
        ScrollView(.vertical) {
            
            //text
            VStack(alignment: .leading) {
                
                Text(self.post.title)
                    .font(.custom("Lora-Regular", size: 18))
                    .padding(.init(top: 15, leading: 10, bottom: 10, trailing: 10))
                
                
                Text(self.post.desc)
                    .foregroundColor(.grayColor)
                    .font(.custom("Lora-Regular", size: 14))
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                
                Divider().frame(width: UIScreen.main.bounds.width)
                
                //Spacer()
            }
            
            //pics and videos
            VStack(alignment: .center) {
                
                //Spacer()
                
                if #available(iOS 14.0, *) {
                    TabView() {
                        //bare image
                        Image(uiImage: self.post.firstPic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 400)
                            .clipped()
                        
                        ForEach(0..<self.post.videos.count, id: \.self) { i in
                            playerPost(newPostVideos: post.videos, index: i)
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width, height: 400)
                                .clipped()
                                .padding()
                        }
                        
                        Image(uiImage: self.post.lastPic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 400)
                            .clipped()
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .padding(.bottom).padding(.top)
                }
                //Spacer()
                
                Divider().frame(width: UIScreen.main.bounds.width)
            }
            
            VStack(alignment: .leading) {
                
                //Spacer()
                
                HStack() {
                    Image(systemName: "doc.plaintext")
                        .font(.system(size: 25.0))
                    Text("Routine Notes")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                
                Text(self.post.instructions)
                    //.foregroundColor(.grayColor)
                    .font(.custom("Lora-Regular", size: 14))
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
            }
            
            VStack(alignment: .trailing) {
                Text(self.post.date)
                    .font(.custom("Exo2-Regular", size: 11))
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
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
    @State(initialValue: .init(id: "", firstPic:UIImage(), lastPic: UIImage(), videos: [], instructions: "", date: "", title: "", desc: "")) var p: Post
    
    var body: some View {
        PostView(post: p)
    }
}

struct playerPost : UIViewControllerRepresentable{
    var newPostVideos:[URL]
    var index:Int
    func makeUIViewController(context: UIViewControllerRepresentableContext<playerPost>) -> AVPlayerViewController {

        let controller = AVPlayerViewController()
        controller.videoGravity = .resizeAspectFill
        let player1 = AVPlayer(url: newPostVideos[index])
        controller.player = player1
        
        return controller
         
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<playerPost>) {
        
    }
}
