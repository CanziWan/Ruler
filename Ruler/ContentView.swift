//
//  ContentView.swift
//  Ruler
//
//  Created by Canzi on 2025/1/20.
//

import SwiftUI

struct ContentView: View {
    @State private var leftCursor: CGFloat = 3.0
    @State private var rightCursor: CGFloat = 5.0
    
    // 计算每厘米对应的点数
    private var pointsPerCm: CGFloat {
        // 1英寸 = 2.54厘米
        // 1英寸 = 96点
        return 96.0 / 2.54  // 约等于 37.795275591 点/厘米
    }
    
    // 根据设备计算最大可显示长度
    private var rulerLength: CGFloat {
        let screenWidth = UIScreen.main.bounds.height // 横屏时使用高度值
        return floor(screenWidth / pointsPerCm) // 转换为厘米并向下取整
    }
    
    private let majorTickInterval: CGFloat = 1.0
    private let minorTickCount: Int = 10
    
    var distance: CGFloat {
        abs(rightCursor - leftCursor)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let cmToPoints = pointsPerCm
            
            VStack(spacing: 20) {
                // 尺子刻度
                ZStack(alignment: .top) {
                    RulerView(rulerLength: rulerLength,
                             majorTickInterval: majorTickInterval,
                             minorTickCount: minorTickCount,
                             width: rulerLength * cmToPoints,
                             cmToPoints: cmToPoints)
                    
                    // 左游标
                    RulerCursor(position: leftCursor)
                        .position(x: leftCursor * cmToPoints, y: 0)
                        .gesture(DragGesture()
                            .onChanged { value in
                                let newPosition = value.location.x / cmToPoints
                                if newPosition >= 0 && newPosition < rightCursor {
                                    leftCursor = newPosition
                                }
                            })
                    
                    // 右游标
                    RulerCursor(position: rightCursor)
                        .position(x: rightCursor * cmToPoints, y: 0)
                        .gesture(DragGesture()
                            .onChanged { value in
                                let newPosition = value.location.x / cmToPoints
                                if newPosition <= rulerLength && newPosition > leftCursor {
                                    rightCursor = newPosition
                                }
                            })
                }
                .frame(width: rulerLength * cmToPoints, height: 200)
                
                // 显示距离
                Text(String(format: "%.1f cm", distance))
                    .font(.title)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}

struct RulerView: View {
    let rulerLength: CGFloat
    let majorTickInterval: CGFloat
    let minorTickCount: Int
    let width: CGFloat
    let cmToPoints: CGFloat
    
    var body: some View {
        Canvas { context, size in
            // 绘制尺子背景
            let background = Path { path in
                path.addRect(CGRect(x: -10, y: 0, width: size.width + 20, height: 60))
            }
            context.fill(background, with: .linearGradient(
                Gradient(colors: [Color(white: 0.95), Color(white: 0.98)]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: 60)
            ))
            
            // 添加边框阴影效果
            context.stroke(
                Path { path in
                    path.addRect(CGRect(x: -10, y: 0, width: size.width + 20, height: 60))
                },
                with: .color(.gray.opacity(0.3)),
                lineWidth: 1
            )
            
            // 添加装饰线条
            context.stroke(
                Path { path in
                    path.move(to: CGPoint(x: -10, y: 5))
                    path.addLine(to: CGPoint(x: size.width + 10, y: 5))
                },
                with: .color(.blue.opacity(0.2)),
                lineWidth: 0.5
            )
            
            for cm in 0...Int(rulerLength) {
                let x = CGFloat(cm) * cmToPoints
                
                // 绘制大刻度
                let majorTick = Path { path in
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: 35))
                }
                context.stroke(majorTick,
                    with: .linearGradient(
                        Gradient(colors: [.blue.opacity(0.8), .blue.opacity(0.4)]),
                        startPoint: CGPoint(x: x, y: 0),
                        endPoint: CGPoint(x: x, y: 35)
                    ),
                    lineWidth: 1.5
                )
                
                // 添加数字
                let text = Text("\(cm)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue.opacity(0.8))
                context.draw(text, at: CGPoint(x: x - 5, y: 45))
                
                // 绘制小刻度
                if cm < Int(rulerLength) {
                    for minor in 1..<minorTickCount {
                        let minorX = x + (CGFloat(minor) * cmToPoints / CGFloat(minorTickCount))
                        let tickHeight: CGFloat
                        
                        if minor == 5 {
                            tickHeight = 25
                            let mediumTick = Path { path in
                                path.move(to: CGPoint(x: minorX, y: 0))
                                path.addLine(to: CGPoint(x: minorX, y: tickHeight))
                            }
                            context.stroke(mediumTick,
                                with: .linearGradient(
                                    Gradient(colors: [.blue.opacity(0.6), .blue.opacity(0.3)]),
                                    startPoint: CGPoint(x: minorX, y: 0),
                                    endPoint: CGPoint(x: minorX, y: tickHeight)
                                ),
                                lineWidth: 1.0
                            )
                        } else {
                            tickHeight = 15
                            let minorTick = Path { path in
                                path.move(to: CGPoint(x: minorX, y: 0))
                                path.addLine(to: CGPoint(x: minorX, y: tickHeight))
                            }
                            context.stroke(minorTick,
                                with: .linearGradient(
                                    Gradient(colors: [.blue.opacity(0.4), .blue.opacity(0.1)]),
                                    startPoint: CGPoint(x: minorX, y: 0),
                                    endPoint: CGPoint(x: minorX, y: tickHeight)
                                ),
                                lineWidth: 0.8
                            )
                        }
                    }
                }
            }
            
            // 添加底线
            let baseline = Path { path in
                path.move(to: CGPoint(x: -10, y: 0))
                path.addLine(to: CGPoint(x: size.width + 10, y: 0))
            }
            context.stroke(baseline,
                with: .linearGradient(
                    Gradient(colors: [.blue.opacity(0.8), .blue.opacity(0.6)]),
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: size.width, y: 0)
                ),
                lineWidth: 2
            )
        }
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct RulerCursor: View {
    var position: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .blue.opacity(0.6)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4, height: 140)
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 12, height: 12)
                        .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        .offset(y: 70)
                )
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            
            Text(String(format: "%.1f", position))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.blue)
                .padding(.top, 4)
        }
    }
}

#Preview {
    ContentView()
}
