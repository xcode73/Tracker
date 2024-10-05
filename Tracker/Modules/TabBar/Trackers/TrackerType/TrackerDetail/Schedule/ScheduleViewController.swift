//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 29.09.2024.
//

import UIKit

class ScheduleViewController: UIViewController {

    // MARK: - Properties
    let weekDays = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    // MARK: - UI Components
    private lazy var scheduleTableView: UITableView = {
        let view = UITableView()
        view.dataSource = self
        view.delegate = self
        view.separatorStyle = .none
        view.backgroundColor = .ypBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var createScheduleButton: UIButton = {
        let view = UIButton()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBlack
        view.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        view.setTitleColor(.white, for: .normal)
        view.setTitle("Готово", for: .normal)
        view.addTarget(ScheduleViewController.self, action: #selector(addSchedule), for: .touchUpInside)
        view.accessibilityIdentifier = "Add Schedule Button"
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        title = "Расписание"
        view.backgroundColor = .ypWhite
        addScheduleButton()
        addScheduleTableView()
    }
    
    
    // MARK: - Constraints
    private func addScheduleTableView() {
        view.addSubview(scheduleTableView)
        
        NSLayoutConstraint.activate([
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.topAnchor.constraint(equalTo: view.topAnchor),
            scheduleTableView.bottomAnchor.constraint(equalTo: createScheduleButton.topAnchor)
        ])
    }
    
    private func addScheduleButton() {
        view.addSubview(createScheduleButton)
        
        NSLayoutConstraint.activate([
            createScheduleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createScheduleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createScheduleButton.heightAnchor.constraint(equalToConstant: 60),
            createScheduleButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32)
        ])
    }
    
    // MARK: - Actions
    @objc
    private func addSchedule() {
        dismiss(animated: true)
//        let viewController = WebViewController()
//        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ScheduleCell()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview("Schedule") {
    let navigationController = UINavigationController(rootViewController: ScheduleViewController())
    navigationController.modalPresentationStyle = .pageSheet
    
    return navigationController
}
#endif
