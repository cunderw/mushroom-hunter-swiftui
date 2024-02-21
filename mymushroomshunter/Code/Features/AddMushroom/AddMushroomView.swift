//
//  AddMushroom.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct AddMushroomView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var dateFound: Date = .init()
    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker: Bool = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mushroom Details")) {
                    TextField("Name", text: $name)
                    TextEditor(text: $description)
                        .frame(height: 100)
                    DatePicker("Date Found", selection: $dateFound, displayedComponents: .date)
                }

                Section(header: Text("Photo")) {
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Text("Select a photo")
                        }
                    }
                }
            }
            .navigationTitle("Add Mushroom")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        // TODO: - Hookup View Model
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
        }
    }
}

#Preview {
    AddMushroomView()
}
