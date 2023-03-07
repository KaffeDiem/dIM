//
//  CollectionView.swift
//  dIM
//
//  Created by Kasper Munch on 05/03/2023.
//

import UIKit
import SwiftUI

public extension UICollectionViewCell {
    static var stringIdentifier: String { String(describing: Self.self) }
}

public protocol Configurable {
    associatedtype DataType
    func configure(using data: DataType) -> Void
}

public class GenericCollectionView<CellType: UICollectionViewCell & Configurable>: UICollectionView {
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        sharedInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    private func sharedInit() {
        backgroundColor = .clear
        register(CellType.self, forCellWithReuseIdentifier: CellType.stringIdentifier)
    }
}

/// The CollectionView is a binding to the UICollectionView from UIKit. It offers more control than
/// what is currently possible in SwiftUI and is very generic. Pass in some data and an onTap function
/// and let this generic collectionView handle the rest.
public struct CollectionView<CellType: UICollectionViewCell & Configurable>: UIViewRepresentable {
    @Binding public var items: [CellType.DataType]
    private let layout: UICollectionViewFlowLayout
    private let onTap: ((_ item: CellType.DataType) -> Void)?
    
    public init(items: Binding<[CellType.DataType]>, onTap: ((_ item: CellType.DataType) -> Void)?) {
        self._items = items
        self.onTap = onTap
        self.layout = UICollectionViewFlowLayout()
    }
    
    public func updateUIView(_ view: GenericCollectionView<CellType>, context: Context) {
        view.reloadData()
    }
    
    public func makeUIView(context: Context) -> GenericCollectionView<CellType> {
        let view = GenericCollectionView<CellType>.init(frame: .zero, collectionViewLayout: layout)
        view.dataSource = context.coordinator
        view.delegate = context.coordinator
        return view
    }
    
    public func makeCoordinator() -> CollectionViewCoordinator<CellType> {
        CollectionViewCoordinator($items, onTap: onTap)
    }
}
