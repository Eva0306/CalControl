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
    
    private var friend: Friend?
    
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
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var heartButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .mainRed
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(heartButtonTapped), for: .touchUpInside)
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
    
    lazy var carbsProgressView = createProgressView(progress: 0.7, color: .mainOrg)
    lazy var fatsProgressView = createProgressView(progress: 0.5, color: .mainYellow)
    lazy var proteinProgressView = createProgressView(progress: 0.6, color: .mainBlue)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupCircularChart()
        addBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        friend = nil
        nameLabel.text = ""
        avatarImageView.image = UIImage(systemName: "person.crop.circle")
        heartButton.setImage(UIImage(systemName: "heart"), for: .normal)
        circularLayer.strokeEnd = 0.0
        carbsProgressView.progress = 0.0
        fatsProgressView.progress = 0.0
        proteinProgressView.progress = 0.0
    }
    
    func configure(with friend: Friend, viewModel: FriendViewModel) {
        self.friend = friend
        self.viewModel.fetchFriendData(friendID: friend.userID)
        
        let imageName = friend.isFavorite ? "heart.fill" : "heart"
        heartButton.setImage(UIImage(systemName: imageName), for: .normal)
        
        self.viewModel.didToggleFavorite = { [weak viewModel] in
            guard let viewModel = viewModel else { return }
            viewModel.toggleFavorite(for: friend)
        }
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
    
    @objc private func heartButtonTapped() {
        guard let friend = friend else { return }
        viewModel.toggleFavoriteStatus()
        let newHeartImage = friend.isFavorite ? "heart" : "heart.fill"
        heartButton.setImage(UIImage(systemName: newHeartImage), for: .normal)
    }
    
}

// MARK: - Setup View
extension FriendCardCell {
    private func setupView() {
        setupAvatarImageView()
        setupNameLabel()
        setupHeartButton()
        setupCombineStackView()
        setupChartContainer()
    }
    
    private func setupAvatarImageView() {
        innerContentView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 10),
            avatarImageView.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 10),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupNameLabel() {
        innerContentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 10),
            nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    private func setupHeartButton() {
        innerContentView.addSubview(heartButton)
        NSLayoutConstraint.activate([
            heartButton.widthAnchor.constraint(equalToConstant: 30),
            heartButton.heightAnchor.constraint(equalToConstant: 25),
            heartButton.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -20),
            heartButton.topAnchor.constraint(equalTo: innerContentView.topAnchor, constant: 20)
        ])
    }
    
    private func setupCombineStackView() {
        let labelStackView = createStackView(for: [carbsLabel, fatsLabel, proteinLabel], spacing: 10, axis: .vertical)
        let progressBarStackView = createStackView(
            for: [carbsProgressView, fatsProgressView, proteinProgressView],
            spacing: 15,
            axis: .vertical
        )
        progressBarStackView.isLayoutMarginsRelativeArrangement = true
        progressBarStackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        let nutrientsStackView = createStackView(
            for: [labelStackView, progressBarStackView],
            spacing: 10,
            axis: .horizontal
        )
        nutrientsStackView.distribution = .fill
        
        let combineStackView = createStackView(
            for: [nutrientsStackView, chartContainer],
            spacing: 30,
            axis: .horizontal
        )
        combineStackView.distribution = .fillProportionally
        
        innerContentView.addSubview(combineStackView)
        NSLayoutConstraint.activate([
            combineStackView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 20),
            combineStackView.leadingAnchor.constraint(equalTo: innerContentView.leadingAnchor, constant: 20),
            combineStackView.trailingAnchor.constraint(equalTo: innerContentView.trailingAnchor, constant: -10),
            combineStackView.bottomAnchor.constraint(equalTo: innerContentView.bottomAnchor, constant: -10),
            
            chartContainer.widthAnchor.constraint(equalToConstant: 100),
            chartContainer.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupChartContainer() {
        let remainingLabel = UILabel()
        remainingLabel.text = "剩餘"
        remainingLabel.textColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .darkGray
            }
        }
        remainingLabel.font = .systemFont(ofSize: 12)
        remainingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        chartContainer.addSubview(remainingLabel)
        NSLayoutConstraint.activate([
            remainingLabel.centerXAnchor.constraint(equalTo: chartContainer.centerXAnchor),
            remainingLabel.centerYAnchor.constraint(equalTo: chartContainer.centerYAnchor)
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
        backgroundCircle.strokeColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .darkGray
            default:
                return .systemGray5
            }
        }.cgColor
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
        label.textColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .white
            default:
                return .darkGray
            }
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func createProgressView(progress: Double, color: UIColor) -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progress = Float(progress)
        progressView.trackTintColor = UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return .darkGray
            default:
                return .systemGray5
            }
        }
        progressView.progressTintColor = color
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.layer.cornerRadius = 10
        progressView.clipsToBounds = true
        return progressView
    }
}
