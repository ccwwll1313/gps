//
//  compute.swift
//  gps
//
//  Created by 任思燕 on 17/2/24.
//  Copyright © 2017年 陈伟麟. All rights reserved.
//

import Foundation
import Darwin

func calcdistance (fromLongitude: Double,fromLatitude: Double,toLongitude: Double,toLatitude: Double) -> Double {
    let pi = M_PI
    let rc = 6378.1370  //赤道半径
    let rj = 6356.7523  //极半径
    let fromralon = (fromLongitude/180)*pi
    let fromrala = fromLatitude/180*pi
    let toralon = toLongitude/180*pi
    let torala = toLatitude/180*pi
    
    let ec = rj + (rc - rj) * (90 - fromLatitude) / 90
    let ed = ec * cos(fromrala)
    let dx = (toralon - fromralon) * ed
    let dy = (torala - fromrala) * ec
    return sqrt(dx*dx + dy*dy)

}
func calcangle(fromLongitude: Double,fromLatitude: Double,toLongitude: Double,toLatitude: Double) -> Double {
    let pi = M_PI
    let rc = 6378.1370  //赤道半径
    let rj = 6356.7523  //极半径
    let fromralon = (fromLongitude/180)*pi
    let fromrala = fromLatitude/180*pi
    let toralon = toLongitude/180*pi
    let torala = toLatitude/180*pi
    let ec = rj + (rc - rj) * (90 - fromLatitude) / 90
    let ed = ec * cos(fromrala)
    let dx = (toralon - fromralon) * ed
    let dy = (torala - fromrala) * ec
    var angle:Double = 0.0
    angle = atan(abs(dx/dy))*180/pi
    let dlo = toLongitude - fromLongitude
    let dla = toLatitude - fromLatitude
    if (dlo>0)&&(dla<=0){
        angle = (90 - angle)+90
    }
    else if (dlo<=0)&&(dla<0){
        angle = angle+180
    }
    else if (dlo<0)&&(dla>=0){
        angle = 90-angle+270
    }
    return angle
}



