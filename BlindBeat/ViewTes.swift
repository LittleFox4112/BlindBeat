//
//  ViewTes.swift
//  BlindBeat
//
//  Created by Quinela Wensky on 15/05/24.
//

//import SwiftUI
//import SpriteKit
//
//struct ViewTes: View {
//    let screenWidth = UIScreen.main.bounds.width
//    let screenHeight = UIScreen.main.bounds.height
//
//    var body: some View {
//        SKViewRepresentable()
//            .frame(width: screenWidth, height: screenHeight, alignment: .center)
//            .edgesIgnoringSafeArea(.all)
//    }
//}
//
//struct SKViewRepresentable: UIViewRepresentable {
//    func makeUIView(context: Context) -> SKView {
//        let skView = SKView()
//        if let scene = SKScene(fileNamed: "DodgeScene") {
//            scene.scaleMode = .aspectFill
//            scene.backgroundColor = .clear
//            skView.presentScene(scene)
//        }
//        return skView
//    }
//
//    func updateUIView(_ uiView: SKView, context: Context) {
//        // Tidak ada pembaruan yang diperlukan
//    }
//}
//
//#Preview {
//    ViewTes()
//}
