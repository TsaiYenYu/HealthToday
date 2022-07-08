//
//  WalkBarChartViewController.swift
//  TodayHealth
//
//  Created by user on 2022/7/7.
//
//todo com.apple.developer.healthkit entitlement

import UIKit

enum TimeUnit {
    case day
    case week
    case month
}

class WalkingBarChartViewController: UIViewController {
    
    static func new(with viewModel: WalkingBarChartViewModel) -> WalkingBarChartViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalkingBarChartViewController") as! WalkingBarChartViewController
        vc.viewModel = viewModel
        return vc
    }
    
    var viewModel: WalkingBarChartViewModel! = WalkingBarChartViewModel()
    
    @IBOutlet weak var scrollStackView: ScrollingStackView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayUnderLineView: UIView!
    @IBOutlet weak var weekUnderLineView: UIView!
    @IBOutlet weak var monthUnderLineView: UIView!
    private var timeSelectView: TimeSelectView!
    private var mainCountView: MainCountView!
    private var chartBarCardView: ChartBarCardView!
    private var timeLocaCalorInfoCardView: TimeLocaCalorInfoCardView!
    private var totalTimeLocaCalorInfoCardView: TotalTimeLocaCalorInfoCardView!
    private var footView: UIView!

    lazy var topSelectTimeUnitList: [(TimeUnit, UILabel, UIView)] = [
        (.day, dayLabel, dayUnderLineView),
        (.week, weekLabel, weekUnderLineView),
        (.month, monthLabel, monthUnderLineView),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        HealthKitManager.current.authorizeHealthKit {
            switch $0 {
            case .success(let bool):
                if bool {
                    self.onClickDay()
                } else {

                }
            case .failure(let err):
                print(err.localizedDescription)
                guard let url = URL(string: "App-Prefs:root=HealthKit") else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            
        }
    }
    
    private func setupUI() {

        setupTitleTimeUnit()
        setupScrollStackView()
        insertBackGroundColorView()
        setupStackView()
        scrollStackView.scrollView.layoutIfNeeded()
        scrollStackView.stackView.layoutIfNeeded()
        scrollStackView.layoutIfNeeded()
    }
    
    private func setupTitleTimeUnit() {
        topSelectTimeUnitList.forEach {
            $0.1.textColor = .systemBlue
            $0.1.isUserInteractionEnabled = true
            $0.2.backgroundColor = .clear
        }
        let tapDay = UITapGestureRecognizer(target: self, action: #selector(onClickDay))
        dayLabel.addGestureRecognizer(tapDay)
        let tapWeek = UITapGestureRecognizer(target: self, action: #selector(onClickWeek))
        weekLabel.addGestureRecognizer(tapWeek)
        let tapMonth = UITapGestureRecognizer(target: self, action: #selector(onClickMonth))
        monthLabel.addGestureRecognizer(tapMonth)
    }
    
    private func setupScrollStackView() {
        scrollStackView.do {
            $0.axis = .vertical
            $0.topConstraint = 0
            $0.spacing = 16
            $0.scrollView.bounces = false
        }
    }
    
    private func insertBackGroundColorView() {
        let bgwhite = UIView()
        bgwhite.translatesAutoresizingMaskIntoConstraints = false
        bgwhite.backgroundColor = .white
        scrollStackView.scrollView.addSubview(bgwhite)
        scrollStackView.scrollView.sendSubviewToBack(bgwhite)
        bgwhite.topAnchor.constraint(equalTo: scrollStackView.scrollView.topAnchor).isActive = true
        bgwhite.heightAnchor.constraint(equalToConstant: 280).isActive = true
        bgwhite.widthAnchor.constraint(equalTo: scrollStackView.scrollView.frameLayoutGuide.widthAnchor).isActive = true
    }

    private func setupStackView() {
        let sepView = UIView()
        sepView.backgroundColor = .clear
        
        //viewModel -> vc -> v
        timeSelectView = TimeSelectView.new(with: "")
        timeSelectView.onNext = { [weak self] in
            guard let self = self else { return }
            self.viewModel.onNextDate()
        }
        timeSelectView.onLast = { [weak self] in
            guard let self = self else { return }
            self.viewModel.onLastDate()
        }

        mainCountView = MainCountView.new(with: "")
        
        chartBarCardView = ChartBarCardView.new(with: "")
        
        timeLocaCalorInfoCardView = TimeLocaCalorInfoCardView.new(with: "")
        
        totalTimeLocaCalorInfoCardView = TotalTimeLocaCalorInfoCardView.new(with: "")
        
        footView = UIView()
        
        NSLayoutConstraint.activate([
            sepView.heightAnchor.constraint(equalToConstant: 1),
            timeSelectView.heightAnchor.constraint(equalToConstant: 40),
            mainCountView.heightAnchor.constraint(equalToConstant: 144),
            chartBarCardView.heightAnchor.constraint(equalToConstant: 250),
            timeLocaCalorInfoCardView.heightAnchor.constraint(equalToConstant: 150),
            totalTimeLocaCalorInfoCardView.heightAnchor.constraint(equalToConstant: 150),
            footView.heightAnchor.constraint(equalToConstant: 40),
        ])
        scrollStackView.stackView.addArrangedSubview(sepView)
        scrollStackView.stackView.addArrangedSubview(timeSelectView)
        scrollStackView.stackView.addArrangedSubview(mainCountView)
        scrollStackView.stackView.addArrangedSubview(chartBarCardView)
        scrollStackView.stackView.addArrangedSubview(timeLocaCalorInfoCardView)
        scrollStackView.stackView.addArrangedSubview(totalTimeLocaCalorInfoCardView)
        scrollStackView.stackView.addArrangedSubview(footView)
    }
    
    private func setupViewModel() {
        viewModel.onSelectDate = { [weak self] dateString in
            guard let self = self else { return }
            self.timeSelectView.displayTimeLabel.text = dateString
        }
        viewModel.onMainCount = { [weak self] countString in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.mainCountView.countLabel.text = countString
            }
        }
        
        viewModel.onWalkLocCalCard = { [weak self] (timeStirng, distanceString, calString, type) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.timeLocaCalorInfoCardView.updateUI(type: type,
                                                        timeSting: timeStirng,
                                                        distanceString: distanceString,
                                                        calString: calString)            }
        }
        
        viewModel.onTotalWalkLocCalCard = { [weak self] (timeStirng, distanceString, calString, type) in
            guard let self = self else { return }
            DispatchQueue.main.async {
            self.totalTimeLocaCalorInfoCardView.updateUI(type: type,
                                                    timeSting: timeStirng,
                                                    distanceString: distanceString,
                                                    calString: calString)
            }
        }
       
        viewModel.onChartDate = { [weak self] (chartData, aXisStringList) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.chartBarCardView.setupChartData(dataList: chartData, xAxisList: aXisStringList)
            }
        }
    }
    
    //MARK:: 點擊 日 周 月 事件
    private func updateTopTimeLabel(timeUint: TimeUnit) {
        topSelectTimeUnitList.forEach {
            if timeUint == $0.0 {
                $0.1.textColor = .black
                $0.2.backgroundColor = .systemBlue
            } else {
                $0.1.textColor = .lightGray
                $0.2.backgroundColor = .clear
            }
        }
    }
    
    @objc func onClickDay() {
        self.updateTopTimeLabel(timeUint: .day)
        viewModel.selectTimeUnit(type: .day)
        totalTimeLocaCalorInfoCardView.isHidden = true
    }
    
    @objc func onClickWeek() {
        self.updateTopTimeLabel(timeUint: .week)
        viewModel.selectTimeUnit(type: .week)
        totalTimeLocaCalorInfoCardView.isHidden = false
    }
    
    @objc func onClickMonth() {
        self.updateTopTimeLabel(timeUint: .month)
        viewModel.selectTimeUnit(type: .month)
        totalTimeLocaCalorInfoCardView.isHidden = false
    }
}


extension UIViewController {
    func showWalkBarChart() {
        let vc = WalkingBarChartViewController.new(with: WalkingBarChartViewModel())
        vc.modalTransitionStyle = .partialCurl
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
    }
}
