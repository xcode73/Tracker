//
//  ScheduleCell.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 29.09.2024.
//

import UIKit

class ScheduleCell: UITableViewCell {
    // MARK: - UI Components
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillProportionally
        view.alignment = .center
        view.spacing = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 17, weight: .regular)
        view.textColor = .ypBlack
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var scheduleSwitch: UISwitch = {
        let view = UISwitch()
        view.addTarget(self, action: #selector(didTapSwitch(_:)), for: .touchUpInside)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
//        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, isOn: Bool) {
        titleLabel.text = title
        scheduleSwitch.isOn = isOn
    }
    
    //MARK: - Actions
    @objc
    private func didTapSwitch(_ sender: UISwitch) {
        sender.isOn.toggle()
    }
}
