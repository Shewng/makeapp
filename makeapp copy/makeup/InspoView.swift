//
//  InspoView.swift
//  makeup
//
//  Created by William Zhou on 2020-10-21.
//  Copyright © 2020 Shwong. All rights reserved.
//

import SwiftUI


struct InspoView: View {
    
    @EnvironmentObject var postList: PostList
    
    @Binding var tabSelection: Int
    @Binding var postArray: [Post]
    
    
    var body: some View {
        NavigationView {
            List {
                ScrollView(.vertical) {
                    VStack () {
                        NavigationLink(destination: CameraView(tabSelection: $tabSelection, postArray: $postArray)) {
                            Text("Somehow add this feature to images.")
                        }
                        
                    }
                }
                VStack() {
                    ForEach(postArray, id: \.id) { post in
                        PostView(post: post)
                    }
                }
            }
            .navigationBarTitle(Text("Allure"))
            .padding(.leading, -20)
            
        }
        
    }
}

struct PostView: View {
    
    let post: Post
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack (alignment: .leading) {
                
                ScrollView(.horizontal) {
                    
                    HStack() {
                        //bare image
                        Image(uiImage: self.post.firstPic)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .border(Color.black, width: 1)
                            .clipped()
                            .padding()
                        
                        //player(setURL: post.videos[0])
                        //.scaledToFill()
                        //.frame(width:270, height: 300)
                        //.border(Color.black, width: 1)
                        //.clipped()
                        //.padding();
                        
                    }.padding(10)
                }
                
                //title, description
                Text(self.post.title)
                    .foregroundColor(.fontColor)
                    .font(.system(size: 18))
                Text(self.post.desc)
                    .foregroundColor(.fontColor)
                    .font(.system(size: 14))

                
            }.padding(.leading, -20)
            
        }
    }
}


struct InspoView_Previews: PreviewProvider {
    static var previews: some View {
        InspPreviewWrapper();
    }
}

struct InspPreviewWrapper: View {
    @State(initialValue: 1) var code: Int
    @State(initialValue: []) var arr: [Post]
    
    var body: some View {
        InspoView(tabSelection: $code, postArray: $arr)
    }
}

//struct Post1 {
//    let id: Int
//    let title, description: String
//}


class Post: NSObject {
    
    var id: Int
    var firstPic: UIImage
    var lastPic: UIImage
    var videos: [URL]
    //var instructions: [String]
    var title: String
    var desc: String

    init(id: Int, firstPic: UIImage, lastPic: UIImage, videos: [URL], title: String, desc: String) {
        self.id = id
        self.firstPic = firstPic
        self.lastPic = lastPic
        self.videos = videos
        //self.instructions = instructions
        self.title = title
        self.desc = desc
    }
}

class PostList: ObservableObject {
    @Published var posts: [Post] = []
    
    init() {
        posts = []
    }
}


