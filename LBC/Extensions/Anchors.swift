//
//  Anchors.swift
//  LBC
//
//  Created by Berserk on 29/05/2024.
//

import UIKit

extension UIView {
    
    func anchors(leading: NSLayoutXAxisAnchor?, leadingConstant: CGFloat = 0.0, trailing: NSLayoutXAxisAnchor?, trailingConstant: CGFloat = 0.0, top: NSLayoutYAxisAnchor?, topConstant: CGFloat = 0.0, bottom: NSLayoutYAxisAnchor?, bottomConstant: CGFloat = 0.0) -> [NSLayoutConstraint] {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        if let unwrappedLeading = leading {
            constraints.append(leadingAnchor.constraint(equalTo: unwrappedLeading, constant: leadingConstant))
        }
        if let unwrappedTrailing = trailing {
            constraints.append(trailingAnchor.constraint(equalTo: unwrappedTrailing, constant: trailingConstant))
        }
        
        if let unwrappedTop = top {
            constraints.append(topAnchor.constraint(equalTo: unwrappedTop, constant: topConstant))
        }
        
        if let unwrappedBottom = bottom {
            constraints.append(bottomAnchor.constraint(equalTo: unwrappedBottom, constant: bottomConstant))
        }
        
        return constraints
    }
    
}
