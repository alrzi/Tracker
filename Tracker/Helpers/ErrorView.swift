//
//  ErrorView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 22.03.2025.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Что то пошло не так")
                .font(.system(size: 23, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Не можем загрузить данные проверьте подключение к интернету")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.gray)
            
            Button(action: onRetry) {
                Text("Попробовать еще раз")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(
                        RadialGradient(
                            colors: [
                                .red,
                                .mint,
                                .green
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 170
                        ),
                        in: .rect(cornerRadius: 12)
                    )
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ErrorView(onRetry: { })
        .background(.black)
}
