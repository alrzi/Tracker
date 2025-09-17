//
//  View+backDeployedLabelsVisibility.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import SwiftUI

extension View {
    @available(iOS, deprecated: 18.0, message: "use labelsVisibility instead")
    @ViewBuilder
    func backDeployedLabelsVisibility(_ visibility: Visibility) -> some View {
        if #available(iOS 18.0, *) {
            self.labelsVisibility(visibility)
        }
        else {
            self
        }
    }
}
