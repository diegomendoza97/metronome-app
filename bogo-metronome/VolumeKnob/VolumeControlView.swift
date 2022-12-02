import SwiftUI


struct KnobView: View {
    @State private var rotation: Double = 0.0
    @State private var startRotation: Double = 0.0
    
    var body: some View {
        Knob()
            .rotationEffect(.degrees(rotation))
            .gesture(
                RotationGesture()
                    .onChanged({ angle in
                        if startRotation == 0 {
                            startRotation = rotation
                        }
                        rotation = startRotation + angle.degrees
                    })
                    .onEnded({ _ in
                        startRotation = 0
                    })
            )
    }
}

// convience Knob to checkout this Stack Overflow answer
// that can be later replaced with your own
struct Knob: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .frame(width: 200, height: 200)
    }
}

struct KnobView_Previews: PreviewProvider {
    static var previews: some View {
        KnobView()
    }
}
