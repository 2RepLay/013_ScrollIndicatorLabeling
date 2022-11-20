//
//  Character.swift
//  011_StackedScroll
//
//  Created by nikita on 20.10.2022.
//

import SwiftUI

struct Character: Identifiable {
	
	var id: String = UUID().uuidString
	var value: String
	var index: Int = 0
	var rect: CGRect = .zero
	var pusOffset: CGFloat = 0
	var isCurrent: Bool = false
	var color: Color = .clear	
	
}
