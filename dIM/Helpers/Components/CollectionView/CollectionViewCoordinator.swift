//
//  CollectionViewCoordinator.swift
//  dIM
//
//  Created by Kasper Munch on 05/03/2023.
//

import UIKit
import SwiftUI

public class CollectionViewCoordinator<CellType: UICollectionViewCell & Configurable>: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public typealias OnTap = (_ item: CellType.DataType) -> Void
    @Binding private var items: [CellType.DataType]
    private let onTap: OnTap?
    
    public init(_ items: Binding<[CellType.DataType]>, onTap: OnTap?) {
        self._items = items
        self.onTap = onTap
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.stringIdentifier, for: indexPath) as? CellType ?? CellType()
        cell.configure(using: items[indexPath.row])
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = (collectionView.frame.width - 32) / 3
        return .init(width: dimension, height: dimension)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let onTap {
            onTap(items[indexPath.row])
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 8, left: 8, bottom: 8, right: 8)
    }
}
