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
    
    func addsite(){
        let newsite = self.view.viewWithTag(111) as? UITextField
        let newlong = self.view.viewWithTag(112) as? UITextField
        let newlat = self.view.viewWithTag(113) as? UITextField

        
        
        
        
    }
    
    func deletesite(){
        let deletesite = self.view.viewWithTag(114) as? UITextField
    }
    
    func showsites(){
        let scroll = self.view.viewWithTag(104) as? UIScrollView
        let showsitelist = self.view.viewWithTag(121) as? UITextView
        
        //scroll?.addSubview(showsitelist!)
        
    
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
        
        let scroll = UIScrollView()
        scroll.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scroll.isScrollEnabled = true
        scroll.isPagingEnabled = true
        scroll.contentSize = CGSize.init(width: view.frame.width*3, height: view.frame.height)
        scroll.bounces = true
        scroll.alwaysBounceHorizontal = true
        scroll.showsHorizontalScrollIndicator = true
        scroll.tag = 104
        self.view.addSubview(scroll)
        
        
        
        let currentspeedlabel = UILabel(frame: CGRect(x: 30, y: 25, width: view.frame.width-40 , height: 75))
        //currentspeedlabel.backgroundColor = UIColor.blue
        currentspeedlabel.font = UIFont.boldSystemFont(ofSize: 15)
        currentspeedlabel.tag = 101
        currentspeedlabel.numberOfLines = 4
        
        currentspeedlabel.text = "当前速度为  \(speed)km/h\n方向：  \(self.angle)度  海拔：   \(self.altidue)\n当前位置：\(self.longitude)\n       \(self.latitude)"
        currentspeedlabel.textColor = UIColor.black
        currentspeedlabel.textAlignment = NSTextAlignment.left
        
        scroll.addSubview(currentspeedlabel)
        
        let rangetext = UILabel()
        rangetext.text = "范围距离为：(公里)"
        rangetext.font = UIFont.boldSystemFont(ofSize: 15)
        rangetext.frame = CGRect(x: 30, y: 90, width: 200, height: 25)
        //rangetext.backgroundColor = UIColor.green
        scroll.addSubview(rangetext)
        
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
        scroll.addSubview(rangeget)
        //rangeget.didChangeValue(forKey: rangeget.text!)
        
        let button = UIButton()
        button.frame = CGRect(x: 250, y: 90, width: view.frame.width-280, height: 25)
        button.backgroundColor = UIColor.init(red: 0.18, green: 0.3, blue: 0.3, alpha: 1)
        button.setTitle("确定", for:.normal)
        button.addTarget(self, action: #selector(self.getrange), for: .touchUpInside)
        scroll.addSubview(button)
        
 

        
        let distancetext = UILabel()
        distancetext.text = "   附近的站点有："
        distancetext.frame = CGRect(x: 30, y:120, width: view.frame.width-60, height: 30)
        distancetext.backgroundColor = UIColor.init(red: 0.4, green: 0.54, blue: 0.54, alpha: 1)
        distancetext.textAlignment = NSTextAlignment.left
        distancetext.textColor = UIColor.white
        distancetext.font = UIFont.boldSystemFont(ofSize: 18)
        scroll.addSubview(distancetext)
        
        
        
        let siteshow = UITextView()
        siteshow.backgroundColor = UIColor.gray
        siteshow.tag = 102
        siteshow.font = UIFont.boldSystemFont(ofSize: 14)
        siteshow.frame = CGRect(x: 30 , y: 150, width: view.frame.width-60, height: view.frame.height-180)
        siteshow.isEditable = false
        scroll.addSubview(siteshow)
        
        
        let addsite = UILabel()
        addsite.text = "添加站点"
        addsite.frame = CGRect(x: view.frame.width, y: 20, width: view.frame.width, height: 30)
        addsite.font = UIFont.boldSystemFont(ofSize: 20)
        addsite.textAlignment = NSTextAlignment.center
        addsite.backgroundColor = UIColor.darkGray
        scroll.addSubview(addsite)
        
        let deletesite = UILabel()
        deletesite.text = "删除站点"
        deletesite.frame = CGRect(x: view.frame.width, y: 240, width: view.frame.width, height: 30)
        deletesite.font = UIFont.boldSystemFont(ofSize: 20)
        deletesite.textAlignment = NSTextAlignment.center
        deletesite.backgroundColor = UIColor.darkGray
        scroll.addSubview(deletesite)
        
        
        let sitename = UILabel()
        let long = UILabel()
        let lat = UILabel()
        let newsite = UITextField()
        let sitedeletelabel = UILabel()
        let sitedelete = UITextField()
        let newlongitude = UITextField()
        let newlatitude = UITextField()
        let newsiteconfirm = UIButton()
        let deletesiteconfirm = UIButton()
        sitename.frame = CGRect(x: view.frame.width+30, y: 60, width: 100, height: 30)
        sitename.text = "站点名称："
        sitename.font = UIFont.boldSystemFont(ofSize: 18)
        scroll.addSubview(sitename)
        
        sitedeletelabel.frame = CGRect(x: view.frame.width+30, y: 280, width: 100, height: 30)
        sitedeletelabel.text = "站点名称："
        sitedeletelabel.font = UIFont.boldSystemFont(ofSize: 18)
        scroll.addSubview(sitedeletelabel)
        
        long.frame = CGRect(x: view.frame.width+30, y: 95, width: 70, height: 30)
        long.text = "经度："
        long.font = UIFont.boldSystemFont(ofSize: 18)
        //long.backgroundColor = UIColor.gray
        
        scroll.addSubview(long)
        lat.frame = CGRect(x: view.frame.width+30, y: 130, width: 70, height: 30)
        lat.text = "纬度："
        lat.font = UIFont.boldSystemFont(ofSize: 18)
        //lat.backgroundColor = UIColor.gray
        scroll.addSubview(lat)
        
        newsite.frame = CGRect(x: view.frame.width+130, y: 60, width: view.frame.width-160, height: 30)
        newsite.tag = 111
        newsite.borderStyle = UITextBorderStyle.bezel
        newsite.clearsOnBeginEditing = true
        newsite.clearButtonMode = UITextFieldViewMode.whileEditing
        newsite.returnKeyType = UIReturnKeyType.done
        newsite.delegate = self
        scroll.addSubview(newsite)
        
        newlongitude.frame = CGRect(x: view.frame.width+100, y: 95, width: view.frame.width-130, height: 30)
        newlongitude.tag = 112
        newlongitude.borderStyle = UITextBorderStyle.bezel
        newlongitude.clearsOnBeginEditing = true
        newlongitude.clearButtonMode = UITextFieldViewMode.whileEditing
        newlongitude.returnKeyType = UIReturnKeyType.done
        newlongitude.delegate = self
        scroll.addSubview(newlongitude)
        
        newlatitude.frame = CGRect(x: view.frame.width+100, y: 130, width: view.frame.width-130, height: 30)
        newlatitude.tag = 113
        newlatitude.borderStyle = UITextBorderStyle.bezel
        newlatitude.clearsOnBeginEditing = true
        newlatitude.clearButtonMode = UITextFieldViewMode.whileEditing
        newlatitude.returnKeyType = UIReturnKeyType.done
        newlatitude.delegate = self
        scroll.addSubview(newlatitude)
        
        sitedelete.frame = CGRect(x: view.frame.width+130, y: 280, width: view.frame.width-160, height: 30)
        sitedelete.tag = 114
        sitedelete.borderStyle = UITextBorderStyle.bezel
        sitedelete.clearsOnBeginEditing = true
        sitedelete.clearButtonMode = UITextFieldViewMode.whileEditing
        sitedelete.returnKeyType = UIReturnKeyType.done
        sitedelete.delegate = self
        scroll.addSubview(sitedelete)
        
        newsiteconfirm.frame = CGRect(x: view.frame.width*1.5 - 30, y: 180, width: 60, height: 30)
        newsiteconfirm.backgroundColor = UIColor.init(red: 0.18, green: 0.3, blue: 0.3, alpha: 1)
        newsiteconfirm.setTitle("添加", for:.normal)
        newsiteconfirm.addTarget(self, action: #selector(self.addsite), for: .touchUpInside)
        scroll.addSubview(newsiteconfirm)
        
        deletesiteconfirm.frame = CGRect(x: view.frame.width*1.5 - 30, y: 330, width: 60, height: 30)
        deletesiteconfirm.backgroundColor = UIColor.init(red: 0.18, green: 0.3, blue: 0.3, alpha: 1)
        deletesiteconfirm.setTitle("删除", for:.normal)
        deletesiteconfirm.addTarget(self, action: #selector(self.deletesite), for: .touchUpInside)
        scroll.addSubview(deletesiteconfirm)
        
        let showsites = UIButton()
        showsites.frame = CGRect(x: view.frame.width*2, y: 20, width: view.frame.width, height: 30)
        showsites.backgroundColor = UIColor.init(red: 0.18, green: 0.3, blue: 0.3, alpha: 1)
        showsites.setTitle("显示所有站点", for:.normal)
        showsites.addTarget(self, action: #selector(self.showsites), for: .touchUpInside)
        scroll.addSubview(showsites)
        
       let showsitelist = UITextView()
        showsitelist.backgroundColor = UIColor.gray
        showsitelist.frame = CGRect(x: view.frame.width*2 + 20, y: 60, width: view.frame.width-40, height: view.frame.height-80)
        showsitelist.tag = 121
        showsitelist.font = UIFont.boldSystemFont(ofSize: 14)
        showsitelist.isEditable = false
         showsitelist.isEditable = false
        scroll.addSubview(showsitelist)
        
        let mode = UISwitch()
        mode.addTarget(self, action: #selector(modeswitch), for: UIControlEvents.valueChanged)
        mode.frame = CGRect(x: view.frame.width-80, y: 120, width: 30, height: 30)
        scroll.addSubview(mode)
        

        // 定时器对象，每秒执行一次，调用timerfiremethod函数

        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.timerfiremethod), userInfo: nil, repeats: true)
            timer.fire()
     

    }
    
    func timerfiremethod(){
       getsiteinrange()      //获取满足范围的站点列表
        
        let currentspeedlabel = self.view.viewWithTag(101) as? UILabel       //找到之前定义好的输出框
        let siteshow = self.view.viewWithTag(102) as? UITextView
        let scroll = self.view.viewWithTag(104) as? UIScrollView
        let speed = round(self.speed*100)/100
        let angle = round(self.angle*100)/100
        let longitude = round(self.longitude*1000000)/1000000
        let latitude = round(self.latitude*1000000)/1000000
        let altidue = round(self.altidue*100)/100
        if angle == -1 {
        currentspeedlabel?.text = "当前速度为  \(speed)   km/h\n方向：                  海拔：   \(altidue)米\n当前位置：\(longitude)  \(latitude)"
        }
        else{
        currentspeedlabel?.text = "当前速度为  \(speed)   km/h\n方向：  \(angle)   度    海拔：   \(altidue)米\n当前位置：\(longitude)  \(latitude)"
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
        scroll?.addSubview(siteshow!)
        scroll?.addSubview(currentspeedlabel!)
        
        //print(self.latitude)
        //print(self.angel)
        //print(self.speed)
    
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        

        // Dispose of any resources that can be recreated.
    }



}

