//
//  AddFriendVC.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/26.
//

import UIKit

class AddFriendVC: UIViewController {
    
    var viewModel: FriendViewModel?
    
    private var pageViewController: UIPageViewController!
    private var currentIndex: Int = 0
    private var nextIndex: Int = 0
    private var isTabButtonPressed: Bool = false
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [inputButton, showQRCodeButton, scanQRCodeButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreen
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var inputButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("輸入好友ID", for: .normal)
        button.tag = 0
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var showQRCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("顯示QRcode", for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var scanQRCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("掃描好友QRcode", for: .normal)
        button.tag = 2
        button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private var underlineLeadingConstraint: NSLayoutConstraint?
    private var underlineWidthConstraint: NSLayoutConstraint?
    
    private var pages: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabButtons()
        setupPageViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func setupTabButtons() {
        view.addSubview(buttonStackView)
        view.addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            
            underlineView.heightAnchor.constraint(equalToConstant: 2),
            underlineView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor)
        ])
        
        underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: buttonStackView.leadingAnchor)
        underlineWidthConstraint = underlineView.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 1/3)
        
        underlineLeadingConstraint?.isActive = true
        underlineWidthConstraint?.isActive = true
    }
    
    private func setupPageViewController() {
        
        let inputVC = InputFriendIDVC()
        inputVC.viewModel = self.viewModel
        let showQRCodeVC = ShowQRCodeVC()
        let scanQRCodeVC = ScanQRCodeVC()
        scanQRCodeVC.viewModel = self.viewModel
        
        pages = [inputVC, showQRCodeVC, scanQRCodeVC]
        
        pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: underlineView.bottomAnchor, constant: 10),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        pageViewController.didMove(toParent: self)
        
        if let firstVC = pages.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
        if let scrollView = pageViewController.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            scrollView.delegate = self
        }
    }
    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        let index = sender.tag
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        
        isTabButtonPressed = true
        
        UIView.animate(withDuration: 0.3) {
            self.updateUnderlinePosition(for: index)
        }
        
        pageViewController.setViewControllers(
            [pages[index]], direction: direction, animated: true
        ) { [weak self] completed in
            if completed {
                self?.currentIndex = index
                self?.isTabButtonPressed = false
            }
        }
    }
    
    private func updateUnderlinePosition(for index: Int) {
        let newLeadingConstant = CGFloat(index) * (view.frame.width / 3)
        underlineLeadingConstraint?.constant = newLeadingConstant
        view.layoutIfNeeded()
    }
}

extension AddFriendVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        nextIndex = index - 1
        return pages[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < (pages.count - 1) else { return nil }
        nextIndex = index + 1
        return pages[nextIndex]
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isTabButtonPressed else { return }
        let offset = scrollView.contentOffset.x - view.frame.width
        let offsetPercentage = offset / view.frame.width
        
        let newLeadingConstant = (CGFloat(currentIndex) + offsetPercentage) * (view.frame.width / 3)
        underlineLeadingConstraint?.constant = newLeadingConstant
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let visibleVC = pageViewController.viewControllers?.first, let index = pages.firstIndex(of: visibleVC) {
            currentIndex = index
            isTabButtonPressed = false
        }
    }
}
