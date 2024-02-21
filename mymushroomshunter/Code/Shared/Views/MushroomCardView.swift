//
//  MushroomCardView.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

enum CardLayout {
    case vertical
    case horizontal
}

struct MushroomCardView: View {
    var mushroom: Mushroom
    var layout: CardLayout

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }

    var body: some View {
        Group {
            if layout == .vertical {
                VStack(alignment: .leading, spacing: 10) {
                    content
                }
            } else {
                HStack {
                    content
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .padding([.top])
    }

    @ViewBuilder
    private var content: some View {
        mushroomImage
        if layout == .vertical {
            Text(mushroom.name)
                .font(.headline)

            Text(mushroom.description)
                .font(.subheadline)

            Text("Found on \(dateFormatter.string(from: mushroom.dateFound))")
                .font(.footnote)
                .foregroundColor(.secondary)
        } else {
            VStack {
                Text(mushroom.name)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(mushroom.description)
                    .font(.subheadline)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(dateFormatter.string(from: mushroom.dateFound))
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var mushroomImage: some View {
        AsyncImage(url: URL(string: mushroom.photoUrl)) { phase in
            switch phase {
            case .empty:
                // Placeholder for loading
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "photo")
                    .foregroundColor(.gray)
            @unknown default:
                EmptyView()
            }
        }
        .cornerRadius(12)
        .frame(width: layout == .horizontal ? 100 : nil, height: 100)
    }
}

struct MushroomCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MushroomCardView(mushroom: Mushroom.sample, layout: .vertical)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Vertical Layout")

            MushroomCardView(mushroom: Mushroom.sample, layout: .horizontal)
                .previewLayout(.sizeThatFits)
                .padding()
                .previewDisplayName("Horizontal Layout")
        }
    }
}
