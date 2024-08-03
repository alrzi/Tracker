//
//  WindowPresenter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public protocol WindowPresenter: Presenter {
    func present(at window: UIWindow)
}
