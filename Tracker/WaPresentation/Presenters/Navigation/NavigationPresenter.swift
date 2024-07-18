//
//  NavigationPresenter.swift
//  WaPresentation
//
//  Created by Alexander Chernousov on 30.08.2022.
//

import UIKit

public protocol NavigationPresenter: Presenter {
    func push(in navigationController: UINavigationController, animated: Bool)
    func replaceCurrent(in navigationController: UINavigationController, animated: Bool)
    func replaceAll(in navigationController: UINavigationController, animated: Bool)
}
