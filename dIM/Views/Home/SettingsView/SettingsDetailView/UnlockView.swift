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
    
    let name: String
    let price: String
    let description: String
    let onTap: OnTap
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                HStack {
                    Text(description)
                        .font(.headline)
                }
            }
            Spacer()
            Button {
                onTap()
            } label: {
                Text(price)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .shiny(.hyperGlossy(.orange))
                    )
           }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.white)
                .opacity(0.1)
        )
    }
}

struct UnlockView: View {
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    var body: some View {
        ZStack {
            if !purchaseManager.isProductsLoaded {
                ProgressView()
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    FeatureCell(image: Image("appiconsvg"), title: "Support & Unlock", subtitle: "Support the development of dIM by unlocking additional features.")
                        .padding()
                    
                    ForEach(purchaseManager.availableProducts) { product in
                        PurchaseCell(name: product.displayName, price: product.displayPrice, description: product.description) {
                            Task {
                                try? await purchaseManager.purchase(product)
                            }
                        }
                        .padding()
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
