//
//  AddMushroom.swift
//  mymushroomshunter
//
//  Created by Carson Underwood on 2/13/24.
//

import SwiftUI

struct AddMushroomView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var repositoryWrapper: MushroomRepositoryWrapper
    @StateObject private var viewModel = AddMushroomViewModel()
    @State private var isShowingImagePicker: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mushroom Details")) {
                    TextField("Name", text: $viewModel.name)
                    TextEditor(text: $viewModel.description)
                        .frame(height: 100)
                    DatePicker("Date Found", selection: $viewModel.dateFound, displayedComponents: .date)
                }

                Section(header: Text("Photo")) {
                    Button(action: {
                        isShowingImagePicker = true
                    }) {
                        if let selectedImage = viewModel.selectedImage {
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
            .onAppear {
                viewModel.repository = repositoryWrapper.repository
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        viewModel.saveMushroom(userID: "YourUserID") { success, error in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            } else if let error = error {
                                alertMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $viewModel.selectedImage, sourceType: .photoLibrary)
            }
        }
    }
}

struct AddMushroomView_Previews: PreviewProvider {
    static var previews: some View {
        let mockRepository = MockMushroomRepository(mushrooms: [
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
            Mushroom.sample,
        ])

        let mockRepositoryWrapper = MushroomRepositoryWrapper(repository: mockRepository)

        let authManager = AuthManager(
            authService: MockAuthenticationService(
                currentUser: MockUser(uid: "123", email: "test@example.com")
            )
        )

        AddMushroomView()
            .environmentObject(authManager)
            .environmentObject(mockRepositoryWrapper)
    }
}
