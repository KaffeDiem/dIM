//
//  UnlockView.swift
//  dIM
//
//  Created by Kasper Munch on 06/03/2023.
//

import SwiftUI
import Shiny


struct UnlockView: View {
    @State private var id = UUID()
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading) {
                    FeatureCell(image: Image("appiconsvg"), title: "Support & Unlock", subtitle: "Support the development of dIM by unlocking additional features.")
                        .padding()
                    
                    if PurchaseManager.shared.isProductsLoaded {
                        if PurchaseManager.shared.availableProductsNotPurchased.isEmpty {
                            Text("All available products has been purchased. Thank you for your support.")
                                .padding()
                        } else {
                            ForEach(PurchaseManager.shared.availableProductsNotPurchased) { product in
                                PurchaseCell(name: product.displayName, price: product.displayPrice, description: product.description) {
                                    Task {
                                        try? await PurchaseManager.shared.purchase(product) { result in
                                            id = UUID()
                                            switch result {
                                            case .success(let product): ()
                                            case .failure(let error): ()
                                            }
                                        }
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
                            try? await PurchaseManager.shared.restore()
                        }
                    } label: {
                        Text("Restore purchases")
                    }
                    .padding()
                }
            }.id(id)
        }
        .task {
            do {
                try await PurchaseManager.shared.loadProducts()
            } catch {
                print(error.localizedDescription)
            }
        }
        .onChange(of: PurchaseManager.shared.availableProductsNotPurchased, perform: { newValue in
            self.id = UUID() // Hack to force reload the view if a product has been purchased.
        })
        .navigationTitle("Unlock features")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UnlockView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnlockView()
            
            PurchaseCell(name: "Animated stickers", price: "1.99 US$", description: "Unlock animated stickers in dIM chat", onTap: {})
        }
    }
}
