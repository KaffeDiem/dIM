//
//  ExplanatoryView.swift
//  bluetoothChat
//
//  Created by Kasper Munch on 19/12/2021.
//

import SwiftUI

/// A snapping carousel view used for the onboarding experience for dIM.
///
/// It works as a few slides of short explanatory slides giving users a first
/// impression of what dIM is and how it works.
struct SnapCarousel: View {
    @EnvironmentObject var UIState: UIStateModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let spacing: CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32 /// UIScreen.main.bounds.width - 10
        let cardHeight: CGFloat = 279
        
        let items = [
            Card(id: 0, text: "Send offline messages.", image: "appiconsvg"),
            Card(id: 1, text: "Messages are sent through the Bluetooth connection of other dIM users.", image: "ExplanatoryMulti"),
            Card(id: 2, text: "Bluetooth has a range of 100m (330ft), therefore you must be close to other users of dIM.", image: "ExplanatoryRange"),
            Card(id: 3, text: "Your messages are safe. No one will ever have access to your messages except for you and the receiver.", image: "ExplanatoryLock"),
            Card(id: 4, text: "Contacts are added by scanning each others QR code with the iPhone camera.", image: "ExplanatoryQR"),
            Card(id: 5, text: "", image: "appiconsvg")
        ]
        
        return Canvas {
            Carousel(
                numberOfItems: CGFloat(items.count),
                spacing: spacing,
                widthOfHiddenCards: widthOfHiddenCards
            ) {
                ForEach(items, id: \.self.id) { item in
                    Item(
                        _id: Int(item.id),
                        spacing: spacing,
                        widthOfHiddenCards: widthOfHiddenCards,
                        cardHeight: cardHeight
                    ) {
                        VStack {
                            Spacer()
                            Image(item.image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 128)
                            Spacer()
                            // Show a link on the last slide instead of text
                            if item.id == items.count - 1 {
                                Link("Read more", destination: URL(string: "https://dimchat.org")!)
                                    .foregroundColor(Color.accentColor)
                            } else {
                                Text("\(item.text)")
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(20)
                    }
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    .background(colorScheme == .dark ? Color("setup-grayDARK") : Color("setup-grayLIGHT"))
                    .cornerRadius(20)
                    .transition(AnyTransition.slide)
                    .animation(.spring())
                }
            }
        }
    }
}

struct Card: Decodable, Hashable, Identifiable {
    var id: Int
    var text: String = ""
    var image: String
}

public class UIStateModel: ObservableObject {
    @Published var activeCard: Int = 0
    @Published var screenDrag: Float = 0.0
}

private struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat //= 8
    let spacing: CGFloat //= 16
    let widthOfHiddenCards: CGFloat //= 32
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: UIStateModel
        
    @inlinable public init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
    }
    
    var body: some View {
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
                
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)

        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
            
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if (value.translation.width < -50 && CGFloat(self.UIState.activeCard) < numberOfItems - 1) {
                self.UIState.activeCard = self.UIState.activeCard + 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if  (value.translation.width > 50 && CGFloat(self.UIState.activeCard) > 0) {
                self.UIState.activeCard = self.UIState.activeCard - 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        })
    }
}

private struct Canvas<Content : View> : View {
    let content: Content
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
    }
}

private struct Item<Content: View>: View {
    @EnvironmentObject var UIState: UIStateModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat

    var _id: Int
    var content: Content

    @inlinable public init(
        _id: Int,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        cardHeight: CGFloat,
        @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
        self.cardHeight = cardHeight
        self._id = _id
    }

    var body: some View {
        content
            .frame(width: cardWidth, height: _id == UIState.activeCard ? cardHeight : cardHeight - 80, alignment: .center)
    }
}

struct SnapCarousel_Previews: PreviewProvider {
    static var previews: some View {
        SnapCarousel()
//            .preferredColorScheme(.dark)
            .environmentObject(UIStateModel())
    }
}
