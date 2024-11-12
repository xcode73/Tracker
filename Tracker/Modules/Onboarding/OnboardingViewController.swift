//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Nikolai Eremenko on 30.09.2024.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    // MARK: - Properties
    private var pages: [OnboardingPage] = [
        OnboardingPage(image: .imgOnboardingBlue, title: "Отслеживайте только \nто, что хотите"),
        OnboardingPage(image: .imgOnboardingRed, title: "Даже если это \nне литры воды и йога")
    ]
    private let initialPage: Int = 0
    
    // MARK: - UI Components
    private lazy var onboardingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.register(OnboardingCell.self, forCellWithReuseIdentifier: OnboardingCell.reuseIdentifier)

        return view
    }()
    
    private lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.numberOfPages = pages.count
        view.currentPage = initialPage
        view.currentPageIndicatorTintColor = .ypBlack
        view.pageIndicatorTintColor = .ypGray
        
        return view
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        setupUI()
    }
    
    private func setupUI() {
        addOnboardingCollectionView()
        addPageControl()
    }
    
    // MARK: - Constraints
    private func addOnboardingCollectionView() {
        onboardingCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboardingCollectionView)
        
        NSLayoutConstraint.activate([
            onboardingCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            onboardingCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            onboardingCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func addPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -123)
        ])
    }

//    // MARK: - Action
//    @objc
//    internal func didTapConfirmButton() {
//        UserDefaults.standard.isOnboardingCompleted = true
//        dismiss(animated: true)
//    }
}

// MARK: - UICollectionViewDataSource
extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCell.reuseIdentifier, for: indexPath) as? OnboardingCell else {
            return UICollectionViewCell()
        }
        cell.delegate = self
        cell.prepareForReuse()
        cell.configure(with: pages[indexPath.row])
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.currentPage = indexPath.row
    }
}

// MARK: - OnboardingCellDelegate
extension OnboardingViewController: OnboardingCellDelegate {
    func didTapConfirmButton() {
        UserDefaults.standard.isOnboardingCompleted = true
        dismiss(animated: true)
    }
}

// MARK: - Preview
#if DEBUG
@available(iOS 17, *)
#Preview() {
    OnboardingViewController()
}
#endif
