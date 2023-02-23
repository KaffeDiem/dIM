//
//  BannerModifier.swift
//  dIM
//
//  Created by Kasper Munch on 18/02/2023.
//

import Foundation
import SwiftUI

/// A custom alert that slides down from the top of the view.
/// Should be shown with the View extension.
struct BannerModifier: ViewModifier {
    struct BannerData {
        enum Kind {
            case error
            case success
            case normal
            
            var color: Color {
                switch self {
                case .error: return Color("alertFailure")
                case .normal: return Color("alertNeutral")
                case .success: return Color("alertSuccess")
                }
            }
        }
        
        let title: String
        let message: String
        let kind: Kind
        
        init(title: String, message: String, kind: Kind = .normal) {
            self.title = title
            self.message = message
            self.kind = kind
        }
    }
    
    @Binding var data: BannerData
    @Binding var shouldShow: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if shouldShow {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(data.title)
                                .bold()
                            Text(data.message)
                                .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding(12)
                    .background(data.kind.color)
                    .cornerRadius(8)
                    Spacer()
                }
                .zIndex(99)
                .animation(.default, value: shouldShow)
                .padding()
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation(.easeOut) {
                        shouldShow = false
                    }
                }
                .onAppear {
                    switch data.kind {
                    case .error: ()
                    default:
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation(.spring()) {
                                shouldShow = false
                            }
                        }
                    }
                }
            }
        }
    }
}
