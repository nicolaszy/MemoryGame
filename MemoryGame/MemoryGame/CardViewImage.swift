//
//  CardView.swift
//  MemoryGame
//
//  Created by Oliver Gepp on 18.08.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI

struct CardViewImage: View{
    
    var card: MemoryGameModel<UIImage>.Card
    
    var body: some View{
            GeometryReader{geometry in
                body(for: geometry.size)
            }
    }
    
    @State private var animatedBonusRemaining: Double = 0
    
    private func startBonusTimeAnimation(){
        animatedBonusRemaining = card.bonusRemaining
        withAnimation(.linear(duration: card.bonusTimeRemaining)){
            animatedBonusRemaining = 0
        }
    }
    
    @ViewBuilder
    private func body(for size: CGSize)-> some View{
        if card.isFaceUp || !card.isMatched{
            ZStack{
                Group{
                    if card.isConsumingBonusTime{
                        Pie(startAngle: Angle(degrees: startAngleConstant),
                            endAngle: Angle(degrees: -animatedBonusRemaining * endAngleConstant - Double(90)),clockwise: true)
                            .onAppear{
                                startBonusTimeAnimation()
                        }
                    }
                    else{
                        Pie(startAngle: Angle(degrees: startAngleConstant),
                            endAngle: Angle(degrees: -card.bonusTimeRemaining * endAngleConstant - Double(90) ),clockwise: true)
                    }
                }.padding(5)
                    .opacity(opacity)
                Image(uiImage: card.content).resizable()
                    .frame(width: fontSize(for: size), height: fontSize(for: size))
                    //.fixedSize(horizontal: true, vertical: true)
                    //.font(Font.system(size: fontSize(for: size)))
                    .rotationEffect(Angle(degrees: card.isMatched ? 360 : 0))
                    .animation(card.isMatched ? Animation.linear(duration: contentRotationDuration).repeatForever(autoreverses: false) : .default)
                    .cornerRadius(100)
            }
            .cardify(isFaceUp: card.isFaceUp)
            .transition(.scale)
        }
    }
    
    // MARK: - Drawing Constants
    private let opacity = Double(0.4)
    private let cornerRadius = CGFloat(10)
    private let edgeLineWidth = CGFloat(3)
    private func fontSize(for size: CGSize)->CGFloat{
        min(size.width, size.height) * 0.6
    }
    private let startAngleConstant = Double(0-90)
    private let endAngleConstant = Double(360)
    private let contentRotationDuration = Double(1)
    
}


