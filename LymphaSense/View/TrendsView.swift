//
//  TrendsView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

import SwiftUI

struct TrendsView: View {
    var body: some View {
        VStack {
            Text("Trends")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
    
            
            /* ScrollView {
                Text(information.story)
                    .font(.body)
                    .padding()
            } */
        }
        .padding([.top, .bottom], 50)
    }
}

struct TrendsView_Previews: PreviewProvider {
    static var previews: some View {
        TrendsView()
    }
}
