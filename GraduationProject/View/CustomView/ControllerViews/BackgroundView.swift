//
//  BackgroundView.swift
//  GraduationProject
//
//  Created by Александр Муклинов on 12.04.2023.
//

import UIKit

final class BackgroundView: UIView {

    var delegate:ClosingViewsProtocol? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // - добавляем цвет для представления
        self.backgroundColor = UIColor.black.withAlphaComponent(0)
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        
        // - добавляем распознователь жеста
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - метод для жеста на закрытие представления

    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        delegate?.closeViewForInput()
    }
}
