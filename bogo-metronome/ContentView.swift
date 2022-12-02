//
//  ContentView.swift
//  bogo-metronome
//
//  Created by Diego Mendoza on 11/29/22.a
//

import SwiftUI
import Combine
import Subsonic
import AVFAudio

struct ContentView: View {
    @State private var wave = false
    
    
    @State private var bpm = 60
    @State private var bpmState = "Start"
    @State var showAlert = false
    @State var isPlaying = false;
    @State var alertTitle = ""
    @State var alertMessage = ""
    var path: String
    var url: URL
    var audioP: AVAudioPlayer
    init() {
        self.path = Bundle.main.path(forResource: "side_stick.mp3", ofType :nil)!
        self.url = URL(fileURLWithPath: path)
        self.audioP = try! AVAudioPlayer(contentsOf: url, fileTypeHint: nil)
        self.audioP.enableRate = true
        self.audioP.prepareToPlay()

        self.audioP.numberOfLoops = -1
    }

    
    var body: some View {
        VStack {
            Spacer()
            VStack (alignment: .leading) {
                HStack {
                    Button {
                        self.updateBPM(action: "remove")
                    } label: {
                        Text("-")
                            .foregroundColor(.white)
                    }
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                    Spacer()
                    
                    Text("\(bpm)").foregroundColor(.white)
                    Spacer()
                    Button {
                        self.updateBPM(action: "add")
                    } label: {
                        Text("+")
                            .foregroundColor(.white)
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 20))
                    
                }
            }
            .font(.system(size: 40))
            .offset(x: 0, y: 50)
            .alert(isPresented: self.$showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel())
            }
            ZStack{
                if isPlaying {
                    Circle()
                        .stroke(lineWidth: 40)
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(red: 82 / 255, green: 113 / 255, blue: 130 / 255))
                        .scaleEffect(wave ? 2 : 1)
                        .opacity(wave ? 0 : 1)
                        .onAppear() {
                            DispatchQueue.main.async {
                                withAnimation(.spring(response: 0.5).repeat(while: isPlaying, autoreverses: false).speed(getWaveSpeed(rate: Double(bpm)))) {
                                    self.wave.toggle()
                                }
                            }
                            
                        }.onDisappear() {
                            print("ON DISSAPEAR ")
                            DispatchQueue.main.async {
                                self.wave = false
                            }

                        }
                }
                
                Button {
                    metronome()
                } label: {
                    Text(bpmState)

                }
                .frame(width: 100, height: 100)
                .padding()
                .background(.white)
                .cornerRadius(70)
            }
            .padding(EdgeInsets(top: 200, leading: 0, bottom: 0, trailing: 0))
            Spacer()
        }
        .preferredColorScheme(.light)
        .ignoresSafeArea()
        .background(getRGB(red: 21, green: 52, blue: 69))
    }
    
    func updateBPM(action: String) {
        if action == "add" {
            if bpm + 1 > 250 {
                alertTitle = "BPM too high!"
                alertMessage = "BPM can't be above 250"
                self.showAlert = true
                return
            }
            bpm += 1
        } else {
            if bpm - 1 < 30 {
                alertTitle = "BPM too low!"
                alertMessage = "BPM can't be below 30"
                self.showAlert = true
                return
            }
            bpm -= 1
        }
    }
    
    func metronome() {
        DispatchQueue.main.async {
            if bpmState == "Start" {
                let bpmFloatValue = self.bpm
                if bpmFloatValue > 250 {
                    self.showAlert = true
                    return
                }
                audioP.rate = getRate(rate: Float(bpmFloatValue))// Change your rate here
                self.audioP.play()
                isPlaying = true
                bpmState = "Stop"
            } else {
                isPlaying = false
                audioP.stop()
                bpmState = "Start"
            }
        }
    }
    
    func getRate(rate: Float) -> Float {
        let newRate = rate / 60
        return newRate
    }
    
    func getWaveSpeed(rate: Double) -> Double {
        print(rate / 100 - 0.1)
        return rate / 100 - 0.1
    }
    
    func getRGB(red: Double, green: Double, blue: Double) -> Color {
        return Color(red: red / 255, green: green / 255, blue: blue / 255)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
            if expression {
                return self.repeatForever(autoreverses: autoreverses)
            } else {
                return self
            }
        }
}
