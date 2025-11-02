import SwiftUI

struct ClassificationResultView: View {
    let breed: Breeds
    let accuracy: Float
    let userImage: UIImage?
    
    @State private var viewModel: ClassificationResultViewViewModel?
    @State private var apiImage: UIImage?
    @State private var showConfirmationAlert = false
    @State private var pendingFolder: String?
    @State private var pendingImage: UIImage?
    
    init(breed: Breeds, accuracy: Float, userImage: UIImage?) {
        self.breed = breed
        self.accuracy = accuracy
        self.userImage = userImage
        _viewModel = State(initialValue: ClassificationResultViewViewModel(breed: breed.rawValue))
    }
    
    private var accuracyLevel: AccuracyLevel {
        AccuracyLevel(percentage: accuracy)
    }
    
    private var formattedAccuracy: String {
        String(format: "%.2f%%", accuracy)
    }
    
    private var classificationMessage: String {
        switch accuracyLevel {
        case .high:
            return "Dog breed is \(breed.displayName) (\(formattedAccuracy))"
        case .medium:
            return "We are not sure but the dog breed may be \(breed.displayName) (\(formattedAccuracy))"
        case .low:
            return "We apologize but we are not sure if this is a dog and if so what breed it is. Try with another photo. (\(formattedAccuracy))"
        }
    }
    
    var body: some View {
        ScrollView() {
            Text("Classification Result")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 24)
            
            Text(classificationMessage)
                .font(.title2)
                .foregroundStyle(.primary)
                .padding(.bottom)
            
            HStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Your Photo")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let userImage = userImage {
                        Image(uiImage: userImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                            }
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Breed Reference")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let apiImage = apiImage {
                        Image(uiImage: apiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 150, height: 150)
                            .overlay {
                                ProgressView()
                            }
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .onChange(of: viewModel?.breedDetails?.imageLink) { oldValue, newValue in
                if let imageURL = newValue, let url = URL(string: imageURL) {
                    loadImage(from: url)
                }
            }
            
            HStack {
                if viewModel?.isUploading == true {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    Button {
                        pendingFolder = "dog-classifier-feedback-positive"
                        pendingImage = userImage
                        showConfirmationAlert = true
                    } label: {
                        Image(systemName: "hand.thumbsup")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.green)
                            }
                    }
                    .disabled(viewModel?.isUploading == true)
                    
                    Button {
                        pendingFolder = "dog-classifier-feedback-negative"
                        pendingImage = userImage
                        showConfirmationAlert = true
                    } label: {
                        Image(systemName: "hand.thumbsdown")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .foregroundStyle(.red)
                            }
                    }
                    .disabled(viewModel?.isUploading == true)
                }
            }
            .padding(.bottom)
            .alert("Permission Request", isPresented: $showConfirmationAlert) {
                Button("Cancel", role: .cancel) {
                    pendingFolder = nil
                    pendingImage = nil
                }
                Button("OK") {
                    if let folder = pendingFolder, let image = pendingImage {
                        viewModel?.confirmUpload(image: image, folder: folder)
                    }
                    pendingFolder = nil
                    pendingImage = nil
                }
            } message: {
                Text("Please, allow us to use your photo and the classification result to improve our model.")
            }
            
            if let breedDetails = viewModel?.breedDetails {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Breed Characteristics")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(breedDetails.characteristics, id: \.title) { characteristic in
                            CharacteristicCard(characteristic: characteristic)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .task {
            if let imageURL = viewModel?.breedDetails?.imageLink, let url = URL(string: imageURL) {
                loadImage(from: url)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.apiImage = image
                    }
                }
            } catch {
                print("Failed to load image: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ClassificationResultView(breed: Breeds(rawValue: "chihuahua") ?? .unknown, accuracy: 99.0, userImage: nil)
}
