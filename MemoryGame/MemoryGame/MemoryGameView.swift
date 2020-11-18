//
//  EmojiMemoryGameView.swift
//  MemoryGame
//
//  Created by Oliver Gepp on 24.07.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI

struct MemoryGameView: View {
    
    @ObservedObject var viewModel: MemoryGameViewModel
    @State var showingDetail = true
    
    @State var score: Double = 0
    @State var highScore: Double = UserDefaults.standard.double(forKey: "highscore")
    
    @State var isLoading: Bool = false
    @State var isAnimating: Bool = false
    
    var body: some View {
        VStack{
            HStack{
                Text("score: "+String(round(score*10)/10)).padding([.leading, .trailing]) //score sollte immer aktuell sein und falls höher als highscore als hightscore abgespeichert werden. dazu brauchen wir bonus time!
                Text("highscore: "+String(round(highScore*10)/10)).padding([.leading, .trailing])
                Spacer()
            }
            //loading screen
            if viewModel.loading{
                VStack{
                Circle().scaleEffect(self.isAnimating ? 0.5: 0.6).animation(
                    Animation.easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                )
                .onAppear{
                    self.isAnimating = true
                }
                Text("loading...").padding(20)
                }
                Spacer()
            }
            else if viewModel.modelKind=="Emoji"{
                Grid(viewModel.cards) { card in
                    CardView(card: card).onTapGesture {
                        withAnimation(.linear(duration: cardRotationDuration)){
                            let pairCard = viewModel.getPairCard(card: card)
                            viewModel.choose(card: card)
                            if(viewModel.cards[viewModel.cards.firstIndex(matching: card)!].isMatched && viewModel.cards[pairCard].canGivePoints){
                                if(viewModel.cards[viewModel.cards.firstIndex(matching: card)!].hasEarnedBonus){
                                    print("matched")
                                    //Timer Bonus für schnelles Aufdecken, berechnet nach 1. aufgedeckter Karte
                                    score+=viewModel.cards[pairCard].bonusTimeRemaining
                                    score+=2 //Pauschalpunktzahl für Match
                                    viewModel.noLongerGivePoints(card: viewModel.cards[viewModel.cards.firstIndex(matching: card)!])
                                    viewModel.noLongerGivePoints(card: viewModel.cards[pairCard])
                                    if(score>highScore){
                                        UserDefaults.standard.set(score, forKey: "highscore")
                                        highScore = score
                                    }
                                }
                            }
                        }
                    }
                    .padding(cardViewPadding)
                    .onAppear{
                        self.isAnimating = false
                    }
                }
            }
            else if viewModel.modelKind=="Fotos"{
                    Grid(viewModel.imageCards) { card in
                        CardViewImage(card: card).onTapGesture {
                            withAnimation(.linear(duration: cardRotationDuration)){
                                let pairCard = viewModel.getImagesPairCard(card: card)
                                viewModel.chooseImageCard(card: card)
                                if(viewModel.imageCards[viewModel.imageCards.firstIndex(matching: card)!].isMatched && viewModel.imageCards[pairCard].canGivePoints){
                                    if(viewModel.imageCards[viewModel.imageCards.firstIndex(matching: card)!].hasEarnedBonus){
                                        print("matched")
                                        //Timer Bonus für schnelles Aufdecken, berechnet nach 1. aufgedeckter Karte
                                        score+=viewModel.imageCards[pairCard].bonusTimeRemaining
                                        score+=2 //Pauschalpunktzahl für Match
                                        viewModel.noLongerGivePointsImage(card: viewModel.imageCards[viewModel.imageCards.firstIndex(matching: card)!])
                                        viewModel.noLongerGivePointsImage(card: viewModel.imageCards[pairCard])
                                        if(score>highScore){
                                            UserDefaults.standard.set(score, forKey: "highscore")
                                            highScore = score
                                        }
                                    }
                                }
                            }
                        }
                        .padding(cardViewPadding)
                        .onAppear{
                            self.isAnimating = false
                        }
                    }
            }
            else if viewModel.modelKind=="Kontakte"{
                if(viewModel.notEnoughContacts){
                    Spacer()
                    Text("You don't have enough contacts with profile pictures for this game mode.").padding(5).foregroundColor(Color.black)
                    Spacer()
                }
                else{
                    Grid(viewModel.profileImageCards) { card in
                        CardViewImage(card: card).onTapGesture {
                            withAnimation(.linear(duration: cardRotationDuration)){
                                let pairCard = viewModel.getProfileImagesPairCard(card: card)
                                viewModel.chooseProfileImageCard(card: card)
                                if(viewModel.profileImageCards[viewModel.profileImageCards.firstIndex(matching: card)!].isMatched && viewModel.profileImageCards[pairCard].canGivePoints){
                                    if(viewModel.profileImageCards[viewModel.profileImageCards.firstIndex(matching: card)!].hasEarnedBonus){
                                        print("matched")
                                        //Timer Bonus für schnelles Aufdecken, berechnet nach 1. aufgedeckter Karte
                                        score+=viewModel.profileImageCards[pairCard].bonusTimeRemaining
                                        score+=2 //Pauschalpunktzahl für Match
                                        viewModel.noLongerGivePointsProfileImage(card: viewModel.profileImageCards[viewModel.profileImageCards.firstIndex(matching: card)!])
                                        viewModel.noLongerGivePointsProfileImage(card: viewModel.profileImageCards[pairCard])
                                        if(score>highScore){
                                            UserDefaults.standard.set(score, forKey: "highscore")
                                            highScore = score
                                        }
                                    }
                                }
                            }
                        }
                        .padding(cardViewPadding)
                        .onAppear{
                            self.isAnimating = false
                        }
                    }
                }
            }
            Button(action: {
                withAnimation(.easeInOut(duration: showMenuAnimationDuration)){
                    self.showingDetail.toggle()
                }
            }) {
                Text("New Game")
            }.sheet(isPresented: $showingDetail) {
                MainMenu(showingDetail: $showingDetail, viewModel: self.viewModel, score: $score)
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: gameResetAnimationDuration)){
                    score = 0
                    viewModel.resetGame()
                }
            }, label: {
                Text("Restart Game")
            })
        }
        .foregroundColor(Color.blue)
    }
}

// MARK: - Drawing Constants
private let cardRotationDuration = Double(0.45)
private let cardViewPadding = CGFloat(5)
private let gameResetAnimationDuration = Double(0.4)
private let showMenuAnimationDuration = Double(0.25)

struct EmojiMemoryGameView_Previews: PreviewProvider {
    static var previews: some View {
        let game = MemoryGameViewModel()
        game.choose(card: game.cards[0])
        return MemoryGameView(viewModel: game)
    }
}
