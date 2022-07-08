//
//  ChartBarCardView.swift
//  customer
//
//  Created by user on 2022/6/29.
//  Copyright © 2022 Chinalife. All rights reserved.
//

import UIKit
import Charts

class ChartBarCardView: UIView {
    
    static func new(with: String = "") -> ChartBarCardView  {
        let view = Bundle.main.loadNibNamed("ChartBarCardView", owner: self, options: nil)?.first as! ChartBarCardView
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    let specHeight: CGFloat = 90.0
    
    @IBOutlet weak var cardView: UIView!
    
    private var clBarchartView: BarChartView!
    private var connectView = UIView()
    var stringList: [String] = []
    var dataEntries: [BarChartDataEntry] = []
    
    private var circleSpecView: CircleSpecView!
    
    private func setupUI() {
        backgroundColor = .clear
        cardView.makeRadius(radius: 10)
        cardView.addShadow(width: 0, height: 0.5, color: .lightGray, opacity: 0.3, radius: 1)
        clBarchartView = BarChartView()
        
        clBarchartView.delegate = self
        clBarchartView.drawBarShadowEnabled = false
        clBarchartView.drawValueAboveBarEnabled = false
        clBarchartView.maxVisibleCount = 60
        clBarchartView.legend.enabled = false
        setChartXAxis()
        setChartYAxis()
        setChartGrid()
        setChartZoom()
        cardView.fill(with: clBarchartView, insets: UIEdgeInsets(top: 5, left: 8, bottom: 8, right: 8))
        cardView.layoutIfNeeded()
        
        circleSpecView = CircleSpecView.new().then {
            $0.makeBorder(borderColor: .systemBlue, borderWidth: 0.5)
            $0.backgroundColor = .white
            $0.makeRadius(radius: specHeight / 2 )
            $0.addShadow(width: 0.5, height: 0.5, color: .lightGray, opacity: 0.3, radius: 0.5)
        }
        circleSpecView.isHidden = true
        clBarchartView.addSubview(circleSpecView)
        
        clBarchartView.addSubview(connectView)
    }
    
    //MARK:: 設定x軸功能
    private func setChartXAxis() {
        let xAxis = clBarchartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 12)
        xAxis.gridColor = .clear
        xAxis.granularity = 1
        xAxis.axisLineColor = .clear
    }
    
    //MARK:: 設定y軸功能
    private func setChartYAxis() {
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        leftAxisFormatter.negativeSuffix = ""
        leftAxisFormatter.positiveSuffix = ""
        
        clBarchartView.leftAxis.drawAxisLineEnabled = false
        let leftAxis = clBarchartView.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 0)
        leftAxis.labelCount = 0
        leftAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        leftAxis.axisLineColor = .systemBlue
        
        clBarchartView.rightAxis.drawAxisLineEnabled = true
        let rightAxis = clBarchartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = .systemFont(ofSize: 8)
        rightAxis.labelTextColor = .systemBlue
        //强制绘制制定数量的label
        //        rightAxis.forceLabelsEnabled = true
        //是否将Y轴进行上下翻转
        leftAxis.inverted = false
        rightAxis.valueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        rightAxis.axisMinimum = 0
        rightAxis.axisLineColor = .systemBlue
    }
    
    //MARK:: 禁止縮放功能
    private func setChartZoom() {
        clBarchartView.doubleTapToZoomEnabled = false
        clBarchartView.dragEnabled = false
        clBarchartView.scaleYEnabled = false
        clBarchartView.pinchZoomEnabled = false
        clBarchartView.setScaleEnabled(false)
    }
    
    //MARK:: 背後網格線
    private func setChartGrid() {
        clBarchartView.drawGridBackgroundEnabled = false
        clBarchartView.xAxis.gridColor = .clear
        clBarchartView.xAxis.drawGridLinesEnabled = false
        clBarchartView.rightAxis.drawGridLinesEnabled = false
        clBarchartView.leftAxis.drawGridLinesEnabled = false
    }
    
    func setupChartData(dataList: [BarChartDataEntry], xAxisList: [String]) {
        circleSpecView.isHidden = true
        connectView.isHidden = true
        stringList = xAxisList
        dataEntries = dataList
        
        //不指定labelCount可能會消失
        clBarchartView.xAxis.labelCount = stringList.count
//        clBarchartView.xAxis.drawAxisLineEnabled = true
        clBarchartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: stringList)
        //dataSet
        var dataSet: BarChartDataSet! = nil
        dataSet = BarChartDataSet(entries: dataEntries, label: "")
        dataSet.colors = [.systemBlue]
        dataSet.drawValuesEnabled = false
        dataSet.highlightColor = .systemBlue
        //封裝data
        let data = BarChartData(dataSet: dataSet)
        data.setValueFont(UIFont.systemFont(ofSize: 8))
        data.barWidth = 0.5
        clBarchartView.data = data
        self.clBarchartView.data?.notifyDataChanged()
        self.clBarchartView.notifyDataSetChanged()
        //塞完資料 才能下動畫 不然會閃退
        clBarchartView.animate(yAxisDuration: 0.5, easingOption: .easeInOutBack)
    }
}


extension ChartBarCardView: ChartViewDelegate {
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if entry.y == 0 { return }
        circleSpecView.isHidden = false
        circleSpecView.frame.size = CGSize(width: 0, height:0)
        connectView.isHidden = false
        connectView.frame.size = CGSize(width: 0, height:0)
        
        let dataFromEntry = (entry.data) as! String
        //第一個日期 在二個count
        let size = CGSize(width: specHeight, height: specHeight)
        var adjustCenter = highlight.xPx - (specHeight/2)
        if (adjustCenter) <  -30  {
            adjustCenter =  -20
        }
        let specCenter = CGPoint(x: adjustCenter, y: -60)
        circleSpecView.center = specCenter
        
        circleSpecView.frame.size = size
        circleSpecView.updateUI(dateString: dataFromEntry, count: String(entry.y.decimalString()))
        
        let lowPoint = CGPoint(x: highlight.xPx,
                               y: highlight.yPx)
        let calHeight = circleSpecView.frame.maxY - highlight.yPx
        let calSize = CGSize(width: 1, height: calHeight)
        connectView.frame = CGRect(origin: lowPoint,
                                   size: calSize)
        connectView.backgroundColor = .systemBlue
        //        print("high.xPx: \(highlight.xPx)")
        //        print("high.x: \(highlight.x)")
        //        print("high.yPx: \(highlight.yPx)")
        //        print("high.y: \(highlight.y)")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        circleSpecView.isHidden = false
        circleSpecView.frame.size = CGSize(width: 0, height:0)
        connectView.isHidden = false
        connectView.frame.size = CGSize(width: 0, height:0)
    }
    
    func chartScaled(_ chartView: ChartViewBase, scaleX: CGFloat, scaleY: CGFloat) {
        
    }
    
    func chartTranslated(_ chartView: ChartViewBase, dX: CGFloat, dY: CGFloat) {
        
    }
}
