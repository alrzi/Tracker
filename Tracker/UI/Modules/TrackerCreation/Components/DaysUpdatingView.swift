//
//  DaysUpdatingView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 23.05.2023.
//

import UIKit

final class DaysUpdaitingView: UIView {
    private let incrementClosure: () -> Void
    private let decrementClosure: () -> Void
    
    func configure(with viewModel: UpdateTrackedDaysViewModel) {
        daysCountLabel.text = viewModel.trackedDays
        updateButtonsStyle(isTrackedForToday: !viewModel.isTrackedForToday)
    }
    
    private let horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 24
        return view
    }()
    
    private let incrementButton: UIButton = {
        let view = UIButton()
        view.setImage(Asset.Assets._17increment.image, for: .normal)
        return view
    }()
    
    private let decrementButton: UIButton = {
        let view = UIButton()
        view.setImage(Asset.Assets._16decrement.image, for: .normal)
        return view
    }()
    
    private let daysCountLabel: UILabel = {
        let view = UILabel()
        view.font = .bold32     
        return view
    }()
    
    init(
        incrementClosure: @escaping () -> Void,
        decrementClosure: @escaping () -> Void
    ) {
        self.incrementClosure = incrementClosure
        self.decrementClosure = decrementClosure
        
        super.init(frame: .zero)
        
        setupUI()
        setTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }
    
    @objc private func decrementButtonTapped() {
        decrementClosure()
    }
    
    @objc private func incrementButtonTapped() {
        incrementClosure()
    }
}

private extension DaysUpdaitingView {
    func setupUI() {
        let leadingSpacer = UIView()
        leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                
        let trailingSpacer = UIView()
        trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
                        
        horizontalStackView.addSubviews(leadingSpacer, decrementButton, daysCountLabel, incrementButton, trailingSpacer)
        addSubviews(horizontalStackView)
                        
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            horizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            horizontalStackView.topAnchor.constraint(equalTo: topAnchor),
            daysCountLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            leadingSpacer.widthAnchor.constraint(greaterThanOrEqualToConstant: .zero),
            trailingSpacer.widthAnchor.constraint(greaterThanOrEqualToConstant: .zero)
        ])
    }
    
    func setTargets() {
        incrementButton.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementButtonTapped), for: .touchUpInside)
    }
    
    func updateButtonsStyle(isTrackedForToday: Bool) {
        if isTrackedForToday {
            decrementButton.alpha = 0.5
            decrementButton.isEnabled = false
            
            incrementButton.alpha = 1
            incrementButton.isEnabled = true
        } 
        else {
            decrementButton.alpha = 1
            decrementButton.isEnabled = true
            
            incrementButton.alpha = 0.5
            incrementButton.isEnabled = false
        }
    }
}
