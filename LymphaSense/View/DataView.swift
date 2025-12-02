//
//  DataView.swift
//  AMAL
//
//  Created by Lindsay on 10/29/25.
//

import SwiftUI

struct DataView: View {
    var body: some View {
        VStack {
            Text("Data")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            /* Text("Hobbies")
                .font(.title2)
            
            HStack {
                ForEach(information.hobbies, id: \.self) { hobby in
                    Image(systemName: hobby)
                        .resizable()
                        .frame(maxWidth: 80, maxHeight: 60)
                    
                }
                .padding()
            }
            .padding()

            Text("Foods")
                .font(.title2)
            
            HStack(spacing: 60) {
                ForEach(information.foods, id: \.self) { food in
                    Text(food)
                        .font(.system(size: 48))
                }
            }
            .padding()

            Text("Favorite Colors")
                .font(.title2)

            HStack(spacing: 30) {
                ForEach(information.colors, id: \.self) { color in
                    color
                        .frame(width: 70, height: 70)
                        .cornerRadius(10)
                }
            }
            .padding() */
        }
    }
}

struct DataView_Previews: PreviewProvider {
    static var previews: some View {
        DataView()
    }
}
