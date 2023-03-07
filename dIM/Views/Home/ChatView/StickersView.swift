//
//  StickersView.swift
//  dIM
//
//  Created by Kasper Munch on 05/03/2023.
//

import SwiftUI

struct StickersView: View {
    @State private var data: [String] = ["hello-world", "fiery", "sick", "good-night"]
    
    var body: some View {
        CollectionView<AnimationViewCell>(items: $data, onTap: { text in print(text) })
    }
}

struct StickersView_Previews: PreviewProvider {
    static var previews: some View {
        StickersView()
    }
}
