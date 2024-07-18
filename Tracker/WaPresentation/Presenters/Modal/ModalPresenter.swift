//
//  ModalPresenter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public protocol ModalPresenter: Presenter {
    func present(at: UIViewController, animated: Bool, completion: (() -> Void)?)
}

public extension ModalPresenter {
    func present(at: UIViewController, animated: Bool) {
        present(at: at, animated: animated, completion: nil)
    }
}
