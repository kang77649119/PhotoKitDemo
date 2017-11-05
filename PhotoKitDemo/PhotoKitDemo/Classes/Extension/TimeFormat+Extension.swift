//
//  TimeFormat+Extension.swift
//  PhotoKitDemo
//
//  Created by 也许、 on 2017/10/10.
//  Copyright © 2017年 也许、. All rights reserved.
//

import UIKit

extension Double {
    
    func formatHourMinueSecond() -> String {
        var time = ""
        let hours:Int = Int(self / 3600)
        let minutes:Int = Int(self.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds:Int = Int(self.truncatingRemainder(dividingBy: 3600))
        
        if hours == 0 {
            time = String.init(format: "%d:%02d", minutes, seconds)
        } else {
            time = String.init(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        return time
    }
    
}
