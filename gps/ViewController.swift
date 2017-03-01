//
//  ViewController.swift
//  gps
//
//  Created by 任思燕 on 17/2/24.
//  Copyright © 2017年 陈伟麟. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate{
    var locationManager : CLLocationManager!
    var longitude:Double = 0.0       //存放从gps取出的经纬度、高度、方向、速度
    var latitude:Double = 0.0
    var speed:Double = 0.0
    var altidue:Double = 0.0
    var angle:Double = 0
    var range:Double? = 30         //存放从输入框取到的用户设定的距离范围，默认为30
    var time = Timer()            //计时器对象
    var selectedsite = [String]()        //满足范围条件的站点列表、距离、方位角
    var selecteddistance = [Double]()
    var selectedangle = [Double]()
    var bool:Bool = true                 //switch开关的状态
    var sitegps = [String:[Double]]()      //预置站点的经纬度
    func getsitegps(){                     //从site dict.swift中取预置站点的经纬度，存放在字典中
    if bool {sitegps = sitegps1}
    else{sitegps = sitegps2}}             //两个来源的经纬度信息，通过switch开关决定用哪一个
    var currlocation = CLLocation()
    func modeswitch(){                 //切换switch开关，更改bool的值
        bool = !bool
    }
    
    func getrange() {                 //从输入框取距离范围的方法
        let rangegettext = self.view.viewWithTag(103) as? UITextField
        let siteshow = self.view.viewWithTag(102) as? UITextView
        let t = rangegettext?.text
        if t == nil{
            self.range = 30
        }
        else {
            self.range = Double(t!)
        }
        print(self.range as Any)
        rangegettext?.resignFirstResponder()
        siteshow?.text = ""
        
    }
                     //从gps取位置信息的方法
    func locationManager(_ manager: CLLocationManager,didUpdateLocations locations: [CLLocation]){
        print("定位真的开始了")
        currlocation = locations.last!
       
        //从手机gps取5个参数
        self.altidue = currlocation.altitude
        self.latitude = Float64(currlocation.coordinate.latitude)
        self.longitude = Float64(currlocation.coordinate.longitude)
        self.speed = Float64(currlocation.speed)*3.6
        if self.speed == -3.6{self.speed = 0}
        self.angle = Float64(currlocation.course)

    }
    func getsiteinrange ()  {       //将预置的经纬度和取出的参数进行对比，将符合条件的地点存在数组中
        selectedsite.removeAll()        //此方法每秒执行一次，执行前需要先清空上一次结果
        selectedangle.removeAll()
        selecteddistance.removeAll()
         var i = 0
        getsitegps()
        for (site,gps) in sitegps{
            let tolocation = CLLocation(latitude: gps[1], longitude: gps[0])
            var distance:Double = 0
            
            //调用compute.swift中的方法计算距离
            distance = calcdistance(fromLongitude: self.longitude, fromLatitude: self.latitude, toLongitude: tolocation.coordinate.longitude, toLatitude: tolocation.coordinate.latitude)
            
            //调用gps自带的方法计算距离
            //distance = currlocation.distance(from: tolocation)/1000
            
            //调用compute.swift中的方法计算角度
            let angle = calcangle(fromLongitude: self.longitude, fromLatitude: self.latitude, toLongitude: tolocation.coordinate.longitude, toLatitude: tolocation.coordinate.latitude)
            if (distance <= range!){     //满足条件的站点，存入数组
                self.selectedsite.append(site)
                self.selectedangle.append(angle)
                self.selecteddistance.append(distance)
                i += 1
            }

        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager = CLLocationManager()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters   //设置精度
        self.locationManager.distanceFilter = 10
        if #available(iOS 8.0, *){                       //获得授权
        self.locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled(){
        self.locationManager.startUpdatingLocation()
        print("定位开始")
        }
        else {print("未开启定位")
        }
        
        let currentspeedlabel = UILabel(frame: CGRect(x: 30, y: 30, width: view.frame.width-40 , height: 60))
        //currentspeedlabel.backgroundColor = UIColor.blue
        currentspeedlabel.font = UIFont.boldSystemFont(ofSize: 15)
        currentspeedlabel.tag = 101
        currentspeedlabel.numberOfLines = 4
        
        currentspeedlabel.text = "当前速度为  \(speed)km/h\n方向为  \(self.angle)度（0度为正北）\n当前位置：\(self.longitude)\n       \(self.latitude)"
        currentspeedlabel.textColor = UIColor.black
        currentspeedlabel.textAlignment = NSTextAlignment.left
        
        self.view.addSubview(currentspeedlabel)
        
        let rangetext = UILabel()
        rangetext.text = "范围距离为：(公里)"
        rangetext.font = UIFont.boldSystemFont(ofSize: 15)
        rangetext.frame = CGRect(x: 30, y: 90, width: 200, height: 25)
        //rangetext.backgroundColor = UIColor.green
        self.view.addSubview(rangetext)
        
        let rangeget = UITextField()
        rangeget.frame = CGRect(x: 180, y:90, width: 70, height: 25)
        rangeget.tag = 103
        rangeget.borderStyle = UITextBorderStyle.bezel
        //rangeget.backgroundColor = UIColor.lightGray
        //rangeget.keyboardType = UIKeyboardType.numberPad
        rangeget.text = "30"
        rangeget.clearsOnBeginEditing = true
        rangeget.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        rangeget.clearButtonMode = UITextFieldViewMode.whileEditing
        rangeget.returnKeyType = UIReturnKeyType.done
        rangeget.delegate = self
        self.view.addSubview(rangeget)
        rangeget.didChangeValue(forKey: rangeget.text!)
        
        let button = UIButton()
        button.frame = CGRect(x: 250, y: 90, width: view.frame.width-280, height: 25)
        button.backgroundColor = UIColor.black
        button.setTitle("确定", for:.normal)
        button.addTarget(self, action: #selector(self.getrange), for: .touchUpInside)
        self.view.addSubview(button)
        
 

        
        let distancetext = UILabel()
        distancetext.text = "附近的站点有："
        distancetext.frame = CGRect(x: 30, y:120, width: view.frame.width-60, height: 30)
        distancetext.backgroundColor = UIColor.darkGray
        distancetext.textAlignment = NSTextAlignment.center
        distancetext.textColor = UIColor.white
        distancetext.font = UIFont.boldSystemFont(ofSize: 18)
        self.view.addSubview(distancetext)
        
        
        
        let siteshow = UITextView()
        siteshow.backgroundColor = UIColor.gray
        siteshow.tag = 102
        siteshow.font = UIFont.boldSystemFont(ofSize: 14)
        siteshow.frame = CGRect(x: 30 , y: 150, width: view.frame.width-60, height: view.frame.height-180)
        siteshow.isEditable = false
        self.view.addSubview(siteshow)
        
        
        
        
        let addsite = UIButton()
        addsite.setTitle("添加站点经纬度", for: UIControlState.normal)

        let mode = UISwitch()
        mode.addTarget(self, action: #selector(modeswitch), for: UIControlEvents.valueChanged)
        mode.frame = CGRect(x: view.frame.width-80, y: 35, width: 30, height: 10)
        self.view.addSubview(mode)
        

        // 定时器对象，每秒执行一次，调用timerfiremethod函数

        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.timerfiremethod), userInfo: nil, repeats: true)
            timer.fire()
     

    }
    
    func timerfiremethod(){
       getsiteinrange()      //获取满足范围的站点列表
        
        let currentspeedlabel = self.view.viewWithTag(101) as? UILabel       //找到之前定义好的输出框
        let siteshow = self.view.viewWithTag(102) as? UITextView
        let speed = round(self.speed*100)/100
        let angle = round(self.angle*100)/100
        let longitude = round(self.longitude*1000000)/1000000
        let latitude = round(self.latitude*1000000)/1000000
        if angle == -1 {
        currentspeedlabel?.text = "当前速度为  \(speed)   km/h\n方向:          （0度为正北）\n当前位置：\(longitude)  \(latitude)"
        }
        else{
        currentspeedlabel?.text = "当前速度为  \(speed)   km/h\n方向为   \(angle)   度（0度为正北）\n当前位置：\(longitude)  \(latitude)"
        }


        
        //定义一个最终输入的字符串
        var selectedsitearray = ""
        var m:Double = 0
        var n:String = ""
        
        if selectedsite.count > 1{
        for i in 1...selectedsite.count-1
        {for j in 0...selectedsite.count-1-i
            
        {
            if selecteddistance[j] > selecteddistance[j+1]
           {m = selecteddistance[j]
            selecteddistance[j] = selecteddistance[j+1]
            selecteddistance[j+1] = m
            m = selectedangle[j]
            selectedangle[j] = selectedangle[j+1]
            selectedangle[j+1] = m
            n = selectedsite[j]
            selectedsite[j] = selectedsite[j+1]
            selectedsite[j+1] = n
            }
          }
        }
        }
        
        if selectedsite.count == 1{
            let anglesort = String(Float(lround(selectedangle[0]*100))/100)
            let sitesort = String(selectedsite[0])
            let distancesort = String(Float(lround(selecteddistance[0]*100))/100)
            selectedsitearray = sitesort! + ":" + distancesort + "公里  " + "  方位角:" + anglesort + "\n"
        }
        if selectedsite.count > 1{
            let anglesort = String(Float(lround(selectedangle[0]*100))/100)
            let sitesort = String(selectedsite[0])
            let distancesort = String(Float(lround(selecteddistance[0]*100))/100)
            selectedsitearray = sitesort! + ":" + distancesort + "公里  " + "  方位角:" + anglesort + "\n"
            //print(selectedsitearray)
            for i in 1...selectedsite.count-1 {
            let anglesort = String(Float(lround(selectedangle[i]*100))/100)
            let sitesort = String(selectedsite[i])
            let distancesort = String(Float(lround(selecteddistance[i]*100))/100)
            selectedsitearray += sitesort! + ":" + distancesort + "公里  " + "  方位角:" + anglesort + "\n"
                //print(selectedsitearray)
        }
        }

        siteshow?.text = selectedsitearray
        self.view.addSubview(siteshow!)
        self.view.addSubview(currentspeedlabel!)
        
        //print(self.latitude)
        //print(self.angel)
        //print(self.speed)
    
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        

        // Dispose of any resources that can be recreated.
    }



}

