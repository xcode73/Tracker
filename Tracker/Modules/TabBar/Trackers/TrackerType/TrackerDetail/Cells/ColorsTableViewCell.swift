//
//  ColorsTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

final class ColorsTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var colorsCollectionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(colorsCollectionView)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            colorsCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            colorsCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
//            colorsCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
