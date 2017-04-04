//
//  UIView+MBProgressHud.swift
//  Stories
//
//  Created by vlad on 8/15/16.
//  Copyright © 2016 908. All rights reserved.
//

import MBProgressHUD

extension UIView {
    func showActivityIndicator() -> MBProgressHUD {
        return MBProgressHUD.showAdded(to: self, animated: true)
    }

    func hideActivityIndicator() {
        MBProgressHUD.hide(for: self, animated: true)
    }
}
