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


//helper to print for debugging
//https://stackoverflow.com/questions/56517813/how-to-print-to-xcode-console-in-swiftui



//https://stackoverflow.com/questions/50085231/uiimage-to-string-and-string-to-uiimage-in-swift
//helper extention to convert UIImage > String
extension UIImage {
    func toString() -> String? {
        let data: Data? = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
//helper extention to convert String > UIImage
extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}



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
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
        //myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        
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
    
    @State private var postTitle = "Add a Title!"
    @State private var postDesc = "Add a Description!"
    
    @State private var tabIndex = 1000
    
    @State private var imageIndex = 0
    @State private var videos: [URL] = []
    @State private var frameLength = 2
    
    @State private var viewID = 0
    @State private var vid = AVPlayer()
    @State private var vidList: [AVPlayer] = []
    
    
    
    
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
    
    func useProxyTextView(_ proxy: GeometryProxy) -> some View {
        
        let screenWidth: CGFloat = proxy.size.width
        let height1: CGFloat = 30
        let height2: CGFloat = 150
        
        return VStack() {
            TextView(text: self.$postTitle, constantText: "title")
                .frame(width: screenWidth, height: height1)
            
            useProxyDivider(proxy)
            
            TextView(text: self.$postDesc, constantText: "desc")
                .frame(width: screenWidth, height: height2)
            
            useProxyDivider(proxy)
        }
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            
            NavigationView {
                
                ScrollView(.vertical) {
                    VStack(alignment: .center) {
                        
                        Spacer()
                        
                        // Description box
                        self.useProxyTextView(geometry)
                        
                        
                        if #available(iOS 14.0, *) {
                            TabView(selection: self.$tabIndex) {
                                //HStack(alignment: .center, spacing: 30) {
                                //first image
                                
                                //problem with tag
                                
                                Image(uiImage: self.bareFaceImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:270, height: 300)
                                    .border(Color.black, width: 1)
                                    .clipped()
                                    .padding()
                                    .tag(1000)
                                
                                //array of videos
                                ForEach(self.videoSettings.vidArray.indices, id: \.self) { i in
                                    Print(vidList.count)
                                    
                                    VStack {
                                        player(index: i)
                                            .scaledToFill()
                                            .frame(width:270, height: 300)
                                            .border(Color.black, width: 1)
                                            .clipped()
                                            .padding()
                                    }
                                }
                                
                                Image(uiImage: self.bareFaceImageFinal)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:270, height: 300)
                                    .border(Color.black, width: 1)
                                    .clipped()
                                    .padding()
                                    .tag(1001)
                                
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .frame(width: UIScreen.main.bounds.width, height: 300)
                            .id(viewID)
                            
                            
                        } else {
                            // Fallback on earlier versions
                        }
                        

                        //.modifier(ScrollingHStackModifier(items: self.stateVideos.count + 2, itemWidth: 270, itemSpacing: 60, currentStep: self.$currentStep, imageIndex: self.$imageIndex, frameLength: self.$frameLength))
                        
                        
                        // END OF FRAMES
                        
                        HStack {
                            if (tabIndex == 1000) {
                                Text("Step 1")
                            } else if (tabIndex == 1001) {
                                Text("Step " + String(stateVideos.count + 2))
                            } else {
                                Text("Step " + String(self.viewID + 1))
                            }
                        }.padding(.bottom, 15)
                        
                        
                        // START OF BUTTONS
                        Spacer()
                        HStack(spacing: 20) {
                            
                            Button(action: {
                                self.isShowingImagePicker.toggle()
                                self.condition = 1
                                print("Upload was tapped")
                                
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 40.0))
                                    .foregroundColor(.gray)
                            }
                            
                            //need to add a index to see which photo to upload to
                            .sheet(isPresented: self.$isShowingImagePicker, content: {
                                
                                ImagePickerView(isPresented: self.$isShowingImagePicker, selectedImage: self.$bareFaceImage, selectedImageFinal: self.$bareFaceImageFinal, flag: self.$condition, stateVideos: self.$stateVideos, imageIndex: self.$imageIndex, tabIndex: self.$tabIndex, viewID: self.$viewID)
                            })
                            
                            Button(action: {
                                print("Camera Was Tapped")
                                self.condition = 2
                                self.showCamera.toggle()
                            }) {
                                Image(systemName: "camera.circle")
                                    .font(.system(size: 40.0))
                                    .foregroundColor(.gray)
                            }
                            .sheet(isPresented: self.$showCamera, content: {
                                ImagePickerView(isPresented: self.$showCamera, selectedImage: self.$bareFaceImage, selectedImageFinal: self.$bareFaceImageFinal, flag: self.$condition, stateVideos: self.$stateVideos, imageIndex: self.$imageIndex, tabIndex: self.$tabIndex, viewID: self.$viewID)
                            })
                            
                            
                            Button(action: {
                                print("Video camera Was Tapped")
                                //self.viewID += 1
                                self.condition = 3
                                self.showVideoCam.toggle()
                                self.alert.toggle()
                                
                            }) {
                                Image(systemName: "video.circle")
                                    .font(.system(size: 40.0))
                                    .foregroundColor(.gray)
                            }
                            .sheet(isPresented: self.$showVideoCam, content: {
                                ImagePickerView(isPresented: self.$showVideoCam, selectedImage: self.$bareFaceImage, selectedImageFinal: self.$bareFaceImageFinal, flag: self.$condition, stateVideos: self.$stateVideos, imageIndex: self.$imageIndex, tabIndex: self.$tabIndex, viewID: self.$viewID)
                            })
                            
                            Button(action: {
                                //print("Add was tapped")
                                //print("State", stateVideos)
                                //self.addFrame()
                                print(videoSettings.vidArray)
                                self.vidList.remove(at: 0)
                            }) {
                                Image(systemName: "chevron.right.circle")
                                    .font(.system(size: 40.0))
                                    .foregroundColor(.gray)
                            }
                            
                        }.padding(.bottom)
                        //END OF BUTTONS
                        Spacer()
                        self.useProxyDivider(geometry)
                        
                    }.frame(maxWidth: .infinity)
                } // end of scroll view
                
                .navigationBarTitle("Add new post", displayMode: .inline)
                .navigationBarItems(
                    trailing:
                        HStack {
                            Button(action: {
                                //collect all pictures/videos/descriptions and send to InspoView
                                self.tabSelection = 1
                                //self.createPost(arr: $postArray)
                                self.createPost(firstPic: self.bareFaceImage, lastPic: self.bareFaceImageFinal, videos: self.stateVideos, title: self.postTitle, desc: self.postDesc)
                                
                                self.videoSettings.vidArray.removeAll()
                                //reset the states
                                self.stateVideos.removeAll()
                                self.vid = AVPlayer()
                                //self.vidList.removeAll()
                                self.viewID = 0
                                self.tabIndex = 1000
                                self.bareFaceImage = UIImage()
                                self.bareFaceImageFinal = UIImage()
                                self.imageIndex = 0
                                
                            }) {
                                Text("Finish")
                            }
                        }
                )
            } // end of nav bar
        }
    }
    
    func createPost(firstPic: UIImage, lastPic: UIImage, videos: [URL], title: String, desc: String) {
        // create new post
        
        //assign images and videos a unique id
        //store the id in the real time data base so that when a post is created the inspo view updates
        //store the images/videos in the storage and get them when view needs to update
        
        //create a unique id
        let uuid = UUID().uuidString
        let newPost: Post = .init(id: uuid, firstPic: firstPic, lastPic: lastPic, videos: videos, title: title, desc: desc)
        
        let postDetails: [String : String] = ["title" : newPost.title, "description" : newPost.desc]
        database.child("uniquePost").child(uuid).setValue(postDetails)
        
        guard let firstPicture = newPost.firstPic.pngData() else { return }
        storage.child("images").child(uuid).child("first.png").putData(firstPicture, metadata: nil, completion: {_, error in
            guard error == nil else {
                print("failed to upload")
                return
            }
            self.storage.child("images").child(uuid).child("first.png").downloadURL(completion: { url , error in
                guard let url = url, error == nil else {
                    return
                }
                let urlString = url.absoluteURL
                print("Downloading URL: \(urlString)")
                UserDefaults.standard.set(urlString, forKey: "url")
            })
        })
        
        
        //convert string back to uiimage
        //let test2 = test!.toImage()
        //print(test2!)
        
        // append to existing array of posts
        self.postArray.append(newPost)
        
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    
    @EnvironmentObject var videoSettings: VideosData
    
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage
    @Binding var selectedImageFinal: UIImage
    @Binding var flag: Int
    @Binding var stateVideos: [URL]
    @Binding var imageIndex: Int
    @Binding var tabIndex: Int
    @Binding var viewID: Int

    
    var sourceType1: UIImagePickerController.SourceType = .savedPhotosAlbum
    var sourceType2: UIImagePickerController.SourceType = .camera
    
    func makeUIViewController(context:UIViewControllerRepresentableContext<ImagePickerView>) -> UIViewController {
        
        let controller = UIImagePickerController()
        if (flag == 1) {
            controller.sourceType = sourceType1
            
        }
        if (flag == 2) {
            controller.sourceType = sourceType2
        }
        if (flag == 3) {
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
