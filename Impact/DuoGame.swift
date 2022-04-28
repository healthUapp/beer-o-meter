//
//  ContentView.swift
//  simpleGraph
//
//  Created by User on 11.04.22.
//

import SwiftUI
import CoreMotion
import CoreGraphics
import Subsonic


struct AccelerometerViewDuo: View {
    let screenHeight = UIScreen.screenHeight
    let screenWidth = UIScreen.screenWidth
    
    @Environment(\.presentationMode) private var presentationMode
    
    
    
    @State private var bpm: Double = 256
    @State private var runSize = 50
    @State private var runOpaciryDown: Bool = false
    @State private var runOpaciryUp: Bool = false
    @State private var runOpacity: Double = 0
    @State private var gameTime: Double = 45
    @State private var timerColor = Color.black
    
    //SOUNDS
    @State private var music: Bool = true
    @State private var playMusic: Bool = false
    @StateObject private var boublesSound = SubsonicPlayer(sound: "bubbles.mp3")
    @StateObject private var pouringSound = SubsonicPlayer(sound: "bestPouring.mp3")
    @StateObject private var bulbSound = SubsonicPlayer(sound: "bulb.mp3")
    //
    
    
    //Состояние записи работы акселерометра и гироскопа
    @State private var motionsRecording: Bool = false
    @State private var alertStatus: Bool = false
    
    @State private var rules: Bool = true
    @State private var pouring:Bool = false
    @State private var countdown:Bool = false
    @State private var countdownValue:Double = 3.5
    @State private var gameTimer:Int = 0
    @State private var running: Bool = false
    @State private var finish: Bool = false
    
    @State private var pourOut:Bool = false
    @State private var missedBeer:Int = 0
    @State private var missedBeerValue:Double = 1000

    @State private var missedFoam:Double = 0 //позже добавлю
    @State private var foamHeight:Double = 50
    @State private var beerHeight:Double = 0
    @State private var beerOpacity:Double = 1
    
    @State private var motionsData_ForSheets: [[String:Double]] = []

    @State private var motionsDataX: [Double] = [0,0]
    @State private var motionsDataY: [Double] = [0,0]
    @State private var shakesDataZ: [Double] = [0,0]
    
    @State private var motionsCounter: Double = 0

    @State private var accelX = Double.zero
    @State private var accelY = Double.zero
    @State private var accelZ = Double.zero
    
    @State private var gyroX = Double.zero
    @State private var gyroY = Double.zero
    @State private var gyroZ = Double.zero
    
    @State private var shakeAccelX: Double = 0
    @State private var shakeAccelY: Double = 0
    
    
    @State private var leftBeerY:Double = 20
    @State private var centerBeerY:Double = 20
    @State private var rightBeerY:Double = 20
    
    @State private var leftBottomY:Double = 250
    @State private var centerBottomY:Double = 250
    @State private var rightBottomY:Double = 250
    
    @State var bubblesHeight:Double = 250
    @State var bubblesWidth:Double = 185

    @State var valueForLoading = 0
    @State var loadingText = ""
    @State var dots = ""
    
    let motion = CMMotionManager()
    let queue = OperationQueue()
    let noBeerY:Double = 20
    let deadValue:Double = 0
    let updateFrequency:Double = 0.02
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    let waterDelay = 6

    func MyMotion(){
        print("\(runOpacity)")
        
        
        
        self.missedBeer = self.missedBeerValue < 250 ? Int((1-(self.missedBeerValue/250))*100) : 0
        
        if(self.countdown){
            self.countdownValue -= 0.02
            
            if(self.countdownValue <= 0.5){
                self.countdown = false
                self.running = true
                
                if(music){
                    self.playMusic = true
                }
            }
        }
        
        self.beerOpacity = 150/(abs(accelY) + (missedBeerValue/10))
        
        self.bubblesHeight = (leftBeerY > rightBeerY ? leftBeerY : rightBeerY)
        self.bubblesWidth = 185
        
        if(valueForLoading == 40){
            valueForLoading = 0
        } else {
            valueForLoading += 1
        }
        
        if(valueForLoading > 0){self.dots = ""}
        if(valueForLoading > 10){self.dots = "."}
        if(valueForLoading > 20){self.dots = ".."}
        if(valueForLoading > 30){self.dots = "..."}
        
        motion.accelerometerUpdateInterval = updateFrequency
        motion.startAccelerometerUpdates(to: OperationQueue.current!){ (data,error) in
            if let myAccelData = self.motion.accelerometerData{
                
                //Получение данных от акселерометра:
                let ax = myAccelData.acceleration.x
                let ay = myAccelData.acceleration.y
//                let az = myAccelData.acceleration.z
                
                //Преобразование данных для графиков:
                let nowScaledAX = round(ax * 300 * abs(ax * 2))
//                let beerAY = (ay * 100 < -100 ? ay : 0)
                let densityСoefficient = -(ay+1) > 0 ? 0.5 : 1
                let nowScaledAY = round(-(ay+1) * (200 * densityСoefficient))

//                let scaledAZ = az * 100
                
                //Запись в массив
                let beforeAX = motionsDataX[motionsDataX.count-1]
                let averageValueX = (nowScaledAX + beforeAX)/2
                self.motionsDataX.append(averageValueX)


                let beforeAY = motionsDataY[motionsDataY.count-1]
                let averageValueY = (nowScaledAY + beforeAY)/2
                self.motionsDataY.append(averageValueY)

                //Вывод данных в рендер
                
                for (index, value) in motionsDataX.enumerated() {
                    if(index == motionsDataX.count - waterDelay){
                        self.accelX = value
                    }
                }
                for (index, value) in motionsDataY.enumerated() {
                    if(index == motionsDataY.count - waterDelay){
                        self.accelY = value
                    }
                }
            }
        }
        
        motion.gyroUpdateInterval = updateFrequency
        motion.startGyroUpdates(to: OperationQueue.current!){ (data,error) in
            if let myGyroData = self.motion.gyroData{
                
//                let date = Date()
//                let calendar = Calendar.current
//                let hour = calendar.component(.hour, from: date)
//                let minute = calendar.component(.minute, from: date)
//                let second = calendar.component(.second, from: date)
//                let dateNow = "\(hour):\(minute):\(second)"
                
                //Получение данных от акселерометра:
                let gx = myGyroData.rotationRate.x
                let gy = myGyroData.rotationRate.y
                let gz = myGyroData.rotationRate.z
                
                //Преобразование данных для графиков:
                let scaledGX = gx * 100
                let scaledGY = gy * 100
                let scaledGZ = gz * 100
                
                //Вывод данных в рендер
                self.gyroX = scaledGX
                self.gyroY = scaledGY
                self.gyroZ = scaledGZ
                
                self.shakesDataZ.append(scaledGZ)
            }
        }
        
        if(self.motionsDataX.count > 300){
                motionsDataX.remove(at: 0)
                motionsDataX.remove(at: 0)
                motionsDataY.remove(at: 0)
                motionsDataY.remove(at: 0)
            
        }
        
        if(pouring){
            self.leftBeerY = missedBeerValue + noBeerY
            self.centerBeerY = missedBeerValue + noBeerY
            self.rightBeerY = missedBeerValue + noBeerY
        }else{
            self.leftBeerY = accelX + noBeerY + missedBeerValue + accelY
            self.centerBeerY = (abs(gyroZ)/6) + abs(accelX ) + noBeerY + missedBeerValue + accelY
            self.rightBeerY = -accelX  + noBeerY + missedBeerValue + accelY
        }
        
        
        
        self.foamHeight = 40 - (missedBeerValue/15)

        if(pourOut){
            self.missedBeerValue += 50
            self.pourOut = missedBeerValue > 250 ? false : true
        }
        
        if(!pouring){
            if(missedBeerValue > 250 - deadValue || (accelY < -195) ){
                if(missedBeerValue < 1000 ){
                    self.missedBeerValue += 10 + gyroZ/20
                }
                if(missedBeerValue>250){
                    finishGame()
                }
            }
        }

        if(leftBeerY < 0 || rightBeerY < 0){
            missedBeerValue += 0.03 * (abs(accelY * 3) + abs(accelX))
        }
        
        if(pouring){
            missedBeerValue -= 2
            
            if(missedBeerValue < 1){
                self.alertStatus = false
                self.pouring = false
            }
        }

        if(running){
            if(gameTime > 0){
                self.gameTime -= 0.02
                if(gameTime < 10){
                    if(gameTime < 5){
                        timerColor = Color.red
                    }else{
                        timerColor = Color.orange
                    }
                }else{
                    timerColor = Color.black
                }
            }else{
                finishGame()
            }
            
            if(self.runOpacity >= 1){
                self.runOpaciryUp = false
                self.runOpaciryDown = true
                runOpacity -= (bpm/60)/50
            }
            if(self.runOpacity <= 0){
                self.runOpaciryDown = false
                self.runOpaciryUp = true
                
                self.runOpacity += (bpm/60)/50
            }
            
            if(self.runOpaciryUp){
                self.runOpacity += (bpm/60)/50
            }
            
            if(self.runOpaciryDown){
                self.runOpacity -= (bpm/60)/50
            }
        }
        
    }
    
    
    func startGame(){
        motionsRecording = true
        self.rules = false
        self.finish = false
        self.pouring = true
        self.countdown = true
        self.countdownValue = 3.5
        self.missedBeerValue = 300
        self.gameTime = 44
        
        pouringSound.play()
        bulbSound.play()
        boublesSound.play()
    }
    
    
    func finishGame(){
        motionsRecording = false
        self.finish = true
        self.rules = false
        self.running = false
        self.pouring = false
        self.countdown = false
        self.gameTimer = 0
        
        self.playMusic = false
        pouringSound.stop()
        bulbSound.stop()
        boublesSound.stop()
    }
    
    func goToMainMenu(){
        presentationMode.wrappedValue.dismiss()
    }

    
    
  
var body: some View {
   VStack {
           ZStack{
               ZStack{
                   GeometryReader { geometry in //Пиво с градиентом
                       Path { path in
                           path.move(to: CGPoint(x: 0, y: leftBeerY))
                           path.addQuadCurve(to: CGPoint(x: 185, y: rightBeerY), control: CGPoint(x: 120 - (gyroZ/10), y: centerBeerY))
                          path.addLine(to: CGPoint(x:185, y: leftBottomY))
                           path.addLine(to: CGPoint(x:0, y: rightBottomY))
                       }.fill(LinearGradient(colors: [Color(UIColor(red: 0.84, green: 0.47, blue: 0.00,alpha: beerOpacity)),Color(UIColor(red: 1.00, green: 0.73, blue: 0.00, alpha: beerOpacity/1.5))], startPoint: .top, endPoint: .bottom))
                   }

                   Path() { path in //верх
                       path.move(to: CGPoint(x: 185, y: 0))
                       path.addLine(to: CGPoint(x: 185, y: -screenHeight))
                       path.addLine(to: CGPoint(x: 0, y: -screenHeight))
                       path.addLine(to: CGPoint(x: 0, y: 0))
                       path.closeSubpath()
                   }.fill(Color.white)
                   
                  GeometryReader { geometry in //Пена
                      Path { path in
                          path.move(to: CGPoint(x: 0 + (foamHeight/2.2), y: leftBeerY))
                          path.addQuadCurve(to: CGPoint(x: 185 - (foamHeight/2.2), y: rightBeerY), control: CGPoint(x: 92 , y: centerBeerY - foamHeight/4))
                      }.stroke(style: StrokeStyle(lineCap: .round )).stroke(Color(UIColor(red: 1.00, green: 0.91, blue: 0.74,alpha: 1)),lineWidth: foamHeight)
                  }
                   
                   Path() { path in //низ
                       path.move(to: CGPoint(x: 200, y: 250))
                       path.addLine(to: CGPoint(x: 200, y: screenHeight))
                       path.addLine(to: CGPoint(x: -20, y: screenHeight))
                       path.addLine(to: CGPoint(x: -20, y: 250))
                       path.closeSubpath()
                   }.fill(Color.white)
                   
               }
                    .frame(width: 187, height:255, alignment: .center)
                    
               
                   .alert("Pour some more?", isPresented: $alertStatus) {
                       Button("YES!", role: .cancel) {
                           self.missedBeerValue = 300
                           self.alertStatus = false
                           self.pouring = true
                       }

                   }
               
               Image("BeerGlass").resizable().frame(width: 400, height: 420)
               
               
               ZStack{
                   if(running){
                       Image("RUN").offset(y: -250).opacity(runOpacity)
                       
                       Text("\(gameTime, specifier: "%.0f")s")
                           .font(.title)
                           .fontWeight(.semibold)
                           .offset(y:180)
                           .foregroundColor(timerColor)
                       
                       Button(action: finishGame){
                           Image("finish")
                       }.offset(y:250)
                   }
                   
                   if(pouring){
                       Text("Pouring" + self.dots).font(.title).fontWeight(.semibold).padding(.vertical, 20)
                           .offset(y:-180)
                   }else{
                       Text("\(missedBeer)%")
                           .font(.largeTitle)
                           .fontWeight(.semibold)
                           .offset(y:-180)
                   }
                   
               }.padding(.vertical,20)
                   .sound("running45s.mp3", isPlaying: $playMusic, volume: Double(missedBeer)/100)
           
               
           
               if(rules){ //ПРАВИЛА
                   ZStack(){
                       VStack(){
                           Text("What should I do?").foregroundColor(Color.black)
                               .font(.system(size: 32))
                           Text("Find a partner. When your mugs are full of beer - RUN! Try not to spill the beer! Who runs smoother wins the race!").foregroundColor(Color.black)
                               .font(.system(size: 16))
                               .multilineTextAlignment(.center)
                               .frame(width: screenWidth-40).padding(.vertical, 10)
                           Button(action: startGame){
                               Image("start")
                           }

                       }.frame(width: screenWidth-20, height: 335, alignment: .center)
                           .background(Color(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.90))).cornerRadius(20)
                   }.frame(width:  screenWidth, height: screenHeight).background(Color(UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 0.30)))
               }
               
               
               if(pouring && !running){
                   ZStack(){
                       Text("\(countdownValue, specifier: "%.0f")")
                           .font(.system(size: 60))
                           .fontWeight(.bold)
                           .offset(y:-250)
                   }
               }
               
               if(finish){ //Финиш
                   ZStack(){
                       VStack(){
                           if(missedBeer >= 80){
                               Text("Wow!").foregroundColor(Color.black)
                                   .font(.system(size: 32))
                               Text("You have 80% of beer left! Your’re better than 80% of people in the world!!").foregroundColor(Color.black)
                                   .font(.system(size: 16))
                                   .multilineTextAlignment(.center)
                                   .frame(width: screenWidth-40).padding(.vertical, 10)
                           }
                           if(missedBeer >= 50 && missedBeer < 80){
                               Text("Yeah!").foregroundColor(Color.black)
                                   .font(.system(size: 32))
                               Text("You’re almost there! Try harder and you’ll break the record!").foregroundColor(Color.black)
                                   .font(.system(size: 16))
                                   .multilineTextAlignment(.center)
                                   .frame(width: screenWidth-40).padding(.vertical, 10)
                           }
                           if(missedBeer < 50){
                               Text("Fuh!").foregroundColor(Color.black)
                                   .font(.system(size: 32))
                               Text("That was hard but you can do it better! Try again!").foregroundColor(Color.black)
                                   .font(.system(size: 16))
                                   .multilineTextAlignment(.center)
                                   .frame(width: screenWidth-40).padding(.vertical, 10)
                           }
                           
                           
                           Button(action: startGame){
                               Image("tryAgain")
                               
                           }
                           
                           
                           Button(action: goToMainMenu){
                               Text("Main menu").foregroundColor(Color(UIColor(red: 0.35, green: 0.46, blue: 0.98, alpha: 1.00)))
                           }
                           
                       }.frame(width: screenWidth-20, height: 335, alignment: .center)
                           .background(Color(UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 0.90))).cornerRadius(20)
                   }.frame(width:  screenWidth, height: screenHeight).background(Color(UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 0.30)
                                                                            
))
               }
           }.offset(y:-30).frame(width: screenWidth, height: screenHeight, alignment: .center)
           
       
       
   }.frame(width: screenWidth, height: screenHeight, alignment: .center).background(Color.white).onReceive(timer){_ in
        if motionsRecording {
                MyMotion()
        }else {
            print("Accelerometer is stopping")
            motion.stopAccelerometerUpdates()
            motion.stopGyroUpdates()
        }
    }
    
    }
};



struct DuoGame: View {
    var body: some View {
        AccelerometerViewDuo()
    }
}

struct DuoGame_Previews: PreviewProvider {
    static var previews: some View {
        DuoGame()
    }
}
