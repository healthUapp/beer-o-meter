//
//  ContentView.swift
//  simpleGraph
//
//  Created by User on 11.04.22.
//

import SwiftUI
import CoreMotion
import CoreGraphics

struct AccelerometerViewDuo: View {
    let screenHeight = UIScreen.screenHeight
    let screenWidth = UIScreen.screenWidth
    
    
    
    //Состояние записи работы акселерометра и гироскопа
    @State private var motionsRecording: Bool = true
    @State private var alertStatus: Bool = false
    @State private var gameProsecc: Bool = true
    
    
    
    @State private var pourBeer:Bool = false
    @State private var pourOut:Bool = false

    @State private var missedBeer:Double = 0
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
    let noBeerY:Double = 0
    let deadValue:Double = 0
    let updateFrequency:Double = 0.02
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    let waterDelay = 6

    func MyMotion(){
        self.beerOpacity = 150/(abs(accelY) + (missedBeer/10))
        
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
        
        self.leftBeerY = accelX + noBeerY + missedBeer + accelY
        self.centerBeerY = (abs(gyroZ)/4) + abs(accelX/2) + noBeerY + missedBeer + accelY
        self.rightBeerY = -accelX  + noBeerY + missedBeer + accelY
        
        self.foamHeight = 40 - (missedBeer/15)

        if(pourOut){
            self.missedBeer += 50
            self.pourOut = missedBeer > 250 ? false : true
        }
        
        if(missedBeer > 250 - deadValue || accelY < -195){
            if(missedBeer < 1000 && !pourBeer){
                self.missedBeer += 10 + gyroZ/20
            }
            self.alertStatus = true
        }

        if(leftBeerY < 0 || rightBeerY < 0){
            missedBeer += 0.03 * (abs(accelY * 3) + abs(accelX))
        }
        
        if(pourBeer){
            missedBeer -= 3
            if(missedBeer < 1){
                self.alertStatus = false
                self.pourBeer = false
            }
        }


       
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
                   
               }.frame(width: 187, height:255, alignment: .center)
               
                   .alert("Pour some more?", isPresented: $alertStatus) {
                       Button("YES!", role: .cancel) {
                           self.missedBeer = 300
                           self.alertStatus = false
                           self.pourBeer = true
                       }

                   }
               
               Image("BeerGlass").resizable().frame(width: 400, height: 420)
               
               VStack{
                   if(pourBeer){
                       Text("Pouring" + self.dots).font(.title).fontWeight(.semibold).padding(.vertical, 20)
                   }else{
                       Text("\(self.missedBeer < 250 ? Int((1-(self.missedBeer/250))*100) :0)%")
                           .font(.largeTitle)
                           .fontWeight(.semibold)
                       
                   }
               }.padding(.vertical,20)
           }.frame(width: screenWidth, height: screenHeight, alignment: .center)
           
           
       
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
