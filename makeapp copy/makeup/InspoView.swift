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


extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}


struct InspoView: View {
    
    @EnvironmentObject var postList: PostList
    @Binding var tabSelection: Int
    @Binding var postArray: [Post]
    
    @State var imageArray: [String] = []
    @State var dataArray: [String] = []

    
    func getStrings(){
        dataArray.removeAll()
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        
        ref.child("uniquePost").observeSingleEvent(of: .value) { (snapshot) in
            
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                
                for child in result {
                    let newRef = ref.child("uniquePost").child(child.key)
                    
                    newRef.observeSingleEvent(of: .value) { (data) in
                        if let newResult = data.children.allObjects as? [DataSnapshot]{
                            for strings in newResult {
                                dataArray.append(strings.value! as! String)
                                dataArray = dataArray.removingDuplicates()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func getFromFirebase() {
        imageArray.removeAll()
        let storage = Storage.storage().reference()
        
        storage.child("uniquePost").listAll { (result, error) in
          if let error = error {
            // ...
            print("LOADING IMAGES ERROR")
          }
            
            //PREFIX = a unique post
          for prefix in result.prefixes {
            prefix.child("images").listAll { (images, error) in
                if let error = error {
                    print("Images Error")
                }
                
                for image in images.items {
                    image.downloadURL { (url, error) in
                        if let error = error {
                            print("URL ERROR")
                        }
                        imageArray.append("\(url!)")
                        imageArray = imageArray.removingDuplicates()
                        print(imageArray.count)
                        
                        imageArray.sort()
                    }
                }
                //arr.removeAll()
                
            }
          }
        }
    }
 
    var body: some View {
        NavigationView {
            
            // WITH DATABASE
            List {
                ScrollView(.vertical) {
                    Print("array= " , dataArray)
                    VStack() {
                        
                        if #available(iOS 14.0, *) {
                            ForEach(0..<((imageArray.count/2)), id: \.self){ index in
                                
                                let desc = index * 3
                                let date = (index * 3) + 1
                                let title = (index * 3) + 2
                                
                                //DATE
                                Text(dataArray[date])
                                    .foregroundColor(.fontColor)
                                    .font(.custom("Lora-Regular", size: 12))
                                    //.offset(x: 265, y: 5)
                                    //.padding(.top, 5)
                                
                                //IMAGES
                                TabView {
                                    ForEach(0...1, id: \.self) { i in
                                        let x = ((index * 2) + i)
                                        loadImage(imageURL: imageArray[x])
                                    }
                                    
                                }
                                .tabViewStyle(PageTabViewStyle())
                                .frame(width: UIScreen.main.bounds.width, height: 300)
                                
                                
                                //TITLE/DESCRIPTIONS
                                Text(dataArray[title])
                                    //.foregroundColor(.fontColor)
                                    .font(.custom("Lora-Regular", size: 18))
                                    //.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                
                                //Divider().frame(width: UIScreen.main.bounds.width)
                                
                                Text(dataArray[desc])
                                    .foregroundColor(.fontColor)
                                    .font(.custom("Lora-Regular", size: 14))
                                    //.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                                
                                
                                
                            }
                        } else {
                            // Fallback on earlier versions
                        }
                        
                    }
                    .onAppear() {
                        getFromFirebase()
                        getStrings()
                    }
                }
            }
            
            // LOCAL
            if #available(iOS 14.0, *) {
                List {
                    ScrollView(.vertical) {
                        VStack () {
                            
                            NavigationLink(destination: CameraView(tabSelection: $tabSelection, postArray: $postArray)) {
                                Text("Somehow add this feature to images.")
                            }
                            
                            //VStack() {
                            //    ForEach(postArray, id: \.id) { post in
                            //        InspoPostView(post: post)
                            //    }
                            //}
                        }
                    }
                }
                .padding(.leading, -20)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack() {
                            Image(systemName: "wand.and.stars.inverse")
                            Text("ALLURE")
                                .font(Font.custom("Exo2-Light", size: 24))
                                //.font(.system(size: 24))
                        }
                    }
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

struct loadImage: View {
        
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

struct InspoPostView: View {
    
    let post: Post
    
    var body: some View {
        
        VStack (alignment: .leading) {
            
            Text(post.date)
                .foregroundColor(.fontColor)
                .font(.custom("Lora-Regular", size: 12))
                .offset(x: 265, y: 5)
                .padding(.top, 5)
            
            NavigationLink(destination: PostView(post: post)) {
                if #available(iOS 14.0, *) {
                    TabView() {
                        //bare image
                        //
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
                        }
                    //}
                    .tabViewStyle(PageTabViewStyle())
                    
                } else {
                    // Fallback on earlier versions
                }
            }
            
            //title, description
            Text(self.post.title)
                //.foregroundColor(.fontColor)
                .font(.custom("Lora-Regular", size: 18))
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            
            Divider().frame(width: UIScreen.main.bounds.width)
            
            Text(self.post.desc)
                .foregroundColor(.fontColor)
                .font(.custom("Lora-Regular", size: 14))
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        
        }
        .padding(.bottom, 20)
        .border(Color.fontColor, width: 1)
        
    }
}


struct InspoView_Previews: PreviewProvider {
    static var previews: some View {
        InspoPreviewWrapper();
    }
}

struct InspoPreviewWrapper: View {
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
    var date: String
    var title: String
    var desc: String
    

    init(id: String, firstPic: UIImage, lastPic: UIImage, videos: [URL], date: String, title: String, desc: String) {
        self.id = id
        self.firstPic = firstPic
        self.lastPic = lastPic
        self.videos = videos
        //self.instructions = instructions
        self.date = date
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

