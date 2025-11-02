import SwiftUI

struct ClassificationResultModal: View {
    let breed: String
    let accuracy: String
    let onThumbUp: () -> Void
    let onThumbDown: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Spacer()
                
                Text("Classification Result")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Dog breed is \(breed) (\(accuracy))")
                    .font(.title2)
                    .foregroundStyle(.primary)
                
                HStack {
                    Spacer()
                    
                    Button {
                        onThumbUp()
                    } label: {
                        Image(systemName: "hand.thumbsup")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                    }
                    
                    Button {
                        onThumbDown()
                    } label: {
                        Image(systemName: "hand.thumbsdown")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 4)
                
                Spacer()
            }
            .presentationDetents([.medium])
        }
    }
}

