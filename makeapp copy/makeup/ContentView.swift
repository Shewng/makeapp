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
    static let fontColor = Color(UIColor.darkGray)
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
    
    var body: some View {
        TabView(selection: $tabSelection) {
            InspoView(tabSelection: $tabSelection, postArray: $postArray)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Inspo")
                }
                .tag(1)
            CameraView(tabSelection: $tabSelection, postArray: $postArray)
                .tabItem {
                    Image(systemName: "plus.square")
                    Text("Camera")
                }
                .tag(2)
        }.accentColor(.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

