//
//  InspoView.swift
//  makeup
//
//  Created by William Zhou on 2020-10-21.
//  Copyright © 2020 Shwong. All rights reserved.
//

import SwiftUI
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Combine

struct InspoView: View {
    
    @EnvironmentObject var postList: PostList
    @Binding var tabSelection: Int
    @Binding var postArray: [Post]
    @State var arr: [String] = []
    
    @State var firstImage = ""
    @State var lastImage = ""
    
    
    func getFromFirebase() {
        arr.removeAll()
        
        var array: [String] = []
        let storage = Storage.storage().reference()
        
        storage.child("uniquePost").listAll { (result, error) in
          if let error = error {
            // ...
            print("LOADING IMAGES ERROR")
          }
            //PREFIX = a unique post
          for prefix in result.prefixes {
            //first image
            prefix.child("images/first.png").downloadURL { (firstImage, err) in
                if err != nil {
                    print("deez error", err as Any)
                    return
                }
                //arr.append("\(firstImage!)")
                array.append("\(firstImage!)")
            }
            //lats image
            //prefix.child("images/last.png").downloadURL { (lastImage, err) in
            //    if err != nil {
            //        print("deez error", err as Any)
            //        return
            //    }
            //    self.lastImage = "\(lastImage!)"
            //}
            
            
            // The prefixes under storageReference.
            // You may call listAll(completion:) recursively on them.
          }
        
            //for index in 0 ..< result.items.count {
            //    result.items[index].child("images/first.png").downloadURL { (firstImage, err) in
            //        if err != nil {
            //            print("deez error", err as Any)
            //            return
            //        } else {
            //            arr.append("\(firstImage!)")
            //        }
            //    }
            //// The items under storageReference.
            //}
            
            ForEach(array, id: \.self) { pic in
                Tester(imageURL: pic)
            }
        }

            //return VStack() {
            //    ForEach(arr, id: \.self) { pic in
            //        Tester(imageURL: pic)
            //    }
            //}
        
        //upload test
        
        /*
        storage.child("uniquePost/9D2439D9-0912-444F-B416-45F39BBF41B0/images/first.png").downloadURL { (url, err) in
            if err != nil {
                print("deez error", err as Any)
                return
            }
            self.url = "\(url!)"
        }
        storage.child("uniquePost/9D2439D9-0912-444F-B416-45F39BBF41B0/images/last.png").downloadURL { (url2, err) in
            if err != nil {
                print("deez error", err as Any)
                return
            }
            self.url2 = "\(url2!)"
        }*/
    }
 
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack() {
                    if firstImage != ""{
                        ScrollView(.horizontal){
                            HStack{
                                //showImages(imageURL: firstImage)
                                //showImages(imageURL: lastImage)
                            }
                        }
                    }
                    ForEach(arr, id: \.self) { pic in
                        Tester(imageURL: pic)
                    }
                    /*
                    ForEach(postArray, id: \.id) { post in
                        InspoPostView(post: post)
                    }*/
                }
                .onAppear() {
                    
                    getFromFirebase()

     
     
                    /*
                    //database try to get the texts
                    database.child("uniquePost").observe(.childAdded, with: { (snapshot) in
                        let getPost = snapshot.value as! [String: String]
                    })
                    */
                }
            }
            List {
                ScrollView(.vertical) {
                    VStack () {
                        
                        
                        NavigationLink(destination: CameraView(tabSelection: $tabSelection, postArray: $postArray)) {
                            Text("Somehow add this feature to images.")
                        }
                    }
                }
            }
            .navigationBarTitle(Text("Allure"))
            .padding(.leading, -20)
            
        }
        
    }
}

struct Tester: View {
        
    @ObservedObject var imageLoader:DataLoader
    //@Binding var array: [String]
    @State var image: UIImage = UIImage()

    init(imageURL: String) {
        imageLoader = DataLoader(urlString:imageURL)
    }

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 400)
                .clipped()
        }.onReceive(imageLoader.didChange) { data in
            self.image = UIImage(data: data) ?? UIImage()
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


//https://github.com/loydkim/SwiftUI_Firebase_Storage_Tutorial/tree/master/Firebase_Storage_Test
//dataloader that converts url to data written by loydkim
class DataLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}
struct showImages: View {
    @ObservedObject var imageLoader:DataLoader
    @State var image: UIImage = UIImage()

    init(imageURL: String) {
        imageLoader = DataLoader(urlString:imageURL)
    }

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 400)
                .clipped()
        }.onReceive(imageLoader.didChange) { data in
            self.image = UIImage(data: data) ?? UIImage()
        }
    }
}
