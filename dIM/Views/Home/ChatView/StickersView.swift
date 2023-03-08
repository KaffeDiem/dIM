//
//  StickersView.swift
//  dIM
//
//  Created by Kasper Munch on 05/03/2023.
//

import SwiftUI

struct StickersView: View {
    @State private var data: [Sticker]
    
    init() {
        let stickersUnlocked = PurchaseManager.shared.purchasedProductIds.contains(.stickers)
        self.data = [
            .init(name: "hello-world", isUnlocked: true),
            .init(name: "fiery", isUnlocked: true),
            .init(name: "sick", isUnlocked: true),
            .init(name: "good-night", isUnlocked: stickersUnlocked),
            .init(name: "shocked", isUnlocked: stickersUnlocked),
            .init(name: "letsgo", isUnlocked: stickersUnlocked),
            .init(name: "love", isUnlocked: stickersUnlocked),
            .init(name: "crying", isUnlocked: stickersUnlocked),
            .init(name: "hiding", isUnlocked: stickersUnlocked),
            .init(name: "lmao", isUnlocked: stickersUnlocked),
            .init(name: "cheering", isUnlocked: stickersUnlocked),
            .init(name: "morning", isUnlocked: stickersUnlocked),
            .init(name: "celebration", isUnlocked: stickersUnlocked),
            .init(name: "yes", isUnlocked: stickersUnlocked),
            .init(name: "fine", isUnlocked: stickersUnlocked),
            .init(name: "confused", isUnlocked: stickersUnlocked),
            .init(name: "devilangel", isUnlocked: stickersUnlocked),
            .init(name: "boss", isUnlocked: stickersUnlocked),
        ]
    }
    
    var body: some View {
        CollectionView<AnimationViewCell>(items: $data) { sticker in
            print(sticker.name, sticker.isUnlocked)
        }
    }
}

struct StickersView_Previews: PreviewProvider {
    static var previews: some View {
        StickersView()
    }
}
