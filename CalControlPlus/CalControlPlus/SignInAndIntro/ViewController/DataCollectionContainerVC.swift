//
//  DataCollectionContainerVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/10/2.
//

import UIKit

class DataCollectionContainerVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private var pageViewController: UIPageViewController!
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    private let pages: [UIViewController] = [
        InfoNameVC(), InfoGenderVC(), InfoBirthdayVC(), InfoHeightVC(),
        InfoWeightVC(), InfoActivityVC(), InfoTargetVC(), InfoStartVC()
    ]
    
    private var currentPageIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        setupPageViewController()
        setupProgressView()
        setupBackButton()
        navigationItem.leftBarButtonItem?.isHidden = (currentPageIndex == 0)
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = nil
        pageViewController.delegate = self
        
        if let firstPage = pages.first as? InfoNameVC {
            firstPage.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -100)
        ])
    }
    
    private func setupProgressView() {
        progressView.progress = 0
    
        view.addSubview(progressView)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    private func setupBackButton() {
        let backButton = UIButton(type: .system)
        backButton.setTitle("Back", for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .mainGreen
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc private func backButtonTapped() {
        guard currentPageIndex > 0 else { return }
        currentPageIndex -= 1

        let previousVC = pages[currentPageIndex]
        pageViewController.setViewControllers([previousVC], direction: .reverse, animated: true, completion: nil)
        navigationItem.leftBarButtonItem?.isHidden = (currentPageIndex == 0)
        updateProgress()
    }
    
    private func updateProgress() {
        let progress = Float(currentPageIndex + 1) / Float(pages.count)
        progressView.setProgress(progress, animated: true)
    }
    
    private func moveToNextPage() {
        guard currentPageIndex < (pages.count - 1) else { return }
        
        currentPageIndex += 1
        
        let nextVC = pages[currentPageIndex]
        
        switch nextVC {
        case let vc as InfoNameVC:
            vc.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
        case let vc as InfoGenderVC:
            vc.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
        case let vc as InfoBirthdayVC:
            vc.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
        case let vc as InfoHeightVC:
            vc.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
        case let vc as InfoWeightVC:
            vc.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
        case let vc as InfoActivityVC:
            vc.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
        case let vc as InfoTargetVC:
            vc.nextPage = { [weak self] in
                self?.moveToNextPage()
            }
        default:
            break
        }
        
        navigationItem.leftBarButtonItem?.isHidden = (currentPageIndex == 0)
        pageViewController.setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        updateProgress()
    }
    
    // MARK: - UIPageViewControllerDataSource
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController),
              currentIndex < (pages.count - 1) else { return nil }
        return pages[currentIndex + 1]
    }
    
    // MARK: - UIPageViewControllerDelegate
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let visibleViewController = pageViewController.viewControllers?.first {
            currentPageIndex = pages.firstIndex(of: visibleViewController) ?? 0
            updateProgress()
        }
    }
}
