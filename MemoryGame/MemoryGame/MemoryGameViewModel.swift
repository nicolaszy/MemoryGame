//
//  EmojiMemoryGame.swift
//  MemoryGame
//
//  Created by Oliver Gepp on 31.07.20.
//  Copyright © 2020 fhnw. All rights reserved.
//

import SwiftUI
import Contacts


class MemoryGameViewModel: ObservableObject{
    
    @Published private var model: MemoryGameModel<String>
    @Published private var imagesModel: MemoryGameModel<UIImage>
    @Published private var profileImagesModel: MemoryGameModel<UIImage>
    @Published var loading: Bool = false
    @Published var notEnoughContacts: Bool = false
    var modelKind = "Emoji"
    private var images: [UIImage] = [UIImage]()
    private var profileImages: [UIImage] = [UIImage]()
    private let group = DispatchGroup()
    
    init() {
        
        model = MemoryGameViewModel.createMemoryGame()
        imagesModel = MemoryGameModel<UIImage>(numberOfPairsOfCards: 0, cardContentFactory: { pairIndex in
            return UIImage()
        })
        profileImagesModel = MemoryGameModel<UIImage>(numberOfPairsOfCards: 0, cardContentFactory: { pairIndex in
            return UIImage()
        })
    }
    

    public func loadContacts(){
        
        loading = true
        
        let store = CNContactStore()
        let req = CNContactFetchRequest(keysToFetch: [
                CNContactImageDataKey as CNKeyDescriptor
            ])
        //TODO: fetch all the images and save them, then choose the number needed by randomly selecting between them
        profileImages.removeAll()
        do{
            try store.enumerateContacts(with: req){
                contact, stop in
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imageData = contact.imageData{
                        self.group.enter()
                        DispatchQueue.main.async {
                
                        self.profileImages.append(UIImage(data: imageData) ?? UIImage())
                        print("found a profile photo")
                        self.group.leave()
                        }
                    }
                }
        }
        }
        catch{
            print("Failed to fetch contact, error: \(error)")
            // Handle the error
        }
        
        
        group.notify(queue: .main) {
            print("finito")
            
            let numberOfImages = MemoryGameViewModel.getNumberOfCards()
            let randomNumbers = MemoryGameViewModel.generateRandomNumbers(numberOfRandomNumbers: numberOfImages, Range: self.profileImages.count)
            
            print(self.profileImages.count)
            print(numberOfImages)
            
            if(numberOfImages>self.profileImages.count || randomNumbers.count != numberOfImages){
                print("not enough contacts!")
                self.notEnoughContacts = true
            }
            else{
                //use the found contacts as cards
                self.profileImagesModel = MemoryGameModel<UIImage>(numberOfPairsOfCards: numberOfImages, cardContentFactory: { pairIndex in
                    return self.profileImages[randomNumbers[pairIndex]]
                })
                self.notEnoughContacts = false
            }
            self.loading = false
        }

    }
 
        struct Response: Decodable {
            let urls:Dictionary<String,String>
        }
    
    //struct Response: Codable { // or Decodable
    //    let urls:Array<Dictionary<String,String>>
    //}
    
    private static func generateRandomNumbers(numberOfRandomNumbers:Int, Range:Int) -> [Int]{
        
        if(Range<numberOfRandomNumbers){return [0]}
        var randomNumbers = [Int]()
        for _ in 0..<numberOfRandomNumbers{
            var randomNo = arc4random_uniform(_:UInt32(Range))
            while(randomNumbers.contains(Int(randomNo))){
                randomNo = arc4random_uniform(_:UInt32(Range))
            }
            randomNumbers.append(Int(randomNo))
        }
        return randomNumbers
    }
    
    public func createPhotosGame(){
        //get info for random image: https://api.unsplash.com/photos/random/?client_id=eef_R8O26zdmXoAXrBZ-ERg9oqsOsZ7fshG97Wh2FAE
        
        loading = true
        images.removeAll()
        
        let numberOfImages = MemoryGameViewModel.getNumberOfCards()
        print(numberOfImages)
        
        //todo: use &count=_(count) instead of for loop
            if let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=eef_R8O26zdmXoAXrBZ-ERg9oqsOsZ7fshG97Wh2FAE&count="+String(numberOfImages)) {

                self.group.enter()
                URLSession.shared.dataTask(with: url) { data, response, error in
                      if let data = data {
                          do {
                            for i in 0..<numberOfImages {
                                self.group.enter()
                                 let res = try JSONDecoder().decode([Response].self, from: data)
                                    print(res[i].urls["regular"]!)
                                 //print(res.urls[0]["regular"]!) //TODO: call fetchBackgroundImageData with it
                                let url_ = URL(string: res[i].urls["regular"]!)
                                if let url = url_ {
                                    DispatchQueue.global(qos: .userInitiated).async {
                                        if let imageData = try? Data(contentsOf: url) {
                                            DispatchQueue.main.async {
                                                self.images.append(UIImage(data: imageData)!)
                                                self.group.leave()
                                            }
                                        }
                                    }
                                }
                            }
                            self.group.leave()
                          } catch let error {
                             print(error)
                          }
                       }
                }.resume()
            }
        
        //TODO: Problem is that async operation is not yet finished
        print("images before notify: "+String(images.count))
        group.notify(queue: .main) { [self] in
            print(print("images in notify: "+String(self.images.count)))
            //start new game from here, also set the loading to false, before set it to true
            imagesModel = MemoryGameModel<UIImage>(numberOfPairsOfCards: numberOfImages, cardContentFactory: { pairIndex in
                return self.images[pairIndex]
            })
            loading = false
            }
    }
    
    private static func createMemoryGame()->MemoryGameModel<String>{
        
        //TODO: Emojisammlungen
        let clothingEmojis: Array<String> = ["🧳","🌂","☂️","🧵","🧶","👓","🕶","🥽","🥼","🦺","👔","👕","👖","🧣","🧤","🧥","🧦","👗","👘","🥻","🩱","🩲","🩳","👙","👚","👛","👜","👝","🎒","👞","👟","🥾","🥿","👠","👡","🩰","👢","👑","👒","🎩","🎓","🧢","⛑","💄","💍","💼"]
        let activityEmojis: Array<String> = ["🧶","🧵","♟️","🃏","🀄","🎴","🖼️","🎭","🎨","🧩","🧸","♠️","♥️","♦️","♣️","🕹️","🎰","🎮","🎲","🧿","🎱","🔮","🪁","🤿","🪀","🎽","🎯","🎿","🛷","🥌","⛳","⛸️","🎣","🏒","🥍","🏓","🏸","🥊","🥋","🥅"]
        let uncookedFoodEmoji: Array<String> = ["🍏","🍎","🍐","🍊","🍋","🍌","🍉","🍇","🍓","🍈","🍒","🍑","🥭","🍍","🥥","🥝", "🍅","🍆","🥑","🥦","🥬","🥒","🌶","🌽","🥕","🧄","🧅","🥔","🍠","🥐","🥯","🍞","🥖","🥨","🧀","🥚","🦴","🍧","🍨","🍦"]
        let cookedFoodEmoji: Array<String> = ["🍳","🧈","🥓","🥩","🍗","🍖","🌭","🍔","🍟","🍕","🥪","🥙","🧆","🌮","🌯","🥗","🥘","🥫","🍝","🍜","🍲","🍛","🍣","🍱","🥟","🦪","🍤","🍙","🍚","🍘","🍥","🍢","🍡","🍿","🍴","🍽","🥣","🥡","🥢","🧂"]
        let drinksAndSweetsEmoji: Array<String> = ["🥛","🍼","☕️","🍵","🧃","🥤","🍶","🍺","🍻","🥂","🍷","🥃","🍸","🍹","🧉","🍾","🧊","🥄","🥧","🧁","🍰","🎂","🍮","🍭","🍬","🍫","🥞","🧇","🍯","🍩","🍪","🥠","🌰","🥜","🥮","🎤","💸","💳","🕯"]
        
        let emojiSammlungen = [clothingEmojis, activityEmojis, uncookedFoodEmoji, cookedFoodEmoji,drinksAndSweetsEmoji]
            
        let numberOfCards = getNumberOfCards()

        var filteredCollection: Array<Array<String>> = []
        
        for i in 0..<emojiSammlungen.count{
            if(emojiSammlungen[i].count>=numberOfCards){
                //add to filtered collection
                filteredCollection.append(emojiSammlungen[i])
            }
        }
        
        let collectionToUse = filteredCollection[Int.random(in: 0..<filteredCollection.count)]
                
        let randomNumbers = MemoryGameViewModel.generateRandomNumbers(numberOfRandomNumbers: numberOfCards, Range: collectionToUse.count)
        
        return  MemoryGameModel<String>(numberOfPairsOfCards: numberOfCards, cardContentFactory: { pairIndex in
            return collectionToUse[randomNumbers[pairIndex]]
        })
    }
    
    static func getNumberOfCards() -> Int{
        let screenSize = UIScreen.main.bounds
        let width = Int(screenSize.width/100)
        let height = Int(screenSize.height/100)
        var numberOfCards = Int(width*height/60)
        print(numberOfCards)
        if numberOfCards==0 {numberOfCards=1}
        let diff = UserDefaults.standard.string(forKey: "difficulty")

        var difficulty: Double
        switch diff {
        case "Einfach":
            difficulty = 4.0
        case "Mittel":
            difficulty = 7.0
        case "Schwer":
            difficulty = 10.0
        default:
            difficulty = 4.0
        }
        
         //4.0=einfach,10.0=mittel,14.0=schwer
        numberOfCards=Int(Double(numberOfCards)*difficulty)
        
        return numberOfCards
    }
    
    // MARK: - Access to the Model
    
    var cards: Array<MemoryGameModel<String>.Card>{
        return model.cards
    }
    
    var imageCards: Array<MemoryGameModel<UIImage>.Card>{
        return imagesModel.cards
    }
    
    var profileImageCards: Array<MemoryGameModel<UIImage>.Card>{
        return profileImagesModel.cards
    }
    
    // MARK: - Intents
    
    func choose(card: MemoryGameModel<String>.Card){
        model.choose(card: card)
    }
    
    func chooseImageCard(card: MemoryGameModel<UIImage>.Card){
        imagesModel.choose(card: card)
    }
    
    func chooseProfileImageCard(card: MemoryGameModel<UIImage>.Card){
        profileImagesModel.choose(card: card)
    }
    
    func getPairCard(card: MemoryGameModel<String>.Card)->Int{
        return model.getPairCard(card: card)
    }
    
    func getImagesPairCard(card: MemoryGameModel<UIImage>.Card)->Int{
        return imagesModel.getPairCard(card: card)
    }
    func getProfileImagesPairCard(card: MemoryGameModel<UIImage>.Card)->Int{
        return profileImagesModel.getPairCard(card: card)
    }
    
    func resetGame(){
        //TODO: check what kind of game was selected (save in model?), and adjust accordingly!
        print("modell: "+modelKind)
        if(modelKind=="Emoji"){ model = MemoryGameViewModel.createMemoryGame() }
        else if(modelKind=="Fotos"){ createPhotosGame() }
        else if(modelKind=="Kontakte") { loadContacts() }
    }
    
    func noLongerGivePoints(card: MemoryGameModel<String>.Card){
        model.noLongerGivePoints(card: card)
    }
    
    func noLongerGivePointsImage(card: MemoryGameModel<UIImage>.Card){
        imagesModel.noLongerGivePoints(card: card)
    }
    
    func noLongerGivePointsProfileImage(card: MemoryGameModel<UIImage>.Card){
        profileImagesModel.noLongerGivePoints(card: card)
    }

    
}
