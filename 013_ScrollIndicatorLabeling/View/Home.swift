//
//  Home.swift
//  013_ScrollIndicatorLabeling
//
//  Created by nikita on 25.10.2022.
//

import SwiftUI

struct Home: View {
	
	@State var characters: [Character] = []
	@State var scrollerHeight: CGFloat = 0
	@State var indicatorOffset: CGFloat = 0
	@State var startOffset: CGFloat = 0
	@State var hideIndicatorLabel: Bool = true
	
	@State var timeOut: CGFloat = 0.3
	@State var currentCharacter: Character = .init(value: "")
	
    var body: some View {
		NavigationStack {
			GeometryReader {
				let size = $0.size
				
				ScrollViewReader(content: { proxy in
					ScrollView(.vertical, showsIndicators: false) {
						VStack(spacing: 0) { 
							ForEach(characters) { character in
								ContactsForCharacter(character: character)
									.id(character.index)
							}
						}
						.padding(.top, 15)
						.padding(.trailing, 20)
						.offset { rect in
							if hideIndicatorLabel && rect.minY < 0 {
								timeOut = 0
								hideIndicatorLabel = false
							}
							
							let rectHeight = rect.height
							let viewHeight = size.height + (startOffset / 2)
							
							let scrollerHeight = (viewHeight / rectHeight) * viewHeight
							self.scrollerHeight = scrollerHeight
							
							let progress = rect.minY / (rectHeight - size.height)
							self.indicatorOffset = -progress * (size.height - scrollerHeight)
						}
					}
				})
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.overlay(alignment: .topTrailing, content: { 
					Rectangle()
						.fill(.clear)
						.frame(width: 2, height: scrollerHeight)
						.overlay(alignment: .trailing, content: { 
							Image(systemName: "bubble.middle.bottom.fill")
								.resizable()
								.renderingMode(.template)
								.aspectRatio(contentMode: .fit)
								.foregroundStyle(.ultraThinMaterial)
								.frame(width: 45, height: 45)
								.rotationEffect(.init(degrees: -90))
								.overlay(content: { 
									Text(currentCharacter.value)
										.fontWeight(.black)
										.foregroundColor(.white)
										.offset(x: -3)
								})
								.environment(\.colorScheme, .dark)
								.offset(x: hideIndicatorLabel || currentCharacter.value == "" ? 65 : 0)
								.animation(.interactiveSpring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.6), value: hideIndicatorLabel || currentCharacter.value == "")
						})
						.padding(.trailing, 5)
						.offset(y: indicatorOffset)
				})
				.coordinateSpace(name: "SCROLLER")
			}
			.navigationTitle("Contact's")
			.offset { rect in
				if startOffset != rect.minY {
					startOffset = rect.minY
				}
			}
		}
		.onAppear {
			characters = fetchCharacters()
		}
		.onReceive(Timer.publish(every: 0.01, on: .main, in: .default).autoconnect()) { _ in
			if timeOut < 0.3 {
				timeOut += 0.01
			} else {
				if !hideIndicatorLabel {
					hideIndicatorLabel = true	
				}
			}
		}
    }
	
	@ViewBuilder
	func ContactsForCharacter(character: Character) -> some View {
		VStack(alignment: .leading, spacing: 15) { 
			Text(character.value)
				.font(.largeTitle.bold())
			
			ForEach(1...4, id: \.self) { _ in
				HStack(spacing: 10) { 
					Circle()
						.fill(character.color.gradient)
						.frame(width: 45, height: 45)
					
					VStack(alignment: .leading, spacing: 8) {
						RoundedRectangle(cornerRadius: 4, style: .continuous)
							.fill(character.color.opacity(0.6).gradient)
							.frame(height: 20)
						
						RoundedRectangle(cornerRadius: 4, style: .continuous)
							.fill(character.color.opacity(0.4).gradient)
							.frame(height: 20)
							.padding(.trailing, 80)
					}
				}
			}
		}
		.offset { rect in
			if characters.indices.contains(character.index) {
				characters[character.index].rect = rect
			}
			
			if let last = characters.last(where: { char in
				char.rect.minY < 0
			}), last.id != currentCharacter.id {
				currentCharacter = last
			}
		}
		.padding(15)
	}
	
	func fetchCharacters() -> [Character] {
		let alphabets: String = "ABCDEFGHIJJKLMNOPQRSTUVWXYZ"
		var characters: [Character] = []
		
		characters = alphabets.compactMap({ character -> Character? in
			return Character(value: String(character))
		})
		
		let colors: [Color] = [.red, .yellow, .pink, .orange, .cyan, .indigo, .purple, .blue]
		
		for index in characters.indices {
			characters[index].index = index
			characters[index].color = colors.randomElement()! 
		}
		
		return characters
	}
	
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

extension View {
	
	@ViewBuilder
	func offset(completion: @escaping(CGRect) -> Void) -> some View {
		self
			.overlay { 
				GeometryReader {
					let rect = $0.frame(in: .named("SCROLLER"))
					
					Color.clear
						.preference(key: OffsetKey.self, value: rect)
						.onPreferenceChange(OffsetKey.self) { value in
							completion(value)
						}
				}
			}
	}
	
}

struct OffsetKey: PreferenceKey {
	
	static var defaultValue: CGRect = .zero
	
	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
	
}
