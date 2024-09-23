//
//  FriendCardCell.swift
//  CalControlPlus
//
//  Created by 楊芮瑊 on 2024/9/23.
//

import UIKit
import Combine

class FriendCardCell: BaseCardTableViewCell {
    
    static let identifier = "FriendCardCell"
    
    var viewModel = FriendCardViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    private var circularLayer = CAShapeLayer()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend name"
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var heartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.tintColor = .mainRed
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var chartContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var carbsLabel: UILabel = createLabel(withText: "醣類")
    lazy var fatsLabel: UILabel = createLabel(withText: "脂質")
    lazy var proteinLabel: UILabel = createLabel(withText: "蛋白質")
    
    lazy var carbsProgressView = createProgressView(progress: 0.7, color: .orange)
    lazy var fatsProgressView = createProgressView(progress: 0.5, color: .yellow)
    lazy var proteinProgressView = createProgressView(progress: 0.6, color: .blue)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupCircularChart()
        addBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with friend: Friend){
        viewModel.fetchFriendData(friendID: friend.userID)
    }
    
    private func addBindings() {
        
        viewModel.$friendName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.nameLabel.text = name
            }
            .store(in: &subscriptions)
        
        viewModel.$avatarUrl
            .receive(on: DispatchQueue.main)
            .sink { [weak self] avatarUrl in
                if let avatarUrl = avatarUrl {
                    self?.avatarImageView.loadImage(with: avatarUrl)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.$calProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.circularLayer.strokeEnd = CGFloat(progress)
            }
            .store(in: &subscriptions)
        
        viewModel.$carbsProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.carbsProgressView.progress = Float(progress)
            }
            .store(in: &subscriptions)
        
        viewModel.$fatsProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.fatsProgressView.progress = Float(progress)
            }
            .store(in: &subscriptions)
        
        viewModel.$proteinProgress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.proteinProgressView.progress = Float(progress)
            }
            .store(in: &subscriptions)
    }
    
    private func setupView() {
        let labelStackView: UIStackView = createStackView(
            for: [carbsLabel, fatsLabel, proteinLabel],
            spacing: 10,
            axis: .vertical
        )
        let progressBarStackView: UIStackView = createStackView(
            for: [carbsProgressView, fatsProgressView, proteinProgressView],
            spacing: 15,
            axis: .vertical
        )
        progressBarStackView.isLayoutMarginsRelativeArrangement = true
        progressBarStackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        let nutrientsStackView: UIStackView = createStackView(
            for: [labelStackView, progressBarStackView],
            spacing: 10,
            axis: .horizontal
        )
        nutrientsStackView.distribution = .fill
        
        let combineStackView: UIStackView = createStackView(
            for: [nutrientsStackView, chartContainer],
            spacing: 30,
            axis: .horizontal)
        combineStackView.distribution = .fillProportionally
        
        innerContentView.addSubview(avatarImageView)
        innerContentView.addSubview(nameLabel)
        innerContentView.addSubview(heartButton)
        innerContentView.addSubview(combineStackView)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 10),
            avatarImageView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),

            heartButton.widthAnchor.constraint(equalToConstant: 30),
            heartButton.heightAnchor.constraint(equalToConstant: 25),
            heartButton.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -20),
            heartButton.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 20),
            
            combineStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            combineStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 20),
            combineStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -10),
            combineStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            
            chartContainer.widthAnchor.constraint(equalToConstant: 100),
            chartContainer.heightAnchor.constraint(equalToConstant: 100)
        ])

    }
    
    private func setupCircularChart() {
        let backgroundCircle = CAShapeLayer()

        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: 50, y: 50),
            radius: 40, startAngle: -CGFloat.pi / 2,
            endAngle: 1.5 * CGFloat.pi,
            clockwise: true
        )

        backgroundCircle.path = circularPath.cgPath
        backgroundCircle.fillColor = UIColor.clear.cgColor
        backgroundCircle.strokeColor = UIColor.lightGray.cgColor
        backgroundCircle.lineWidth = 10
        chartContainer.layer.addSublayer(backgroundCircle)

        circularLayer.path = circularPath.cgPath
        circularLayer.fillColor = UIColor.clear.cgColor
        circularLayer.strokeColor = UIColor.orange.cgColor
        circularLayer.lineWidth = 10
        circularLayer.strokeEnd = 0.0
        circularLayer.lineCap = .round
        chartContainer.layer.addSublayer(circularLayer)
    }
    
    private func createStackView(for items: [UIView], spacing: CGFloat, axis: NSLayoutConstraint.Axis) -> UIStackView {
        let sv = UIStackView(arrangedSubviews: items)
        sv.axis = axis
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = spacing
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }
 
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createProgressView(progress: Double, color: UIColor) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = Float(progress)
        progressView.trackTintColor = .lightGray
        progressView.progressTintColor = color
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.layer.cornerRadius = 5
        progressView.clipsToBounds = true
        return progressView
    }
}
