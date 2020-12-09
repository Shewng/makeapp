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
    @State var innerPostIndex: Int = 1000
    
    var body: some View {
            
        ScrollView(.vertical) {
            
            //text
            VStack(alignment: .leading) {
                
                Text(self.post.title)
                    .font(.custom("Lora-Medium", size: 18))
                    .padding(.init(top: 15, leading: 10, bottom: 5, trailing: 10))
                
                Text(self.post.desc)
                    .font(.custom("Lora-Regular", size: 14))
                    .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                
                Divider().frame(width: UIScreen.main.bounds.width).background(Color.gray)
                
            }
            
            //pics and videos
            VStack(alignment: .center) {
                                
                if #available(iOS 14.0, *) {
                    TabView(selection: self.$innerPostIndex) {
                        //bare image
                        VStack() {
                            Text("Bare")
                            Image(uiImage: self.post.firstPic)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: 400)
                                .clipped()
                        }
                        
                        .tag(1000)
                        ForEach(0..<self.post.videos.count, id: \.self) { i in
                            VStack() {
                                Text("Step " + String(i + 1))
                                playerPost(newPostVideos: post.videos, index: i)
                                    .scaledToFill()
                                    .frame(width: UIScreen.main.bounds.width, height: 400)
                                    .clipped()
                            }
                            .tag(i)
                        }
                        
                        VStack() {
                            Text("Final")
                            Image(uiImage: self.post.lastPic)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: 400)
                                .clipped()
                        }
                        .tag(1001)
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .frame(width: UIScreen.main.bounds.width, height: 520)
                    .padding(.top, -40)
                    .padding(.bottom, -15)
                }
                
                Divider().frame(width: UIScreen.main.bounds.width).background(Color.gray)
            }
            
            VStack(alignment: .leading) {
                
                HStack() {
                    Image(systemName: "doc.plaintext")
                        .font(.system(size: 25.0))
                    Text("Routine Notes")
                        .font(.system(size: 16, weight: .bold))
                }
                .padding(.init(top: 5, leading: 10, bottom: 5, trailing: 10))
                
                Text(self.post.instructions)
                    .font(.custom("Lora-Regular", size: 14))
                    .padding(.init(top: 5, leading: 10, bottom: 15, trailing: 10))
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
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
