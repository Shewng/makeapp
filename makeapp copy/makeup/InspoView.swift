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
                        InspoPostView(post: post)
                    }
                }
            }
            .navigationBarTitle(Text("Allure"))
            .padding(.leading, -20)
            
        }
        
    }
}

struct InspoPostView: View {
    
    let post: Post
    
    var body: some View {
        
        GeometryReader { geometry in
            
            VStack (alignment: .leading) {
                
                if #available(iOS 14.0, *) {
                    TabView() {
                        //bare image
                        //NavigationLink(destination: PostView(post: post) {
                        Image(uiImage: self.post.firstPic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 400)
                            .clipped()
                        
                        Image(uiImage: self.post.lastPic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width, height: 400)
                            .clipped()
                        //}
                    }
                    .tabViewStyle(PageTabViewStyle())
                }
                
                //title, description
                Text(self.post.title)
                    .foregroundColor(.fontColor)
                    .font(.system(size: 18))
                    .padding(.leading, 10)
                
                Divider().frame(width: UIScreen.main.bounds.width)
                
                Text(self.post.desc)
                    .foregroundColor(.fontColor)
                    .font(.system(size: 18))
                    .padding(.leading, 10)
                
            }
            .padding(.bottom, 20)
            .border(Color.fontColor, width: 1)
            
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
    
    var id: String
    var firstPic: UIImage
    var lastPic: UIImage
    var videos: [URL]
    //var instructions: [String]
    var title: String
    var desc: String
    

    init(id: String, firstPic: UIImage, lastPic: UIImage, videos: [URL], title: String, desc: String) {
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


