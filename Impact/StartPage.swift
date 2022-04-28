//
//  StartPage.swift
//  Impact
//
//  Created by Stanislau Kostka on 26.04.22.
//  Copyright © 2022 Taqtile. All rights reserved.
//

import SwiftUI
import CoreMotion
import CoreGraphics
import LinkPresentation


extension UIScreen{//Размеры экрана
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

 
extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}


struct StartPage: View {
    
    
    let screenHeight = UIScreen.screenHeight
    let screenWidth = UIScreen.screenWidth
    
    var body: some View {
        NavigationView{
            VStack{
            
                Text("Start")
                    .font(.system(size: 48))
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .bold()
                Text("Choose the game mod")
                    .padding(.top, 1.0)
                
                
                
                HStack{
                    NavigationLink(
                        destination: SoloGame(),
                        label: {
                                Image("individual")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 160, height: 360, alignment: .center)
                            }
                    )
                    
                    
                    
                    NavigationLink(
                        destination: DuoGame(),
                        label: {
                            Image("dual")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 160, height: 360, alignment: .center)
                        }
                    )
                }
                
                
                NavigationLink(
                    destination: InfoPageRus(),
                    label: {
                        Text("Whath the video")
                            .padding(.top, 1.0)
                            .accentColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                    }
                )
                
                
                NavigationLink(
                    destination: InfoPage(),
                    label: {
                        Text("Why it's important walk properly?")
                            .padding(.top, 1.0)
                            .accentColor(/*@START_MENU_TOKEN@*/.black/*@END_MENU_TOKEN@*/)
                    }
                )
                
                
            }
            .frame(width: screenWidth, alignment: .center)
            .padding(.bottom, 120.0)
        }
        .frame(width: screenWidth + 10, height: screenHeight)
    }
}



struct FirstPage_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StartPage()
            SoloGame()
            DuoGame()
            InfoPage()
            InfoPageRus()
                .previewInterfaceOrientation(.portrait)
        }
    }
}
