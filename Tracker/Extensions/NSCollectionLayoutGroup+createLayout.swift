//
//  NSCollectionLayoutGroup+createLayout.swift
//  Tracker
//
//  Created by Александр Зиновьев on 14.07.2024.
//

import UIKit

extension NSCollectionLayoutGroup {
    static func create(
        horizontalGroupWithWidth width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        items: [NSCollectionLayoutItem]
    ) -> NSCollectionLayoutGroup {
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: height
            ),
            subitems: items
        )

        return group
    }

    static func create(
        verticalGroupWithWidth width: NSCollectionLayoutDimension,
        height: NSCollectionLayoutDimension,
        items: [NSCollectionLayoutItem]
    ) -> NSCollectionLayoutGroup {
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: width,
                heightDimension: height
            ),
            subitems: items
        )

        return group
    }
}
