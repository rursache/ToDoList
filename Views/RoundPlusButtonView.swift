//
//  RoundPlusButtonView.swift
//  ToDoList
//
//  Created by Radu Ursache on 01.07.2024.
//  Copyright © 2024 RanduSoft. All rights reserved.
//

import Foundation
import SwiftUI

struct RoundPlusButtonView: View {
    var action: () -> Void
    
    var body: some View {
        ZStack {
            Button {
                action()
            } label: {
                Image(systemName: "plus")
                    .bold()
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(.accent)
                    .clipShape(.circle)
            }.padding()
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}

#Preview {
    RoundPlusButtonView {
        print("Works!")
    }
}
