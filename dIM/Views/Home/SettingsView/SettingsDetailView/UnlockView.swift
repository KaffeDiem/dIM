//
//  UnlockView.swift
//  dIM
//
//  Created by Kasper Munch on 06/03/2023.
//

import SwiftUI
import Shiny

struct PurchaseCell: View {
    typealias OnTap = () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    let name: String
    let price: String
    let description: String
    let onTap: OnTap
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.heavy)
                HStack {
                    Text(description)
                }
            }
            Spacer()
            Button {
                onTap()
            } label: {
                Text(price)
                    .fontWeight(.bold).shiny(.hyperGlossy(.systemGray2))
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(colorScheme == .light ? .black : .white )
                .opacity(0.05)
        )
    }
}

struct UnlockView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    FeatureCell(image: Image("appiconsvg"), title: "Support & Unlock", subtitle: "Support the development of dIM by unlocking additional features.")
                        .padding()
                    
                    if purchaseManager.isProductsLoaded {
                        if purchaseManager.availableProductsNotPurchased.isEmpty {
                            Text("All available products has been purchased. Thank you for your support.")
                                .padding()
                        } else {
                            ForEach(purchaseManager.availableProductsNotPurchased) { product in
                                PurchaseCell(name: product.displayName, price: product.displayPrice, description: product.description) {
                                    Task {
                                        try? await purchaseManager.purchase(product)
                                    }
                                }.padding()
                            }
                        }
                    } else {
                        ProgressView().fontWeight(.heavy)
                            .padding(50)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    Button {
                        Task {
                            try? await purchaseManager.restore()
                        }
                    } label: {
                        Text("Restore purchases")
                    }
                    .padding()
                }
            }
        }.task {
            do {
                try await purchaseManager.loadProducts()
            } catch {
                print(error.localizedDescription)
            }
        }
        .navigationTitle("Unlock features")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnlockView()
                .environmentObject(PurchaseManager())
            
            PurchaseCell(name: "Animated stickers", price: "1.99 US$", description: "Unlock animated stickers in dIM chat", onTap: {})
        }
    }
}