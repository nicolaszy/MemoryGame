//
//  MainMenu.swift
//  MemoryGame
//
//  Created by Nicolas Kalousek on 06.11.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI

struct MainMenu: View {
    @State var spielmodus = UserDefaults.standard.string(forKey: "spielmodus") ?? "Emoji"
    @State var schwierigkeit = UserDefaults.standard.string(forKey: "difficulty") ?? "Einfach"
    @Binding var showingDetail: Bool
    @ObservedObject var viewModel: MemoryGameViewModel
    @Binding var score: Double

    var body: some View {
        VStack{
        HStack{
            Text("Spielmodus wählen:")
            Menu(spielmodus){
                Button("Emoji", action: startEmoji)
                Button("Fotos", action: startFotos)
                Button("Kontakte", action: startKontakte)
            }
        }
        
        HStack{
        Text("Schwierigkeit wählen:")
        Menu{
            Button("Einfach", action: changeDifficultyEasy)
            Button("Mittel", action: changeDifficultyMedium)
            Button("Schwer", action: changeDifficultyDifficult)
        } label: {
            Text(schwierigkeit)
        }
        }
            Button("Spiel starten", action: startGame)
        }
}
        
    func changeDifficultyEasy(){
        self.schwierigkeit = "Einfach"
        UserDefaults.standard.setValue(self.schwierigkeit, forKey: "difficulty")
    }
    func changeDifficultyMedium(){
        self.schwierigkeit = "Mittel"
        UserDefaults.standard.setValue(self.schwierigkeit, forKey: "difficulty")
    }
    func changeDifficultyDifficult(){
        self.schwierigkeit = "Schwer"
        UserDefaults.standard.setValue(self.schwierigkeit, forKey: "difficulty")
    }
    
    func startEmoji(){
        self.spielmodus = "Emoji"
        UserDefaults.standard.setValue(self.spielmodus, forKey: "spielmodus")
    }
    func startFotos(){
        self.spielmodus = "Fotos"
        UserDefaults.standard.setValue(self.spielmodus, forKey: "spielmodus")
    }
    func startKontakte(){
        self.spielmodus = "Kontakte"
        UserDefaults.standard.setValue(self.spielmodus, forKey: "spielmodus")
    }
    
    func startGame(){
        score = 0
        showingDetail = false;
        viewModel.modelKind = self.spielmodus
        withAnimation(.easeInOut(duration: gameResetAnimationDuration)){
            viewModel.resetGame()
        }
    }
    
    private let gameResetAnimationDuration = Double(0.6)

}

