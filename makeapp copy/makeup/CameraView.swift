//
//  CameraView.swift
//  makeup
//
//  Created by William Zhou on 2020-10-21.
//  Copyright © 2020 Shwong. All rights reserved.
//

import SwiftUI
import AVFoundation
import AVKit
import Firebase
import FirebaseDatabase
import FirebaseStorage


struct TextView: UIViewRepresentable {
    @Binding var text: String
    var constantText: String = ""
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        
        let myTextView = UITextView()
        myTextView.delegate = context.coordinator
        
        myTextView.contentInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
        myTextView.textColor = UIColor.lightGray
        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        myTextView.isScrollEnabled = true
        
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        
        var parent: TextView
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if (textView.textColor == UIColor.lightGray) {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if (textView.text.isEmpty && parent.constantText == "title") {
                textView.text = "Add a Title!"
                textView.textColor = UIColor.lightGray
            } else if (textView.text.isEmpty && parent.constantText == "desc") {
                textView.text = "Add a Description!"
                textView.textColor = UIColor.lightGray
            } else if (textView.text.isEmpty && parent.constantText == "instruc") {
                textView.text = "Add a Description!"
                textView.textColor = UIColor.lightGray
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}


struct CameraView: View {
    
    private let database = Database.database().reference()
    private let storage = Storage.storage().reference()
    
    
    @ObservedObject var model = Model() // list of pictures/videos
    //@ObservedObject var vidArray = VideosData()
    
    @EnvironmentObject var videoSettings: VideosData
    
    @State private var stateVideos: [URL] = []
    @State private var currentStep: Int = 1
    
    @State private var bareFaceImageFinal = UIImage()
    @State private var bareFaceImage = UIImage()
    @State private var isShowingImagePicker = false
    
    @State private var showCamera = false
    @State private var showVideoCam = false
    @State private var condition = 1
    @State private var isDisabled = false
    @State private var alert = false
    @State private var backgroundOffset: CGFloat = 0
    
    @State private var date = ""
    @State private var finishFlag = true
    
    @State private var postTitle = "Add a Title!"
    @State private var postDesc = "Add a Description!"
    @State private var postNotes = "Add some notes!"
    
    @State private var instructions = ""
    @State private var tester: String = ""
    
    @State private var tabIndex = 1000
    @State private var videos: [URL] = []
    @State private var frameLength = 2
    
    @State private var viewID = 0
    @State private var vid = AVPlayer()
    @State private var vidList: [AVPlayer] = []
    
    var pageIndex = 0
    
    
    @Binding var tabSelection: Int
    @Binding var postArray: [Post]
    
    func addFrame() {
        let id = model.frames.count + 1
        let image = UIImage()
        model.frames.append(Frame(id: id, name: "Frame\(id)", image: image))
        frameLength = model.frames.count
        
    }
    
    func addVid(b:URL){
        stateVideos.append(b)
    }
    
    func useProxyDivider(_ proxy: GeometryProxy) -> some View {
        let screenWidth: CGFloat = proxy.size.width
        let screenHeight: CGFloat = proxy.size.height
        
        return Divider().frame(width: screenWidth)
    }
    
    func useProxyTextViewTitleDesc(_ proxy: GeometryProxy) -> some View {
        
        let screenWidth: CGFloat = proxy.size.width
        let height1: CGFloat = 30
        let height2: CGFloat = 150
        
        return VStack() {
            TextView(text: self.$postTitle, constantText: "title")
                .frame(width: screenWidth, height: height1)
            
            useProxyDivider(proxy)
            
            TextView(text: self.$postDesc, constantText: "desc")
                .frame(width: screenWidth, height: height2)
        }
    }
    
    func useProxyTextViewInstruc(_ proxy: GeometryProxy) -> some View {
        
        let screenWidth: CGFloat = proxy.size.width
        let height1: CGFloat = 200
        
        return VStack() {
            TextView(text: self.$postNotes, constantText: "instruc")
                .frame(width: screenWidth, height: height1)
        }
    }
    
    func getDate() -> some View {
        let monthDate = Date()
        let dayDate = Date()
        let yearDate = Date()
        let monthFormat = DateFormatter()
        let dayFormat = DateFormatter()
        let yearFormat = DateFormatter()
        
        monthFormat.dateFormat = "MMMM"
        dayFormat.dateFormat = "dd"
        yearFormat.dateFormat = "yyyy"
        
        let month = monthFormat.string(from: monthDate)
        let day = dayFormat.string(from: dayDate)
        let year = yearFormat.string(from: yearDate)
        
        let stringDate = month.prefix(3) + " " + day + ", " + year
        
        
        date = stringDate    // set state var
        
        return VStack(alignment: .leading) {
            Text(date)
                .foregroundColor(.grayColor)
                .font(.system(size: 12))
                .offset(x: -140)
        }
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            NavigationView {
                
                ScrollView(.vertical) {
                    
                    /**
                     TITLE DESCRIPTION
                     */
                    VStack() {
                        Spacer()
                        // Description box
                        self.useProxyTextViewTitleDesc(geometry)
                        
                        // Date
                        self.getDate()
                        
                        self.useProxyDivider(geometry)
                    }
                    
                    /**
                     IMAGES/VIDEOS TABVIEW
                     */
                    VStack() {
                        if #available(iOS 14.0, *) {
                            TabView(selection: self.$tabIndex) {
                                
                                //first image
                                VStack {
                                    Text("First Image")
                                    
                                    Image(uiImage: self.bareFaceImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 300)
                                        .border(Color.grayColor, width: 1)
                                        .clipped()
                                        //.padding()
                                        
                                }
                                .tag(1000)
                                
                                //array of videos
                                ForEach(self.videoSettings.vidArray.indices, id: \.self) { i in
                                    Print(vidList.count)
                                    
                                    VStack {
                                        Text("Step " + String(i + 1))
                                        
                                        player(index: i)
                                            .scaledToFill()
                                            .frame(width: 300, height: 300)
                                            .border(Color.grayColor, width: 1)
                                            .clipped()
                                            //.padding()
                                    }
                                    .tag(i)
                                }
                                
                                VStack{
                                    Text("Add Video Here!")
                                    
                                    Rectangle()
                                        .fill(Color.grayColor)
                                        .frame(width: 300, height: 300)
                                        .border(Color.grayColor, width: 1)
                                        .clipped()
                                        //.padding()
                                    
                                }
                                .tag(1002)
                                
                                VStack{
                                    Text("Last Image")
                                    
                                    Image(uiImage: self.bareFaceImageFinal)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 300, height: 300)
                                        .border(Color.grayColor, width: 1)
                                        .clipped()
                                        //.padding()
                                    
                                }
                                .tag(1001)
                                
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(width: UIScreen.main.bounds.width, height: 370)
                            .id(viewID)
                            
                            
                        } else {
                            // Fallback on earlier versions
                        }
                    }
                    

                        //.modifier(ScrollingHStackModifier(items: self.stateVideos.count + 2, itemWidth: 270, itemSpacing: 60, currentStep: self.$currentStep, imageIndex: self.$imageIndex, frameLength: self.$frameLength))
                        
                        
                        // END OF FRAMES
                        
                        /*
                        HStack {
                            if (tabIndex == 1000) {
                                Text("Step 1")
                            } else if (tabIndex == 1001) {
                                Text("Step " + String(stateVideos.count + 2))
                            } else if (tabIndex == 1002){
                                Text("Add Video Here!")
                            }
                            else {
                                Text("Step " + String(pageIndex))
                            }
                        }.padding(.bottom, 15)
                        */
                        
                    
                    /**
                     BUTTONS
                     */
                    VStack() {
                        HStack(alignment: .center, spacing: 40) {
                            
                            VStack {
                                Button(action: {
                                    self.isShowingImagePicker.toggle()
                                    self.condition = 1
                                    print("Upload was tapped")
                                    
                                }) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 25.0))
                                        .foregroundColor(.black)
                                }
                                //need to add a index to see which photo to upload to
                                .sheet(isPresented: self.$isShowingImagePicker, content: {
                                    ImagePickerView(isPresented: self.$isShowingImagePicker, selectedImage: self.$bareFaceImage, selectedImageFinal: self.$bareFaceImageFinal, flag: self.$condition, finishFlag: self.$finishFlag, stateVideos: self.$stateVideos, tabIndex: self.$tabIndex, viewID: self.$viewID)
                                })
                                Text("Upload")
                                    .font(.system(size: 10.0))
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            VStack {
                                Button(action: {
                                    self.condition = 2
                                    self.showCamera.toggle()
                                }) {
                                    Image(systemName: "camera")
                                        .font(.system(size: 25.0))
                                        .foregroundColor(.black)
                                }
                                .sheet(isPresented: self.$showCamera, content: {
                                    ImagePickerView(isPresented: self.$showCamera, selectedImage: self.$bareFaceImage, selectedImageFinal: self.$bareFaceImageFinal, flag: self.$condition, finishFlag: self.$finishFlag, stateVideos: self.$stateVideos, tabIndex: self.$tabIndex, viewID: self.$viewID)
                                })
                                Text("Camera")
                                    .font(.system(size: 10.0))
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            VStack {
                                Button(action: {
                                    self.condition = 3
                                    self.showVideoCam.toggle()
                                    self.alert.toggle()
                                    
                                }) {
                                    Image(systemName: "play.rectangle")
                                        .font(.system(size: 25.0))
                                        .foregroundColor(.black)
                                }
                                .sheet(isPresented: self.$showVideoCam, content: {
                                    ImagePickerView(isPresented: self.$showVideoCam, selectedImage: self.$bareFaceImage, selectedImageFinal: self.$bareFaceImageFinal, flag: self.$condition, finishFlag: self.$finishFlag, stateVideos: self.$stateVideos, tabIndex: self.$tabIndex, viewID: self.$viewID)
                                })
                                Text("Record")
                                    .font(.system(size: 10.0))
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            VStack {
                                Button(action: {
                                    videoSettings.vidArray.removeAll()
                                    self.bareFaceImage = UIImage()
                                    self.bareFaceImageFinal = UIImage()
                                    self.finishFlag = true
                                }) {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 25.0))
                                        .foregroundColor(.black)
                                }
                                Text("Clear")
                                    .font(.system(size: 10.0))
                                    .foregroundColor(.black)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            
                        }
                        .padding(.bottom)
                    }
                    
                    /**
                     INSTRUCTIONS
                     */
                    VStack(alignment: .leading) {
                        Spacer()
                        
                        self.useProxyDivider(geometry)
                        
                        VStack(alignment: .leading) {
                            Spacer()
                        
                            HStack() {
                                Image(systemName: "doc.plaintext")
                                    .font(.system(size: 25.0))
                                
                                Text("Routine Notes")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .padding(.leading, 10)
                            
                            VStack {
                                useProxyTextViewInstruc(geometry)
                            }
                            
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                } // end of scroll view
                
                .onTapGesture{ self.hideKeyboard() }
                //.gesture(DragGesture().onChanged { _ in
                //    self.hideKeyboard()
                //})
                
                
                .navigationBarTitle("Add new post", displayMode: .inline)
                .navigationBarItems(
                    trailing:
                        HStack {
                            Button(action: {
                                
                                
                                // Collect all pictures/videos/descriptions and send to InspoView
                                self.tabSelection = 1
                                self.createPost(firstPic: self.bareFaceImage, lastPic: self.bareFaceImageFinal, videos: self.videoSettings.vidArray, instructions: self.postNotes, currentDate: self.date, title: self.postTitle, desc: self.postDesc)
                                
                                // reset the states
                                self.videoSettings.vidArray.removeAll()
                                self.stateVideos.removeAll()
                                self.vid = AVPlayer()
                                self.finishFlag = true
                                self.date = ""
                                self.postTitle = ""
                                self.postDesc = ""
                                self.postNotes = ""
                                self.viewID = 0
                                self.tabIndex = 1000
                                self.bareFaceImage = UIImage()
                                self.bareFaceImageFinal = UIImage()
                                
                            }) {
                                Text("Finish")
                            }
                            .disabled(finishFlag)
                        }
                )
            } // end of nav bar
        }
    }
    
    func createPost(firstPic: UIImage, lastPic: UIImage, videos: [URL], instructions: String, currentDate: String, title: String, desc: String) {
        // create new post
        
        //assign images and videos a unique id
        //store the id in the real time data base so that when a post is created the inspo view updates
        //store the images/videos in the storage and get them when view needs to update
        
        //create a unique id
        let uuid = UUID().uuidString
        
        let newPost: Post = .init(id: uuid, firstPic: firstPic, lastPic: lastPic, videos: videos, instructions: instructions, date: currentDate, title: title, desc: desc)
        
        /*
        //add to realtime database the title, desc
        let postDetails: [String : String] = ["title" : newPost.title, "description" : newPost.desc]
        database.child("uniquePost").child(uuid).setValue(postDetails)
        
    
        
        //loop thru video array and upload each video
        for index in 0..<newPost.videos.count {
            let videoName = "vid" + String(index) + ".mov"
            guard let vid = NSData(contentsOf: newPost.videos[index]) as Data? else { return }
            storage.child("uniquePost").child(uuid).child("videos").child(videoName).putData(vid, metadata: nil, completion: {_, error in
                guard error == nil else {
                    print("failed to upload")
                    return
                }
                print("Video Uploaded")
                self.storage.child("uniquePost").child(uuid).child("videos").child(videoName).downloadURL(completion: { url , error in
                    guard let url = url, error == nil else {
                        return
                    }
                    let urlString = url.absoluteURL
                    print("Video downloading URL: \(urlString)")
                    UserDefaults.standard.set(urlString, forKey: "videoUrl")
                })
            })
        }
        

        
        
        //add first picture to database
        guard let firstPicture = newPost.firstPic.pngData() else { return }
        storage.child("uniquePost").child(uuid).child("images").child("first.png").putData(firstPicture, metadata: nil, completion: {_, error in
            guard error == nil else {
                print("failed to upload")
                return
            }
            self.storage.child("uniquePost").child(uuid).child("images").child("first.png").downloadURL(completion: { url , error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteURL
                print("Downloading URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "firstImageURL")
            })
        })
        
        //add last picture to database
        guard let lastPicture = newPost.lastPic.pngData() else { return }
        storage.child("uniquePost").child(uuid).child("images").child("last.png").putData(lastPicture, metadata: nil, completion: {_, error in
            guard error == nil else {
                print("failed to upload")
                return
            }
            self.storage.child("uniquePost").child(uuid).child("images").child("last.png").downloadURL(completion: { url , error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteURL
                print("Downloading URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "lastLmageURL")
            })
        })
        */
        
        // append to existing array of posts
        self.postArray.insert(newPost, at: 0)
        
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    
    @EnvironmentObject var videoSettings: VideosData
    
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage
    @Binding var selectedImageFinal: UIImage
    @Binding var flag: Int
    @Binding var finishFlag: Bool
    @Binding var stateVideos: [URL]
    @Binding var tabIndex: Int
    @Binding var viewID: Int
    
    
    var sourceType1: UIImagePickerController.SourceType = .photoLibrary
    var sourceType2: UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context:UIViewControllerRepresentableContext<ImagePickerView>) -> UIViewController {
        
        let controller = UIImagePickerController()
        if (flag == 1) {
            if (tabIndex == 1000 || tabIndex == 1001) {
                controller.sourceType = sourceType1
            } else {
                controller.sourceType = sourceType1
                controller.mediaTypes = ["public.movie"]
            }
        }
        if (flag == 2) {
            controller.sourceType = sourceType2
        }
        if (flag == 3) {
            controller.sourceType = sourceType2
            controller.mediaTypes = ["public.movie"]
        }
        controller.delegate = context.coordinator
        return controller
    }
    
    
    func makeCoordinator() -> ImagePickerView.Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        
        let parent: ImagePickerView
        init(parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            //need to find index of frame
            //if index is 0 we set the first frame's image
            if (self.parent.tabIndex == 1000) {
                if let selectedImageFromPicker = info[.originalImage] as? UIImage {
                    self.parent.selectedImage = selectedImageFromPicker
                }
            }
            
            //if on last frame
            if (self.parent.tabIndex == 1001) {
                if let selectedImageFromPicker = info[.originalImage] as? UIImage {
                    self.parent.selectedImageFinal = selectedImageFromPicker
                }
            }
            
            if let videoURL = info[.mediaURL] as? URL {
                self.parent.videoSettings.vidArray.append(videoURL)
                self.parent.viewID += 1
                self.parent.stateVideos.append(videoURL)
                
                if (self.parent.tabIndex == 1002){
                    self.parent.tabIndex = (parent.videoSettings.vidArray.count - 1)
                }
            }
            
            let image1: UIImage? = self.parent.selectedImage
            let image2: UIImage? = self.parent.selectedImageFinal
            if (image1?.size.width != 0 && image2?.size.width != 0) {
                self.parent.finishFlag = false
            }
            
            self.parent.isPresented = false
        }
    }
    
    func updateUIViewController(_ uiViewController: ImagePickerView.UIViewControllerType, context: UIViewControllerRepresentableContext<ImagePickerView>) {
    }
}

struct player : UIViewControllerRepresentable{
    
    var index:Int
    @EnvironmentObject var videoSettings: VideosData
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<player>) -> AVPlayerViewController {
        
        //frameLength += 1
        let controller = AVPlayerViewController()
        controller.videoGravity = .resizeAspectFill
        let player1 = AVPlayer(url: videoSettings.vidArray[index])
        controller.player = player1
        
        //controller.player = vid
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<player>) {
        
    }
}


class Frame: NSObject {
    var id: Int
    var name: String
    var image: UIImage
    
    init(id: Int, name: String, image: UIImage) {
        self.id = id
        self.name = name
        self.image = image
    }
}

class Model: ObservableObject {
    @Published var frames: [Frame] = []
    @State var b1 = UIImage()
    @State var b2 = UIImage()
    
    init() {
        frames = [
            Frame(id: 1, name: "Frame1", image: b1),
            //Frame(id: 2, name: "Frame2", image: b2),
        ]
    }
}



struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CamPreviewWrapper()
    }
}

struct CamPreviewWrapper: View {
    @State(initialValue: 1) var code: Int
    @State(initialValue: []) var postArray: [Post]
    
    var body: some View {
        CameraView(tabSelection: $code, postArray: $postArray)
    }
}


class VideosData: ObservableObject {
    @Published var vidArray: [URL] = []
}
