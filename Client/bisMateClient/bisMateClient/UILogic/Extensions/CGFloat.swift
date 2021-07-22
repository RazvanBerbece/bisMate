//
//  CGFloat.swift
//  bisMateClient
//
//  Created by Razvan-Antonio Berbece on 19/07/2021.
//  https://medium.com/@nikeshakya51/responsive-design-in-ios-b35dc7f22821
//
//

import Foundation
import UIKit

let minScalableValue: CGFloat = 8.0 // Min value that should undergo upper scaling for bigger iphones and iPads

extension CGFloat {
    
    // MARK: - IPhone 8
    func relativeToIphone8Width(shouldUseLimit: Bool = true) -> CGFloat {
        let upperScaleLimit: CGFloat = 1.8
        var toUpdateValue = floor(self * (UIScreen.main.bounds.width / 375))
        guard self > minScalableValue else {return toUpdateValue}
        guard shouldUseLimit else {return toUpdateValue}
        guard upperScaleLimit > 1 else {return toUpdateValue}
        let limitedValue = self * upperScaleLimit
        if toUpdateValue > limitedValue {
            toUpdateValue = limitedValue
        }
        return toUpdateValue
    }
    func relativeToIphone8Height(shouldUseLimit: Bool = true) -> CGFloat {
        var extraHeight: CGFloat = 0
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        if #available(iOS 11.0, *) {
            extraHeight = keyWindow?.safeAreaInsets.bottom ?? 0
            extraHeight = extraHeight + (keyWindow?.safeAreaInsets.top ?? 20) - 20
        }
        let upperScaleLimit: CGFloat = 1.8
        var toUpdateValue = floor(self * ((UIScreen.main.bounds.height - extraHeight) / 667))
        guard self > minScalableValue else {return toUpdateValue}
        guard shouldUseLimit else {return toUpdateValue}
        guard upperScaleLimit > 1 else {return toUpdateValue}
        let limitedValue = self * upperScaleLimit
        if toUpdateValue > limitedValue {
            toUpdateValue = limitedValue
        }
        return toUpdateValue
    }
    
    // MARK: - IPhone 11 Pro
//    func relativeToIphone11ProWidth(shouldUseLimit: Bool = true) -> CGFloat {
//        // TODO
//        return
//    }
//    func relativeToIphone11ProHeight(shouldUseLimit: Bool = true) -> CGFloat {
//        // TODO
//        return
//    }
    
}
