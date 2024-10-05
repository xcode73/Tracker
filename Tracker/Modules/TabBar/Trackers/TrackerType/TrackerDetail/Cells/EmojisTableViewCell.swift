//
//  EmojisTableViewCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 27.09.2024.
//

import UIKit

final class EmojisTableViewCell: UITableViewCell {
    // MARK: - UI Components
    private let emojisView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var emojisCollectionView: UIView = {
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
        contentView.addSubview(emojisView)
        emojisView.addSubview(emojisCollectionView)
        
        NSLayoutConstraint.activate([
            emojisView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojisView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojisCollectionView.leadingAnchor.constraint(equalTo: emojisView.leadingAnchor, constant: 10),
            emojisCollectionView.trailingAnchor.constraint(equalTo: emojisView.trailingAnchor, constant: -10),
//            emojisCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
}
