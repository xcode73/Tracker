//
//  ErrorCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 04.10.2024.
//

import UIKit

class ErrorCell: UITableViewCell {
    
    private lazy var errorLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.textAlignment = .center
        view.text = "Ограничение 38 символов"
        view.textColor = .ypRed
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
