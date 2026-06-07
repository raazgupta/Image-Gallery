import UIKit

protocol GachaAnimationView: AnyObject {
    func setRewardImage(_ image: UIImage?)
    func startAnimation(finalStars: Int, completion: @escaping () -> Void)
}

class SlotMachineView: UIView, GachaAnimationView {
    private struct Palette {
        let primary: UIColor
        let secondary: UIColor
        let glow: UIColor
    }

    private struct Timing {
        static let introStart: TimeInterval = 0.0
        static let chargeUpStart: TimeInterval = 0.9
        static let fakeOutStart: TimeInterval = 3.6
        static let paletteRevealStart: TimeInterval = 5.0
        static let rarityRevealStart: TimeInterval = 5.45
        static let rewardRevealStart: TimeInterval = 6.2
        static let finishStart: TimeInterval = 6.75
    }

    private let backdropGradientLayer = CAGradientLayer()
    private let ringLayer = CAShapeLayer()
    private let innerRingLayer = CAShapeLayer()

    private let auraView = UIView()
    private let flashView = UIView()
    private let cardContainerView = UIView()
    private let mysteryCardView = UIView()
    private let cardImageView = UIImageView()
    private let placeholderLabel = UILabel()
    private let starStackView = UIStackView()

    private let borderGradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    private var starViews: [UIImageView] = []
    private var sparkViews: [UIView] = []
    private var finalStars = 1
    private var rewardImage: UIImage?
    private var rewardImageVisible = false
    private var completion: (() -> Void)?

    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backdropGradientLayer.frame = bounds
        flashView.frame = bounds
        auraView.layer.cornerRadius = auraView.bounds.width / 2

        let ringRect = auraView.frame.insetBy(dx: -18, dy: -18)
        ringLayer.frame = bounds
        ringLayer.path = UIBezierPath(ovalIn: ringRect).cgPath

        let innerRingRect = auraView.frame.insetBy(dx: 14, dy: 14)
        innerRingLayer.frame = bounds
        innerRingLayer.path = UIBezierPath(ovalIn: innerRingRect).cgPath

        borderGradientLayer.frame = mysteryCardView.bounds
        borderMaskLayer.frame = mysteryCardView.bounds
        borderMaskLayer.path = UIBezierPath(
            roundedRect: mysteryCardView.bounds.insetBy(dx: 2, dy: 2),
            cornerRadius: 26
        ).cgPath

        mysteryCardView.layer.shadowPath = UIBezierPath(
            roundedRect: mysteryCardView.bounds,
            cornerRadius: 28
        ).cgPath
    }

    func setRewardImage(_ image: UIImage?) {
        rewardImage = image
        guard rewardImageVisible, let image else { return }
        cardImageView.image = image
        placeholderLabel.alpha = 0.0
    }

    func startAnimation(finalStars: Int, completion: @escaping () -> Void) {
        self.finalStars = max(1, min(3, finalStars))
        self.completion = completion

        applyPalette(neutralPalette(), animated: false)
        resetState()
        prepareHaptics()
        runSequence()
    }

    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        setupBackdrop()
        setupAura()
        setupCard()
        setupStars()
        setupSparks()
    }

    private func setupBackdrop() {
        backdropGradientLayer.colors = [
            UIColor(red: 0.03, green: 0.04, blue: 0.08, alpha: 0.98).cgColor,
            UIColor(red: 0.05, green: 0.08, blue: 0.16, alpha: 0.96).cgColor,
            UIColor(red: 0.01, green: 0.02, blue: 0.05, alpha: 0.98).cgColor
        ]
        backdropGradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        backdropGradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        layer.addSublayer(backdropGradientLayer)

        flashView.backgroundColor = .white
        flashView.alpha = 0.0
        addSubview(flashView)
    }

    private func setupAura() {
        auraView.translatesAutoresizingMaskIntoConstraints = false
        auraView.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        auraView.alpha = 0.0
        addSubview(auraView)

        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 3
        ringLayer.opacity = 0.0
        layer.addSublayer(ringLayer)

        innerRingLayer.fillColor = UIColor.clear.cgColor
        innerRingLayer.lineWidth = 1.5
        innerRingLayer.opacity = 0.0
        layer.addSublayer(innerRingLayer)

        NSLayoutConstraint.activate([
            auraView.centerXAnchor.constraint(equalTo: centerXAnchor),
            auraView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            auraView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.74),
            auraView.heightAnchor.constraint(equalTo: auraView.widthAnchor)
        ])
    }

    private func setupCard() {
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.backgroundColor = .clear
        addSubview(cardContainerView)

        mysteryCardView.translatesAutoresizingMaskIntoConstraints = false
        mysteryCardView.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.20, alpha: 1.0)
        mysteryCardView.layer.cornerRadius = 28
        mysteryCardView.layer.shadowColor = UIColor.black.cgColor
        mysteryCardView.layer.shadowOpacity = 0.35
        mysteryCardView.layer.shadowRadius = 28
        mysteryCardView.layer.shadowOffset = CGSize(width: 0, height: 14)
        mysteryCardView.clipsToBounds = true
        cardContainerView.addSubview(mysteryCardView)

        borderGradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        borderGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        borderGradientLayer.mask = borderMaskLayer
        mysteryCardView.layer.addSublayer(borderGradientLayer)

        let topShineLayer = CAGradientLayer()
        topShineLayer.colors = [
            UIColor.white.withAlphaComponent(0.32).cgColor,
            UIColor.clear.cgColor
        ]
        topShineLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        topShineLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        topShineLayer.frame = CGRect(x: 0, y: 0, width: 320, height: 180)
        mysteryCardView.layer.addSublayer(topShineLayer)

        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.clipsToBounds = true
        cardImageView.alpha = 0.0
        mysteryCardView.addSubview(cardImageView)

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "MYSTERY"
        placeholderLabel.textColor = UIColor.white.withAlphaComponent(0.94)
        placeholderLabel.font = UIFont.systemFont(ofSize: 28, weight: .black)
        placeholderLabel.textAlignment = .center
        placeholderLabel.layer.shadowColor = UIColor.black.cgColor
        placeholderLabel.layer.shadowOpacity = 0.3
        placeholderLabel.layer.shadowRadius = 10
        placeholderLabel.layer.shadowOffset = CGSize(width: 0, height: 4)
        mysteryCardView.addSubview(placeholderLabel)

        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        subLabel.text = "Tap fate. Hold breath."
        subLabel.textColor = UIColor.white.withAlphaComponent(0.68)
        subLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        mysteryCardView.addSubview(subLabel)

        NSLayoutConstraint.activate([
            cardContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cardContainerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            cardContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.66),
            cardContainerView.heightAnchor.constraint(equalTo: cardContainerView.widthAnchor, multiplier: 1.42),
            cardContainerView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.68),
            cardContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 520),

            mysteryCardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
            mysteryCardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
            mysteryCardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
            mysteryCardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor),

            cardImageView.leadingAnchor.constraint(equalTo: mysteryCardView.leadingAnchor, constant: 8),
            cardImageView.trailingAnchor.constraint(equalTo: mysteryCardView.trailingAnchor, constant: -8),
            cardImageView.topAnchor.constraint(equalTo: mysteryCardView.topAnchor, constant: 8),
            cardImageView.bottomAnchor.constraint(equalTo: mysteryCardView.bottomAnchor, constant: -8),

            placeholderLabel.centerXAnchor.constraint(equalTo: mysteryCardView.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: mysteryCardView.centerYAnchor, constant: -14),

            subLabel.centerXAnchor.constraint(equalTo: mysteryCardView.centerXAnchor),
            subLabel.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 10)
        ])
    }

    private func setupStars() {
        starStackView.translatesAutoresizingMaskIntoConstraints = false
        starStackView.axis = .horizontal
        starStackView.alignment = .center
        starStackView.distribution = .equalSpacing
        starStackView.spacing = 14
        starStackView.alpha = 0.0
        addSubview(starStackView)

        for _ in 0..<3 {
            let starView = UIImageView(image: UIImage(systemName: "star.fill"))
            starView.translatesAutoresizingMaskIntoConstraints = false
            starView.contentMode = .scaleAspectFit
            starView.alpha = 0.0
            starView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            starView.layer.shadowColor = UIColor.white.cgColor
            starView.layer.shadowOpacity = 0.0
            starView.layer.shadowRadius = 14
            starView.layer.shadowOffset = .zero
            NSLayoutConstraint.activate([
                starView.widthAnchor.constraint(equalToConstant: 34),
                starView.heightAnchor.constraint(equalToConstant: 34)
            ])
            starStackView.addArrangedSubview(starView)
            starViews.append(starView)
        }

        NSLayoutConstraint.activate([
            starStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            starStackView.bottomAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: -28)
        ])
    }

    private func setupSparks() {
        for index in 0..<18 {
            let spark = UIView()
            spark.translatesAutoresizingMaskIntoConstraints = false
            spark.backgroundColor = .white
            spark.alpha = 0.0
            spark.layer.cornerRadius = 3
            addSubview(spark)
            sparkViews.append(spark)

            let angle = CGFloat(index) / 18.0 * .pi * 2
            let xOffset = cos(angle) * 120
            let yOffset = sin(angle) * 160
            NSLayoutConstraint.activate([
                spark.centerXAnchor.constraint(equalTo: centerXAnchor, constant: xOffset),
                spark.centerYAnchor.constraint(equalTo: centerYAnchor, constant: yOffset),
                spark.widthAnchor.constraint(equalToConstant: index.isMultiple(of: 3) ? 6 : 4),
                spark.heightAnchor.constraint(equalToConstant: index.isMultiple(of: 3) ? 6 : 4)
            ])
        }
    }

    private func resetState() {
        alpha = 0.0
        transform = .identity
        rewardImageVisible = false
        cardImageView.image = nil
        cardImageView.alpha = 0.0
        placeholderLabel.alpha = 1.0
        cardContainerView.alpha = 1.0
        cardContainerView.transform = CGAffineTransform(scaleX: 0.88, y: 0.88).concatenating(CGAffineTransform(translationX: 0, y: 24))
        auraView.alpha = 0.0
        auraView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        starStackView.alpha = 0.0

        for (index, starView) in starViews.enumerated() {
            starView.alpha = 0.0
            starView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            starView.isHidden = index >= finalStars
        }

        for spark in sparkViews {
            spark.alpha = 0.0
            spark.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            spark.layer.removeAllAnimations()
        }

        ringLayer.removeAllAnimations()
        innerRingLayer.removeAllAnimations()
        auraView.layer.removeAllAnimations()
        cardContainerView.layer.removeAllAnimations()
        mysteryCardView.layer.removeAllAnimations()
        cardImageView.layer.removeAllAnimations()
    }

    private func runSequence() {
        animateIntro()

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.chargeUpStart) { [weak self] in
            self?.animateChargeUp()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.fakeOutStart) { [weak self] in
            self?.animateFakeOut()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.paletteRevealStart) { [weak self] in
            self?.animatePaletteReveal()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.rarityRevealStart) { [weak self] in
            self?.animateRarityReveal()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.rewardRevealStart) { [weak self] in
            self?.animateRewardReveal()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.finishStart) { [weak self] in
            self?.finishSequence()
        }
    }

    private func animateIntro() {
        mediumImpact.impactOccurred(intensity: 0.7)

        UIView.animate(withDuration: 0.32) {
            self.alpha = 1.0
        }

        UIView.animate(
            withDuration: 0.82,
            delay: 0.0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut],
            animations: {
                self.cardContainerView.transform = .identity
                self.auraView.alpha = 0.7
                self.auraView.transform = .identity
            },
            completion: nil
        )

        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 0.9
        pulse.toValue = 1.05
        pulse.duration = 1.9
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        auraView.layer.add(pulse, forKey: "auraPulse")

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.12
        fade.toValue = 0.32
        fade.duration = 1.8
        fade.autoreverses = true
        fade.repeatCount = .infinity
        ringLayer.add(fade, forKey: "ringFade")
        innerRingLayer.add(fade, forKey: "innerRingFade")

        startSparkAnimations(baseDelay: 0.0)
    }

    private func animateChargeUp() {
        selectionFeedback.selectionChanged()

        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wobble.values = [-0.04, 0.05, -0.03, 0.03, 0.0]
        wobble.keyTimes = [0.0, 0.22, 0.48, 0.74, 1.0]
        wobble.duration = 0.7
        wobble.repeatCount = 5
        mysteryCardView.layer.add(wobble, forKey: "wobble")

        let floatAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        floatAnimation.fromValue = -4
        floatAnimation.toValue = 6
        floatAnimation.duration = 1.1
        floatAnimation.autoreverses = true
        floatAnimation.repeatCount = 4
        mysteryCardView.layer.add(floatAnimation, forKey: "float")

        UIView.animate(withDuration: 0.7) {
            self.auraView.alpha = 0.92
            self.auraView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }

        let ringScale = CABasicAnimation(keyPath: "transform.scale")
        ringScale.fromValue = 0.95
        ringScale.toValue = 1.06
        ringScale.duration = 1.0
        ringScale.autoreverses = true
        ringScale.repeatCount = 4
        ringLayer.add(ringScale, forKey: "ringScale")

        let borderPulse = CABasicAnimation(keyPath: "opacity")
        borderPulse.fromValue = 0.65
        borderPulse.toValue = 0.9
        borderPulse.duration = 0.52
        borderPulse.autoreverses = true
        borderPulse.repeatCount = 6
        borderGradientLayer.add(borderPulse, forKey: "borderPulse")
    }

    private func animateFakeOut() {
        let intensity = 0.82
        heavyImpact.impactOccurred(intensity: intensity)

        UIView.animate(withDuration: 0.18, animations: {
            self.flashView.alpha = 0.16
            self.cardContainerView.transform = CGAffineTransform(scaleX: 1.025, y: 1.025)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.flashView.alpha = 0.0
                self.cardContainerView.transform = .identity
            }
        }

        let burstScale = CABasicAnimation(keyPath: "transform.scale")
        burstScale.fromValue = 1.0
        burstScale.toValue = 1.14
        burstScale.duration = 0.4
        burstScale.autoreverses = true
        auraView.layer.add(burstScale, forKey: "burstScale")
    }

    private func animatePaletteReveal() {
        let palette = paletteForCurrentRarity()
        applyPalette(palette, animated: true)

        let revealFlash = CAKeyframeAnimation(keyPath: "opacity")
        revealFlash.values = [0.0, 0.22, 0.0]
        revealFlash.keyTimes = [0.0, 0.35, 1.0]
        revealFlash.duration = 0.5
        flashView.layer.add(revealFlash, forKey: "revealFlash")

        if finalStars == 3 {
            let upgradeFlash = CAKeyframeAnimation(keyPath: "opacity")
            upgradeFlash.values = [0.0, 0.45, 0.0, 0.55, 0.0]
            upgradeFlash.keyTimes = [0.0, 0.18, 0.42, 0.68, 1.0]
            upgradeFlash.duration = 0.8
            flashView.layer.add(upgradeFlash, forKey: "upgradeFlash")
        }
    }

    private func animateRarityReveal() {
        mediumImpact.impactOccurred(intensity: 1.0)

        UIView.animate(withDuration: 0.2) {
            self.starStackView.alpha = 1.0
            self.placeholderLabel.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }

        for index in 0..<finalStars {
            let starView = starViews[index]
            let delay = 0.05 + (Double(index) * 0.09)
            UIView.animate(
                withDuration: 0.3,
                delay: delay,
                usingSpringWithDamping: 0.58,
                initialSpringVelocity: 0.4,
                options: [.curveEaseOut],
                animations: {
                    starView.alpha = 1.0
                    starView.transform = .identity
                    starView.layer.shadowOpacity = 0.9
                },
                completion: nil
            )
        }

        if finalStars == 3 {
            UIView.animate(withDuration: 0.34) {
                self.auraView.transform = CGAffineTransform(scaleX: 1.24, y: 1.24)
            }
        }
    }

    private func animateRewardReveal() {
        rewardImageVisible = true
        mediumImpact.impactOccurred(intensity: 0.82)

        if let rewardImage {
            cardImageView.image = rewardImage
        }

        let flip = CATransition()
        flip.type = .push
        flip.subtype = .fromTop
        flip.duration = 0.42
        flip.timingFunction = CAMediaTimingFunction(name: .easeOut)
        mysteryCardView.layer.add(flip, forKey: "rewardFlip")

        UIView.animate(withDuration: 0.28) {
            self.placeholderLabel.alpha = self.rewardImage == nil ? 0.18 : 0.0
            self.cardImageView.alpha = self.rewardImage == nil ? 0.0 : 1.0
            self.cardContainerView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }

        UIView.animate(
            withDuration: 0.24,
            delay: 0.12,
            options: [.curveEaseOut],
            animations: {
                self.cardContainerView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            },
            completion: nil
        )
    }

    private func finishSequence() {
        UIView.animate(withDuration: 0.24, animations: {
            self.alpha = 0.0
            self.cardContainerView.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
        }) { _ in
            self.completion?()
        }
    }

    private func startSparkAnimations(baseDelay: TimeInterval) {
        let intensity = finalStars == 3 ? 1.0 : (finalStars == 2 ? 0.75 : 0.5)

        for (index, spark) in sparkViews.enumerated() {
            let delay = baseDelay + (Double(index % 6) * 0.08)
            UIView.animate(
                withDuration: 0.45,
                delay: delay,
                options: [.curveEaseOut],
                animations: {
                    spark.alpha = 0.28 + (0.35 * intensity)
                    spark.transform = .identity
                },
                completion: nil
            )

            let drift = CABasicAnimation(keyPath: "transform.translation.y")
            drift.fromValue = 0
            drift.toValue = -18 - CGFloat(index % 4) * 8
            drift.duration = 1.2 + Double(index % 5) * 0.18
            drift.autoreverses = true
            drift.repeatCount = .infinity
            drift.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            spark.layer.add(drift, forKey: "sparkDrift")

            let twinkle = CABasicAnimation(keyPath: "opacity")
            twinkle.fromValue = 0.12
            twinkle.toValue = 0.75
            twinkle.duration = 0.9 + Double(index % 4) * 0.15
            twinkle.autoreverses = true
            twinkle.repeatCount = .infinity
            spark.layer.add(twinkle, forKey: "sparkTwinkle")
        }
    }

    private func applyPalette(_ palette: Palette, animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        CATransaction.setAnimationDuration(animated ? 0.55 : 0.0)

        ringLayer.strokeColor = palette.secondary.cgColor
        innerRingLayer.strokeColor = palette.primary.withAlphaComponent(0.8).cgColor
        flashView.backgroundColor = palette.secondary.withAlphaComponent(0.95)
        borderGradientLayer.colors = [
            palette.primary.withAlphaComponent(0.75).cgColor,
            palette.secondary.cgColor,
            UIColor.white.withAlphaComponent(0.86).cgColor
        ]

        CATransaction.commit()

        UIView.animate(withDuration: animated ? 0.55 : 0.0) {
            self.auraView.backgroundColor = palette.glow.withAlphaComponent(0.35)
            self.mysteryCardView.backgroundColor = palette.primary.withAlphaComponent(0.18)
        }

        for starView in starViews {
            starView.tintColor = palette.secondary
            starView.layer.shadowColor = palette.glow.cgColor
        }

        for spark in sparkViews {
            spark.backgroundColor = palette.secondary
        }
    }

    private func paletteForCurrentRarity() -> Palette {
        switch finalStars {
        case 1:
            return Palette(
                primary: UIColor(red: 0.79, green: 0.85, blue: 0.92, alpha: 1.0),
                secondary: UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0),
                glow: UIColor(red: 0.74, green: 0.86, blue: 1.0, alpha: 1.0)
            )
        case 2:
            return Palette(
                primary: UIColor(red: 0.95, green: 0.73, blue: 0.28, alpha: 1.0),
                secondary: UIColor(red: 1.0, green: 0.83, blue: 0.34, alpha: 1.0),
                glow: UIColor(red: 1.0, green: 0.76, blue: 0.22, alpha: 1.0)
            )
        default:
            return Palette(
                primary: UIColor(red: 0.45, green: 0.28, blue: 0.85, alpha: 1.0),
                secondary: UIColor(red: 0.74, green: 0.60, blue: 1.0, alpha: 1.0),
                glow: UIColor(red: 0.58, green: 0.36, blue: 0.95, alpha: 1.0)
            )
        }
    }

    private func neutralPalette() -> Palette {
        Palette(
            primary: UIColor(red: 0.52, green: 0.59, blue: 0.67, alpha: 1.0),
            secondary: UIColor(red: 0.83, green: 0.88, blue: 0.93, alpha: 1.0),
            glow: UIColor(red: 0.70, green: 0.77, blue: 0.86, alpha: 1.0)
        )
    }

    private func prepareHaptics() {
        heavyImpact.prepare()
        mediumImpact.prepare()
        selectionFeedback.prepare()
    }
}

class SpinningStarAnimationView: UIView, GachaAnimationView {
    private struct Timing {
        static let introDuration: TimeInterval = 0.6
        static let spinPhaseDuration: TimeInterval = 4.0
        static let pulseBurstAt: TimeInterval = 2.5
        static let explodeAt: TimeInterval = 4.0
        static let finishAt: TimeInterval = 7.0
    }

    private let backdropGradientLayer = CAGradientLayer()
    private let starContainerView = UIView()
    private let spinningStarView = UIImageView(image: UIImage(systemName: "star.fill"))
    private let orbitRingLayer = CAShapeLayer()
    private let pulseLayer = CAShapeLayer()
    private let flashView = UIView()
    private let rarityStarsContainer = UIView()
    private let starStackView = UIStackView()

    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

    private var finalStars = 1
    private var completion: (() -> Void)?
    private var rarityStarViews: [UIImageView] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backdropGradientLayer.frame = bounds
        flashView.frame = bounds
        orbitRingLayer.frame = bounds
        pulseLayer.frame = bounds

        let ringRect = starContainerView.frame.insetBy(dx: -28, dy: -28)
        orbitRingLayer.path = UIBezierPath(ovalIn: ringRect).cgPath

        let pulseRect = starContainerView.frame.insetBy(dx: -52, dy: -52)
        pulseLayer.path = UIBezierPath(ovalIn: pulseRect).cgPath
    }

    func setRewardImage(_ image: UIImage?) {
    }

    func startAnimation(finalStars: Int, completion: @escaping () -> Void) {
        self.finalStars = max(1, min(3, finalStars))
        self.completion = completion
        resetState()
        prepareHaptics()
        runSequence()
    }

    private func setupView() {
        backgroundColor = .clear

        backdropGradientLayer.colors = [
            UIColor(red: 0.03, green: 0.04, blue: 0.08, alpha: 0.98).cgColor,
            UIColor(red: 0.05, green: 0.08, blue: 0.16, alpha: 0.96).cgColor,
            UIColor(red: 0.01, green: 0.02, blue: 0.05, alpha: 0.98).cgColor
        ]
        backdropGradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        backdropGradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        layer.addSublayer(backdropGradientLayer)

        flashView.backgroundColor = .white
        flashView.alpha = 0.0
        addSubview(flashView)

        orbitRingLayer.fillColor = UIColor.clear.cgColor
        orbitRingLayer.strokeColor = UIColor.white.withAlphaComponent(0.32).cgColor
        orbitRingLayer.lineWidth = 2
        layer.addSublayer(orbitRingLayer)

        pulseLayer.fillColor = UIColor.white.withAlphaComponent(0.08).cgColor
        pulseLayer.opacity = 0.0
        layer.addSublayer(pulseLayer)

        starContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(starContainerView)

        spinningStarView.translatesAutoresizingMaskIntoConstraints = false
        spinningStarView.tintColor = UIColor(red: 0.92, green: 0.95, blue: 1.0, alpha: 1.0)
        spinningStarView.contentMode = .scaleAspectFit
        spinningStarView.layer.shadowColor = UIColor.white.cgColor
        spinningStarView.layer.shadowOpacity = 0.9
        spinningStarView.layer.shadowRadius = 24
        spinningStarView.layer.shadowOffset = .zero
        starContainerView.addSubview(spinningStarView)

        rarityStarsContainer.translatesAutoresizingMaskIntoConstraints = false
        rarityStarsContainer.alpha = 0.0
        starContainerView.addSubview(rarityStarsContainer)

        starStackView.translatesAutoresizingMaskIntoConstraints = false
        starStackView.axis = .horizontal
        starStackView.alignment = .center
        starStackView.distribution = .equalSpacing
        starStackView.spacing = 16
        starStackView.alpha = 1.0
        rarityStarsContainer.addSubview(starStackView)

        for _ in 0..<3 {
            let starView = UIImageView(image: UIImage(systemName: "star.fill"))
            starView.translatesAutoresizingMaskIntoConstraints = false
            starView.contentMode = .scaleAspectFit
            starView.alpha = 0.0
            starView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            starView.layer.shadowOpacity = 0.0
            starView.layer.shadowRadius = 16
            starView.layer.shadowOffset = .zero
            NSLayoutConstraint.activate([
                starView.widthAnchor.constraint(equalToConstant: 38),
                starView.heightAnchor.constraint(equalToConstant: 38)
            ])
            starStackView.addArrangedSubview(starView)
            rarityStarViews.append(starView)
        }

        NSLayoutConstraint.activate([
            starContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            starContainerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6),
            starContainerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.34),
            starContainerView.heightAnchor.constraint(equalTo: starContainerView.widthAnchor),
            starContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 240),

            spinningStarView.centerXAnchor.constraint(equalTo: starContainerView.centerXAnchor),
            spinningStarView.centerYAnchor.constraint(equalTo: starContainerView.centerYAnchor),
            spinningStarView.widthAnchor.constraint(equalTo: starContainerView.widthAnchor, multiplier: 0.78),
            spinningStarView.heightAnchor.constraint(equalTo: spinningStarView.widthAnchor),

            rarityStarsContainer.centerXAnchor.constraint(equalTo: starContainerView.centerXAnchor),
            rarityStarsContainer.centerYAnchor.constraint(equalTo: starContainerView.centerYAnchor),
            rarityStarsContainer.widthAnchor.constraint(equalTo: starContainerView.widthAnchor, multiplier: 0.72),
            rarityStarsContainer.heightAnchor.constraint(equalTo: rarityStarsContainer.widthAnchor, multiplier: 0.42),

            starStackView.leadingAnchor.constraint(equalTo: rarityStarsContainer.leadingAnchor),
            starStackView.trailingAnchor.constraint(equalTo: rarityStarsContainer.trailingAnchor),
            starStackView.topAnchor.constraint(equalTo: rarityStarsContainer.topAnchor),
            starStackView.bottomAnchor.constraint(equalTo: rarityStarsContainer.bottomAnchor)
        ])
    }

    private func resetState() {
        alpha = 0.0
        starContainerView.alpha = 1.0
        starContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        spinningStarView.alpha = 1.0
        spinningStarView.transform = .identity
        spinningStarView.tintColor = UIColor(red: 0.92, green: 0.95, blue: 1.0, alpha: 1.0)
        spinningStarView.layer.removeAllAnimations()
        flashView.alpha = 0.0
        orbitRingLayer.removeAllAnimations()
        pulseLayer.removeAllAnimations()
        rarityStarsContainer.alpha = 0.0
        rarityStarsContainer.transform = .identity
        rarityStarsContainer.layer.removeAllAnimations()

        for (index, starView) in rarityStarViews.enumerated() {
            starView.alpha = 0.0
            starView.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
            starView.isHidden = index >= finalStars
            starView.tintColor = colorForRarity()
            starView.layer.shadowColor = glowColorForRarity().cgColor
            starView.layer.shadowOpacity = 0.0
        }
    }

    private func runSequence() {
        UIView.animate(withDuration: 0.28) {
            self.alpha = 1.0
        }

        UIView.animate(
            withDuration: 0.6,
            delay: 0.0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.4,
            options: [.curveEaseOut],
            animations: {
                self.starContainerView.transform = .identity
            },
            completion: nil
        )

        let spin = CABasicAnimation(keyPath: "transform.rotation.z")
        spin.fromValue = 0
        spin.toValue = CGFloat.pi * 18
        spin.duration = Timing.spinPhaseDuration
        spin.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        spin.fillMode = .forwards
        spin.isRemovedOnCompletion = false
        spinningStarView.layer.add(spin, forKey: "spin")

        let scale = CAKeyframeAnimation(keyPath: "transform.scale")
        scale.values = [1.0, 1.04, 1.12, 1.22, 1.34]
        scale.keyTimes = [0.0, 0.28, 0.58, 0.82, 1.0]
        scale.duration = Timing.spinPhaseDuration
        scale.fillMode = .forwards
        scale.isRemovedOnCompletion = false
        spinningStarView.layer.add(scale, forKey: "scale")

        let ringPulse = CABasicAnimation(keyPath: "opacity")
        ringPulse.fromValue = 0.18
        ringPulse.toValue = 0.6
        ringPulse.duration = 0.7
        ringPulse.autoreverses = true
        ringPulse.repeatCount = 6
        orbitRingLayer.add(ringPulse, forKey: "orbitOpacity")

        let ringScale = CABasicAnimation(keyPath: "transform.scale")
        ringScale.fromValue = 0.92
        ringScale.toValue = 1.08
        ringScale.duration = 0.7
        ringScale.autoreverses = true
        ringScale.repeatCount = 6
        orbitRingLayer.add(ringScale, forKey: "orbitScale")

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.pulseBurstAt) { [weak self] in
            self?.mediumImpact.impactOccurred(intensity: 0.78)
            self?.pulseLayer.opacity = 1.0

            let pulseBurst = CABasicAnimation(keyPath: "transform.scale")
            pulseBurst.fromValue = 0.4
            pulseBurst.toValue = 1.0
            pulseBurst.duration = 0.4
            pulseBurst.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self?.pulseLayer.add(pulseBurst, forKey: "pulseBurst")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.explodeAt) { [weak self] in
            self?.explodeIntoRarity()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.finishAt) { [weak self] in
            self?.finishSequence()
        }
    }

    private func explodeIntoRarity() {
        heavyImpact.impactOccurred(intensity: finalStars == 3 ? 1.0 : 0.84)

        let rarityColor = colorForRarity()
        let rarityGlow = glowColorForRarity()
        spinningStarView.tintColor = rarityColor
        spinningStarView.layer.shadowColor = rarityGlow.cgColor
        flashView.backgroundColor = rarityGlow.withAlphaComponent(0.95)

        UIView.animate(withDuration: 0.12, animations: {
            self.flashView.alpha = 0.24
            self.spinningStarView.transform = CGAffineTransform(scaleX: 1.65, y: 1.65)
            self.spinningStarView.alpha = 0.0
        }) { _ in
            self.spinningStarView.isHidden = true
            UIView.animate(withDuration: 0.28) {
                self.flashView.alpha = 0.0
                self.rarityStarsContainer.alpha = 1.0
            }
        }

        orbitRingLayer.strokeColor = rarityColor.withAlphaComponent(0.72).cgColor
        pulseLayer.fillColor = rarityGlow.withAlphaComponent(0.22).cgColor

        for index in 0..<finalStars {
            let starView = rarityStarViews[index]
            let delay = Double(index) * 0.08
            UIView.animate(
                withDuration: 0.32,
                delay: delay,
                usingSpringWithDamping: 0.56,
                initialSpringVelocity: 0.45,
                options: [.curveEaseOut],
                animations: {
                    starView.alpha = 1.0
                    starView.transform = .identity
                    starView.layer.shadowOpacity = 0.92
                },
                completion: nil
            )
        }

        let slowSpin = CABasicAnimation(keyPath: "transform.rotation.z")
        slowSpin.fromValue = 0
        slowSpin.toValue = CGFloat.pi * 2
        slowSpin.duration = 2.8
        slowSpin.repeatCount = .infinity
        slowSpin.timingFunction = CAMediaTimingFunction(name: .linear)
        rarityStarsContainer.layer.add(slowSpin, forKey: "raritySlowSpin")
    }

    private func finishSequence() {
        UIView.animate(withDuration: 0.24, animations: {
            self.alpha = 0.0
        }) { _ in
            self.completion?()
        }
    }

    private func colorForRarity() -> UIColor {
        switch finalStars {
        case 1:
            return UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0)
        case 2:
            return UIColor(red: 1.0, green: 0.83, blue: 0.34, alpha: 1.0)
        default:
            return UIColor(red: 0.74, green: 0.60, blue: 1.0, alpha: 1.0)
        }
    }

    private func glowColorForRarity() -> UIColor {
        switch finalStars {
        case 1:
            return UIColor(red: 0.74, green: 0.86, blue: 1.0, alpha: 1.0)
        case 2:
            return UIColor(red: 1.0, green: 0.76, blue: 0.22, alpha: 1.0)
        default:
            return UIColor(red: 0.58, green: 0.36, blue: 0.95, alpha: 1.0)
        }
    }

    private func prepareHaptics() {
        heavyImpact.prepare()
        mediumImpact.prepare()
    }
}

class AirportBoardAnimationView: UIView, GachaAnimationView {
    private struct Timing {
        static let firstReveal: TimeInterval = 5.0
        static let secondReveal: TimeInterval = 6.0
        static let thirdReveal: TimeInterval = 7.0
        static let finishDelay: TimeInterval = 0.4
    }

    private enum RevealState {
        case revealA
        case revealB
        case revealC
    }

    private let backdropGradientLayer = CAGradientLayer()
    private let boardView = UIView()
    private let boardGlowView = UIView()
    private let slotStackView = UIStackView()
    private let flashView = UIView()

    private var slotViews: [UIView] = []
    private var slotLabels: [UILabel] = []
    private var slotWorkItems: [DispatchWorkItem] = []
    private var finalStars = 1
    private var completion: (() -> Void)?

    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backdropGradientLayer.frame = bounds
        flashView.frame = bounds
        boardGlowView.layer.cornerRadius = boardGlowView.bounds.width / 2
    }

    func setRewardImage(_ image: UIImage?) {
    }

    func startAnimation(finalStars: Int, completion: @escaping () -> Void) {
        self.finalStars = max(1, min(3, finalStars))
        self.completion = completion
        resetState()
        prepareHaptics()
        runSequence()
    }

    private func setupView() {
        backgroundColor = .clear

        backdropGradientLayer.colors = [
            UIColor(red: 0.03, green: 0.04, blue: 0.08, alpha: 0.98).cgColor,
            UIColor(red: 0.05, green: 0.08, blue: 0.16, alpha: 0.96).cgColor,
            UIColor(red: 0.01, green: 0.02, blue: 0.05, alpha: 0.98).cgColor
        ]
        backdropGradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
        backdropGradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        layer.addSublayer(backdropGradientLayer)

        flashView.backgroundColor = .white
        flashView.alpha = 0.0
        addSubview(flashView)

        boardGlowView.translatesAutoresizingMaskIntoConstraints = false
        boardGlowView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        boardGlowView.alpha = 0.0
        addSubview(boardGlowView)

        boardView.translatesAutoresizingMaskIntoConstraints = false
        boardView.backgroundColor = UIColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 0.98)
        boardView.layer.cornerRadius = 28
        boardView.layer.shadowColor = UIColor.black.cgColor
        boardView.layer.shadowOpacity = 0.32
        boardView.layer.shadowRadius = 26
        boardView.layer.shadowOffset = CGSize(width: 0, height: 16)
        addSubview(boardView)

        slotStackView.translatesAutoresizingMaskIntoConstraints = false
        slotStackView.axis = .horizontal
        slotStackView.alignment = .fill
        slotStackView.distribution = .fillEqually
        slotStackView.spacing = 14
        boardView.addSubview(slotStackView)

        for _ in 0..<3 {
            let slotView = UIView()
            slotView.translatesAutoresizingMaskIntoConstraints = false
            slotView.backgroundColor = UIColor(red: 0.16, green: 0.18, blue: 0.25, alpha: 1.0)
            slotView.layer.cornerRadius = 16
            slotView.layer.borderWidth = 1.5
            slotView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
            slotStackView.addArrangedSubview(slotView)
            slotViews.append(slotView)

            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = UIFont.monospacedSystemFont(ofSize: 44, weight: .black)
            label.textColor = UIColor.white.withAlphaComponent(0.92)
            label.text = "★"
            slotView.addSubview(label)
            slotLabels.append(label)

            NSLayoutConstraint.activate([
                slotView.heightAnchor.constraint(equalToConstant: 128),
                label.centerXAnchor.constraint(equalTo: slotView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: slotView.centerYAnchor)
            ])
        }

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "ARRIVAL BOARD"
        titleLabel.font = UIFont.monospacedSystemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.56)
        titleLabel.textAlignment = .center
        boardView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            boardGlowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            boardGlowView.centerYAnchor.constraint(equalTo: centerYAnchor),
            boardGlowView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.72),
            boardGlowView.heightAnchor.constraint(equalTo: boardGlowView.widthAnchor),

            boardView.centerXAnchor.constraint(equalTo: centerXAnchor),
            boardView.centerYAnchor.constraint(equalTo: centerYAnchor),
            boardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.78),
            boardView.widthAnchor.constraint(lessThanOrEqualToConstant: 620),

            titleLabel.topAnchor.constraint(equalTo: boardView.topAnchor, constant: 22),
            titleLabel.centerXAnchor.constraint(equalTo: boardView.centerXAnchor),

            slotStackView.leadingAnchor.constraint(equalTo: boardView.leadingAnchor, constant: 24),
            slotStackView.trailingAnchor.constraint(equalTo: boardView.trailingAnchor, constant: -24),
            slotStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            slotStackView.bottomAnchor.constraint(equalTo: boardView.bottomAnchor, constant: -24)
        ])
    }

    private func resetState() {
        slotWorkItems.forEach { $0.cancel() }
        slotWorkItems.removeAll()

        alpha = 0.0
        boardView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        boardGlowView.alpha = 0.0
        flashView.alpha = 0.0

        for (index, label) in slotLabels.enumerated() {
            label.alpha = 1.0
            label.transform = .identity
            label.text = "★"
            label.textColor = UIColor.white.withAlphaComponent(0.92)
            slotViews[index].layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        }
    }

    private func runSequence() {
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.86,
            initialSpringVelocity: 0.45,
            options: [.curveEaseOut],
            animations: {
                self.alpha = 1.0
                self.boardView.transform = .identity
                self.boardGlowView.alpha = 0.75
            },
            completion: nil
        )

        let glowPulse = CABasicAnimation(keyPath: "transform.scale")
        glowPulse.fromValue = 0.92
        glowPulse.toValue = 1.06
        glowPulse.duration = 1.1
        glowPulse.autoreverses = true
        glowPulse.repeatCount = .infinity
        glowPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        boardGlowView.layer.add(glowPulse, forKey: "glowPulse")

        scheduleRandomFlip(for: 0, until: Timing.firstReveal)
        scheduleRandomFlip(for: 1, until: Timing.firstReveal)
        scheduleRandomFlip(for: 2, until: Timing.firstReveal)

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.firstReveal) { [weak self] in
            self?.cancelRandomFlips()
            self?.applyRevealState(.revealA)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.secondReveal) { [weak self] in
            guard let self else { return }
            if self.finalStars == 2 {
                self.applyRevealState(.revealB)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.thirdReveal) { [weak self] in
            guard let self else { return }
            if self.finalStars == 3 {
                self.applyRevealState(.revealC)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Timing.thirdReveal + Timing.finishDelay) { [weak self] in
            self?.finishSequence()
        }
    }

    private func scheduleRandomFlip(for index: Int, until stopTime: TimeInterval) {
        func loop(elapsed: TimeInterval) {
            guard elapsed < stopTime else { return }
            animateRandomFlip(for: index)

            let nextDelay = min(0.34, max(0.14, 0.30 - (elapsed * 0.02)))
            let workItem = DispatchWorkItem {
                loop(elapsed: elapsed + nextDelay)
            }
            slotWorkItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + nextDelay, execute: workItem)
        }

        loop(elapsed: 0.0)
    }

    private func cancelRandomFlips() {
        slotWorkItems.forEach { $0.cancel() }
        slotWorkItems.removeAll()
    }

    private func animateRandomFlip(for index: Int) {
        let label = slotLabels[index]
        let slotView = slotViews[index]
        let randomState: RevealState = [.revealA, .revealB, .revealC].randomElement() ?? .revealA
        let spec = specsForRevealState(randomState)[index]

        UIView.transition(with: slotView, duration: 0.22, options: [.transitionFlipFromBottom, .curveEaseInOut]) {
            label.text = spec.symbol
            label.textColor = spec.symbol == "★"
                ? spec.color.withAlphaComponent(0.92)
                : UIColor.clear
        }
    }

    private func applyRevealState(_ state: RevealState) {
        let specs = specsForRevealState(state)
        mediumImpact.impactOccurred(intensity: state == .revealA ? 0.82 : 0.74)

        for (index, spec) in specs.enumerated() {
            let label = slotLabels[index]
            let slotView = slotViews[index]

            UIView.transition(with: slotView, duration: 0.24, options: [.transitionFlipFromBottom, .curveEaseInOut]) {
                label.text = spec.symbol
                label.textColor = spec.color
            }

            UIView.animate(withDuration: 0.22) {
                slotView.layer.borderColor = spec.borderColor.cgColor
                label.layer.shadowColor = spec.glowColor.cgColor
                label.layer.shadowOpacity = spec.symbol == "★" ? 0.9 : 0.0
                label.layer.shadowRadius = spec.symbol == "★" ? 16 : 0
                label.transform = spec.symbol == "★" ? CGAffineTransform(scaleX: 1.08, y: 1.08) : .identity
            } completion: { _ in
                UIView.animate(withDuration: 0.18) {
                    label.transform = .identity
                }
            }
        }

        let dominantGlow = specs.compactMap { $0.symbol == "★" ? $0.glowColor : nil }.last ?? UIColor.white
        flashView.backgroundColor = dominantGlow.withAlphaComponent(0.9)
        UIView.animate(withDuration: 0.08, animations: {
            self.flashView.alpha = 0.14
        }) { _ in
            UIView.animate(withDuration: 0.18) {
                self.flashView.alpha = 0.0
            }
        }
    }

    private func finishSequence() {
        heavyImpact.impactOccurred(intensity: finalStars == 3 ? 1.0 : 0.82)
        UIView.animate(withDuration: 0.24, animations: {
            self.alpha = 0.0
        }) { _ in
            self.completion?()
        }
    }

    private func colorForRarity() -> UIColor {
        switch finalStars {
        case 1:
            return UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0)
        case 2:
            return UIColor(red: 1.0, green: 0.83, blue: 0.34, alpha: 1.0)
        default:
            return UIColor(red: 0.74, green: 0.60, blue: 1.0, alpha: 1.0)
        }
    }

    private func glowColorForRarity() -> UIColor {
        switch finalStars {
        case 1:
            return UIColor(red: 0.74, green: 0.86, blue: 1.0, alpha: 1.0)
        case 2:
            return UIColor(red: 1.0, green: 0.76, blue: 0.22, alpha: 1.0)
        default:
            return UIColor(red: 0.58, green: 0.36, blue: 0.95, alpha: 1.0)
        }
    }

    private func prepareHaptics() {
        heavyImpact.prepare()
        mediumImpact.prepare()
    }

    private func specsForRevealState(_ state: RevealState) -> [(symbol: String, color: UIColor, borderColor: UIColor, glowColor: UIColor)] {
        let white = UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0)
        let whiteGlow = UIColor(red: 0.74, green: 0.86, blue: 1.0, alpha: 1.0)
        let gold = UIColor(red: 1.0, green: 0.83, blue: 0.34, alpha: 1.0)
        let goldGlow = UIColor(red: 1.0, green: 0.76, blue: 0.22, alpha: 1.0)
        let purple = UIColor(red: 0.74, green: 0.60, blue: 1.0, alpha: 1.0)
        let purpleGlow = UIColor(red: 0.58, green: 0.36, blue: 0.95, alpha: 1.0)
        let emptyBorder = UIColor.white.withAlphaComponent(0.12)
        let clear = UIColor.clear

        switch state {
        case .revealA:
            return [
                ("★", white, whiteGlow.withAlphaComponent(0.88), whiteGlow),
                ("", clear, emptyBorder, clear),
                ("", clear, emptyBorder, clear)
            ]
        case .revealB:
            return [
                ("★", gold, goldGlow.withAlphaComponent(0.88), goldGlow),
                ("★", gold, goldGlow.withAlphaComponent(0.88), goldGlow),
                ("", clear, emptyBorder, clear)
            ]
        case .revealC:
            return [
                ("★", purple, purpleGlow.withAlphaComponent(0.88), purpleGlow),
                ("★", purple, purpleGlow.withAlphaComponent(0.88), purpleGlow),
                ("★", purple, purpleGlow.withAlphaComponent(0.88), purpleGlow)
            ]
        }
    }
}

class SlotReelAnimationView: UIView, GachaAnimationView {
    private enum ReelOutcome {
        case star
        case miss
    }

    private let backdropView = UIView()
    private let machineView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let flashView = UIView()
    private let glowView = UIView()
    private let reelsStackView = UIStackView()
    private let leverTrackView = UIView()
    private let leverKnobView = UIView()

    private var reelWindows: [UIView] = []
    private var reelContainers: [UIView] = []
    private var reelIconViews: [UIImageView] = []
    private var reelLockedStates: [Bool] = []
    private var spinWorkItems: [DispatchWorkItem] = []
    private var completion: (() -> Void)?
    private var finalStars = 1
    private var rewardImage: UIImage?

    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    deinit {
        cancelScheduledWork()
    }

    func setRewardImage(_ image: UIImage?) {
        rewardImage = image
    }

    func startAnimation(finalStars: Int, completion: @escaping () -> Void) {
        self.finalStars = max(1, min(3, finalStars))
        self.completion = completion
        resetState()
        prepareHaptics()
        runSequence()
    }

    private func setupView() {
        backgroundColor = .clear

        backdropView.translatesAutoresizingMaskIntoConstraints = false
        backdropView.backgroundColor = UIColor.black.withAlphaComponent(0.84)
        addSubview(backdropView)

        flashView.translatesAutoresizingMaskIntoConstraints = false
        flashView.backgroundColor = .white
        flashView.alpha = 0.0
        addSubview(flashView)

        glowView.translatesAutoresizingMaskIntoConstraints = false
        glowView.backgroundColor = UIColor(red: 0.49, green: 0.75, blue: 1.0, alpha: 0.28)
        glowView.layer.cornerRadius = 170
        glowView.alpha = 0.0
        addSubview(glowView)

        machineView.translatesAutoresizingMaskIntoConstraints = false
        machineView.backgroundColor = UIColor(red: 0.15, green: 0.18, blue: 0.25, alpha: 1.0)
        machineView.layer.cornerRadius = 34
        machineView.layer.borderWidth = 2
        machineView.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        machineView.layer.shadowColor = UIColor.black.cgColor
        machineView.layer.shadowOpacity = 0.34
        machineView.layer.shadowRadius = 26
        machineView.layer.shadowOffset = CGSize(width: 0, height: 16)
        addSubview(machineView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "SLOT MACHINE"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 26, weight: .black)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.96)
        machineView.addSubview(titleLabel)

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Three reels. One fate."
        subtitleLabel.textAlignment = .center
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.62)
        machineView.addSubview(subtitleLabel)

        reelsStackView.translatesAutoresizingMaskIntoConstraints = false
        reelsStackView.axis = .horizontal
        reelsStackView.alignment = .fill
        reelsStackView.distribution = .fillEqually
        reelsStackView.spacing = 16
        machineView.addSubview(reelsStackView)

        for _ in 0..<3 {
            let reelWindow = UIView()
            reelWindow.translatesAutoresizingMaskIntoConstraints = false
            reelWindow.backgroundColor = UIColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1.0)
            reelWindow.layer.cornerRadius = 22
            reelWindow.layer.borderWidth = 1.5
            reelWindow.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
            reelWindow.clipsToBounds = true

            let reelContainer = UIView()
            reelContainer.translatesAutoresizingMaskIntoConstraints = false
            reelWindow.addSubview(reelContainer)

            let iconView = UIImageView(image: UIImage(systemName: "star.fill"))
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = UIColor.white.withAlphaComponent(0.92)
            iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 46, weight: .bold)
            reelContainer.addSubview(iconView)

            NSLayoutConstraint.activate([
                reelContainer.leadingAnchor.constraint(equalTo: reelWindow.leadingAnchor),
                reelContainer.trailingAnchor.constraint(equalTo: reelWindow.trailingAnchor),
                reelContainer.topAnchor.constraint(equalTo: reelWindow.topAnchor),
                reelContainer.bottomAnchor.constraint(equalTo: reelWindow.bottomAnchor),

                iconView.centerXAnchor.constraint(equalTo: reelContainer.centerXAnchor),
                iconView.centerYAnchor.constraint(equalTo: reelContainer.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 58),
                iconView.heightAnchor.constraint(equalToConstant: 58),
            ])

            reelsStackView.addArrangedSubview(reelWindow)
            reelWindows.append(reelWindow)
            reelContainers.append(reelContainer)
            reelIconViews.append(iconView)
            reelLockedStates.append(false)
        }

        leverTrackView.translatesAutoresizingMaskIntoConstraints = false
        leverTrackView.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        leverTrackView.layer.cornerRadius = 8
        machineView.addSubview(leverTrackView)

        leverKnobView.translatesAutoresizingMaskIntoConstraints = false
        leverKnobView.backgroundColor = UIColor(red: 1.0, green: 0.50, blue: 0.29, alpha: 1.0)
        leverKnobView.layer.cornerRadius = 22
        leverKnobView.layer.shadowColor = UIColor.black.cgColor
        leverKnobView.layer.shadowOpacity = 0.26
        leverKnobView.layer.shadowRadius = 10
        leverKnobView.layer.shadowOffset = CGSize(width: 0, height: 6)
        machineView.addSubview(leverKnobView)

        NSLayoutConstraint.activate([
            backdropView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backdropView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backdropView.topAnchor.constraint(equalTo: topAnchor),
            backdropView.bottomAnchor.constraint(equalTo: bottomAnchor),

            flashView.leadingAnchor.constraint(equalTo: leadingAnchor),
            flashView.trailingAnchor.constraint(equalTo: trailingAnchor),
            flashView.topAnchor.constraint(equalTo: topAnchor),
            flashView.bottomAnchor.constraint(equalTo: bottomAnchor),

            glowView.centerXAnchor.constraint(equalTo: centerXAnchor),
            glowView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            glowView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.82),
            glowView.heightAnchor.constraint(equalTo: glowView.widthAnchor),

            machineView.centerXAnchor.constraint(equalTo: centerXAnchor),
            machineView.centerYAnchor.constraint(equalTo: centerYAnchor),
            machineView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.76),
            machineView.widthAnchor.constraint(lessThanOrEqualToConstant: 600),
            machineView.heightAnchor.constraint(equalTo: machineView.widthAnchor, multiplier: 0.92),

            titleLabel.topAnchor.constraint(equalTo: machineView.topAnchor, constant: 26),
            titleLabel.centerXAnchor.constraint(equalTo: machineView.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: machineView.centerXAnchor),

            reelsStackView.leadingAnchor.constraint(equalTo: machineView.leadingAnchor, constant: 26),
            reelsStackView.trailingAnchor.constraint(equalTo: machineView.trailingAnchor, constant: -56),
            reelsStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 26),
            reelsStackView.heightAnchor.constraint(equalTo: machineView.heightAnchor, multiplier: 0.42),

            leverTrackView.trailingAnchor.constraint(equalTo: machineView.trailingAnchor, constant: -18),
            leverTrackView.centerYAnchor.constraint(equalTo: reelsStackView.centerYAnchor),
            leverTrackView.widthAnchor.constraint(equalToConstant: 14),
            leverTrackView.heightAnchor.constraint(equalTo: reelsStackView.heightAnchor, multiplier: 0.9),

            leverKnobView.centerXAnchor.constraint(equalTo: leverTrackView.centerXAnchor),
            leverKnobView.topAnchor.constraint(equalTo: leverTrackView.topAnchor, constant: -2),
            leverKnobView.widthAnchor.constraint(equalToConstant: 44),
            leverKnobView.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func resetState() {
        cancelScheduledWork()
        alpha = 1.0
        flashView.alpha = 0.0
        glowView.alpha = 0.0
        machineView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        machineView.alpha = 0.0
        subtitleLabel.text = "Three reels. One fate."
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.62)

        for (index, iconView) in reelIconViews.enumerated() {
            reelLockedStates[index] = false
            iconView.layer.removeAllAnimations()
            iconView.transform = .identity
            iconView.alpha = 0.94
            iconView.tintColor = neutralColor(for: index)
            iconView.image = UIImage(systemName: "star.fill")
            iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 46, weight: .bold)
            reelWindows[index].layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        }

        leverKnobView.layer.removeAllAnimations()
        leverKnobView.transform = .identity
    }

    private func runSequence() {
        UIView.animate(withDuration: 0.42, delay: 0.0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.65) {
            self.machineView.transform = .identity
            self.machineView.alpha = 1.0
            self.glowView.alpha = 0.7
        }

        animateLeverPull()
        startSpinLoop()
        subtitleLabel.text = "Reels are slowing…"
        scheduleReveal(for: 0, at: 4.0)
        scheduleReveal(for: 1, at: 4.7)
        scheduleReveal(for: 2, at: 5.35)
        scheduleFinish(at: 7.35)
    }

    private func animateLeverPull() {
        UIView.animateKeyframes(withDuration: 0.9, delay: 0.0) {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.45) {
                self.leverKnobView.transform = CGAffineTransform(translationX: 0, y: 84)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.45, relativeDuration: 0.55) {
                self.leverKnobView.transform = .identity
            }
        }
    }

    private func startSpinLoop() {
        for index in 0..<reelIconViews.count {
            scheduleSpinStep(for: index, step: 0, startDelay: Double(index) * 0.08)
            startContinuousRotation(for: reelIconViews[index], duration: 0.34 + Double(index) * 0.04)
        }
    }

    private func scheduleSpinStep(for index: Int, step: Int, startDelay: TimeInterval) {
        guard !reelLockedStates[index] else { return }
        let maxSpinDuration: TimeInterval = 4.95
        let deadline = startDelay + cumulativeDelay(for: step)
        guard deadline < maxSpinDuration else { return }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, !self.reelLockedStates[index] else { return }
            self.animateSpinStep(for: index, step: step)
            self.scheduleSpinStep(for: index, step: step + 1, startDelay: startDelay)
        }
        spinWorkItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: workItem)
    }

    private func cumulativeDelay(for step: Int) -> TimeInterval {
        var total: TimeInterval = 0
        for current in 0..<step {
            total += spinInterval(for: current)
        }
        return total
    }

    private func spinInterval(for step: Int) -> TimeInterval {
        let progress = min(Double(step) / 20.0, 1.0)
        return 0.09 + (progress * 0.09)
    }

    private func animateSpinStep(for index: Int, step: Int) {
        guard !reelLockedStates[index] else { return }
        let iconView = reelIconViews[index]
        let reelWindow = reelWindows[index]
        let symbolName = "star.fill"
        let tint = spinTintColor(step: step, reel: index)

        UIView.transition(with: iconView, duration: 0.14, options: [.transitionFlipFromTop, .curveEaseInOut]) {
            iconView.image = UIImage(systemName: symbolName)
            iconView.tintColor = tint
            iconView.transform = CGAffineTransform(scaleX: 0.9, y: 1.12)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                iconView.transform = .identity
            }
        }

        UIView.animate(withDuration: 0.16) {
            reelWindow.layer.borderColor = tint.withAlphaComponent(0.34).cgColor
        }
    }

    private func scheduleReveal(for index: Int, at delay: TimeInterval) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.revealReel(at: index)
        }
        spinWorkItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func revealReel(at index: Int) {
        guard index < reelIconViews.count else { return }
        guard !reelLockedStates[index] else { return }

        let iconView = reelIconViews[index]
        let reelWindow = reelWindows[index]
        let outcome = reelOutcome(for: index)
        let isWinningStar = outcome == .star
        let tint = isWinningStar ? finalColor() : UIColor.white.withAlphaComponent(0.42)
        let symbolName = isWinningStar ? "star.fill" : "xmark"
        let borderColor = isWinningStar ? finalGlowColor().withAlphaComponent(0.76) : UIColor.white.withAlphaComponent(0.16)

        reelLockedStates[index] = true
        iconView.layer.removeAllAnimations()
        selectionFeedback.selectionChanged()
        if index == 0 || index == finalStars - 1 || (finalStars == 1 && index == 0) {
            mediumImpact.impactOccurred(intensity: 0.84)
        }

        UIView.transition(with: iconView, duration: 0.34, options: [.transitionFlipFromTop, .curveEaseOut]) {
            iconView.image = UIImage(systemName: symbolName)
            iconView.tintColor = tint
            iconView.alpha = isWinningStar ? 1.0 : 0.75
            iconView.transform = isWinningStar ? CGAffineTransform(scaleX: 1.12, y: 1.12) : .identity
            reelWindow.layer.borderColor = borderColor.cgColor
        } completion: { _ in
            UIView.animate(withDuration: 0.18) {
                iconView.transform = .identity
            }
        }

        if isWinningStar {
            flashView.backgroundColor = finalGlowColor().withAlphaComponent(0.9)
            UIView.animate(withDuration: 0.08, animations: {
                self.flashView.alpha = 0.12
                self.glowView.backgroundColor = self.finalGlowColor().withAlphaComponent(0.30)
            }) { _ in
                UIView.animate(withDuration: 0.18) {
                    self.flashView.alpha = 0.0
                }
            }
        }

        if index == 2 {
            subtitleLabel.text = finalSubtitle()
            subtitleLabel.textColor = finalGlowColor().withAlphaComponent(0.86)
            heavyImpact.impactOccurred(intensity: finalStars == 3 ? 1.0 : 0.82)
        }
    }

    private func scheduleFinish(at delay: TimeInterval) {
        let workItem = DispatchWorkItem { [weak self] in
            self?.finishSequence()
        }
        spinWorkItems.append(workItem)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func finishSequence() {
        UIView.animate(withDuration: 0.26, animations: {
            self.alpha = 0.0
        }) { _ in
            self.completion?()
        }
    }

    private func cancelScheduledWork() {
        spinWorkItems.forEach { $0.cancel() }
        spinWorkItems.removeAll()
    }

    private func startContinuousRotation(for view: UIView, duration: TimeInterval) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = 0
        rotation.toValue = Double.pi * 2
        rotation.duration = duration
        rotation.repeatCount = .infinity
        rotation.timingFunction = CAMediaTimingFunction(name: .linear)
        view.layer.add(rotation, forKey: "slot-rotation")
    }

    private func neutralColor(for index: Int) -> UIColor {
        let colors = [
            UIColor(red: 0.92, green: 0.96, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.76, green: 0.84, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.87, green: 0.90, blue: 1.0, alpha: 1.0)
        ]
        return colors[index % colors.count]
    }

    private func spinTintColor(step: Int, reel: Int) -> UIColor {
        let hues = [
            UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0),
            UIColor(red: 1.0, green: 0.83, blue: 0.34, alpha: 1.0),
            UIColor(red: 0.74, green: 0.60, blue: 1.0, alpha: 1.0)
        ]
        return hues[(step + reel) % hues.count]
    }

    private func reelOutcome(for index: Int) -> ReelOutcome {
        index < finalStars ? .star : .miss
    }

    private func finalColor() -> UIColor {
        switch finalStars {
        case 1:
            return UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0)
        case 2:
            return UIColor(red: 1.0, green: 0.83, blue: 0.34, alpha: 1.0)
        default:
            return UIColor(red: 0.74, green: 0.60, blue: 1.0, alpha: 1.0)
        }
    }

    private func finalGlowColor() -> UIColor {
        switch finalStars {
        case 1:
            return UIColor(red: 0.74, green: 0.86, blue: 1.0, alpha: 1.0)
        case 2:
            return UIColor(red: 1.0, green: 0.76, blue: 0.22, alpha: 1.0)
        default:
            return UIColor(red: 0.58, green: 0.36, blue: 0.95, alpha: 1.0)
        }
    }

    private func finalSubtitle() -> String {
        switch finalStars {
        case 1:
            return "One star. Two misses."
        case 2:
            return "Two stars. One miss."
        default:
            return "Three-star jackpot."
        }
    }

    private func prepareHaptics() {
        heavyImpact.prepare()
        mediumImpact.prepare()
        selectionFeedback.prepare()
    }
}
