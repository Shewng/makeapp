//
//  ContentView.swift
//  makeup
//
//  Created by Shwong on 2020-10-21.
//  Copyright © 2020 Shwong. All rights reserved.
//

import SwiftUI

#if canImport(UIKIT)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


//helper to print for debugging
//https://stackoverflow.com/questions/56517813/how-to-print-to-xcode-console-in-swiftui
extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

extension Color {
    static let grayColor = Color(UIColor.darkGray)
}

struct ExDivider: View {
    
    @State private var width: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .frame(width: width)
            .edgesIgnoringSafeArea(.horizontal)
    }
}

struct ContentView: View {
    
    @State private var tabSelection: Int = 1
    @State private var postArray: [Post] = []
    
    func initializePosts() {
        let img1: UIImage = UIImage(named: "post1bare")!
        let img2: UIImage = UIImage(named: "post1full")!
        let img3: UIImage = UIImage(named: "post2bare")!
        let img4: UIImage = UIImage(named: "post2full")!
        
        let post1: Post = .init(
            id: "1",
            firstPic: img1,
            lastPic: img2,
            videos: [],
            instructions: "I use a pencil eyeliner instead of liquid. I just like the natural look a lot more, but use what you like! My lip gloss is from Charlotte Tilbury 'Jewel Lips', but it's sold out everywhere unfortunately...\n\nThe most important thing that I make sure to watch for is how glossy my face is. You can easily do this by applying the right moisturizer/facial oils before you do your routine. My routine is specific to my skin cause it's more sensitive, you do you.\n\nAlso I cannot stress this enough. AVOID USING POWDERS!! Most people know this, but they usually leave a matte finish and soak some of the moisture from your skin. Things like patting face powder for instance.\n",
            date: "June 16, 2020",
            title: "Quick and Natural Look of the Day :)",
            desc: "Feeling really confident with my current makeup routine, glossy and just enough of my personal touch. It's all in the smaller details!!")
        let post2: Post = .init(
            id: "2",
            firstPic: img3,
            lastPic: img4,
            videos: [],
            instructions: "No special gimmicks. For my complextion, I use FENTY BEAUTY primer, Youngblood mineral foundation and FENTY BEAUTY bronzer. Yup, only 3 things! When creating your natural look, try to limit the products to the essential ones for your skin.\n\n1. Use primer! It can smooth out your pores without clogging them like foundation usually does. Added benefit of making the skin look hydrated.\n\n2. Tinted colors. Basically, you still want your skin to show those unique features like freckles, color hue (redness/pale) and imperfections. By avoiding harsher tones, it really gives you your natural, personal look!\n\n3. Creams creams creams. No need for powders, cream bronzers, contour creams, you name it!\n\n4. Natural brows are easy to achieve. Make them look bushy, use a brow gel, and brush them in the proper direction.\n\n5. Use mascara sparringly, or skip it entirely. Something that is a 'cheat' is using brown mascara, making your lashes not as harsh with black color. Since your skin is the defining feature of natural looks, many just skip it entirely!!\n",
            date: "August 8, 2020",
            title: "Tips for the infamous natural look!",
            desc: "Explaining some tips for creating your own natural look. Simple and uncomplicated, as natural beauty should be!")
        postArray.append(post1)
        postArray.append(post2)
    }
    
    var body: some View {
        TabView(selection: $tabSelection) {
            InspoView(tabSelection: $tabSelection, postArray: $postArray)
                .tabItem {
                    Image(systemName: "rectangle.stack.person.crop")
                    Text("Inspo")
                }
                .tag(1)
            CameraView(tabSelection: $tabSelection, postArray: $postArray)
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Create")
                }
                .tag(2)
        }
        .accentColor(Color.pink)
        .onAppear() {
            initializePosts()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

