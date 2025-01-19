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
        // 使用UIScreen的scale来获取实际的物理像素密度
        let scale = UIScreen.main.scale
        // 1英寸 = 2.54厘米
        // 1英寸 = 72点 (标准PT单位)
        return 72.0 * scale / 2.54  // 根据设备实际像素密度计算
    }
    
    // 根据设备计算最大可显示长度
    private var rulerLength: CGFloat {
        // 获取设备屏幕的实际尺寸
        let screenWidth = UIScreen.main.bounds.width  // 使用宽度而不是高度
        let screenHeight = UIScreen.main.bounds.height
        // 使用较长的一边作为尺子的长度
        let maxLength = max(screenWidth, screenHeight)
        // 考虑边距，留出一些空间
        let availableLength = maxLength - 40 // 减去左右各20点的边距
        // 转换为厘米并向下取整
        return floor(availableLength / pointsPerCm)
    }
    
    private let majorTickInterval: CGFloat = 1.0
    private let minorTickCount: Int = 10
    
    var distance: CGFloat {
        abs(rightCursor - leftCursor)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let cmToPoints = pointsPerCm
            
            VStack(spacing: -120) {
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
                .frame(width: rulerLength * cmToPoints, height: 300)
                
                // 修改信息显示部分
                VStack(spacing: 0) {
                    // 主测量距离
                    Text(String(format: "测量距离: %.1f 厘米", distance))
                        .font(.title2)
                        .bold()
                        .foregroundColor(.blue)
                        .padding(.bottom, 0)
                        .padding(.horizontal, 12) // 将水平内边距从16改为12
                        .padding(.vertical, 12) // 添加垂直内边距
                    
                    // 添加额外的间距
                    Spacer().frame(height: 12) // 将间距从4改为12，整体向下偏移
                    
                    // 详细信息
                    VStack(spacing: 4) {
                        HStack(spacing: 20) {
                            InfoItem(title: "起点", value: String(format: "%.1f cm", leftCursor))
                            InfoItem(title: "终点", value: String(format: "%.1f cm", rightCursor))
                        }
                        
                        HStack(spacing: 20) {
                            InfoItem(title: "精确度", value: "0.1 cm")
                            InfoItem(title: "量程", value: "\(Int(rulerLength)) cm")
                        }
                    }
                    .padding(.horizontal, 12) // 将水平内边距从16改为12
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 15) // 增加圆角
                            .fill(Color.white) // 使用白色背景
                            .shadow(color: .gray.opacity(0.4), radius: 6, x: 0, y: 4) // 增加阴影效果
                    )
                }
                .padding(.top, 0)
                .padding(.leading, 8) // 添加左侧偏移
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
                path.addRoundedRect(in: CGRect(x: -10, y: 0, width: size.width + 20, height: 100), cornerSize: CGSize(width: 20, height: 20))
            }
            context.fill(background, with: .linearGradient(
                Gradient(colors: [Color(white: 0.95), Color(white: 0.98)]),
                startPoint: CGPoint(x: 0, y: 0),
                endPoint: CGPoint(x: 0, y: 100)
            ))
            
            // 添加边框阴影效果
            context.stroke(
                Path { path in
                    path.addRoundedRect(in: CGRect(x: -10, y: 0, width: size.width + 20, height: 100), cornerSize: CGSize(width: 20, height: 20))
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
                    path.addLine(to: CGPoint(x: x, y: 50))
                }
                context.stroke(majorTick,
                    with: .linearGradient(
                        Gradient(colors: [.blue.opacity(0.8), .blue.opacity(0.4)]),
                        startPoint: CGPoint(x: x, y: 0),
                        endPoint: CGPoint(x: x, y: 50)
                    ),
                    lineWidth: 1.5
                )
                
                // 添加数字
                let text = Text("\(cm)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue.opacity(0.8))
                context.draw(text, at: CGPoint(x: x - 5, y: 60))
                
                // 绘制小刻度
                if cm < Int(rulerLength) {
                    for minor in 1..<minorTickCount {
                        let minorX = x + (CGFloat(minor) * cmToPoints / CGFloat(minorTickCount))
                        let tickHeight: CGFloat
                        
                        // 修改刻度高度逻辑
                        switch minor {
                        case 5: // 5毫米刻度
                            tickHeight = 40
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
                        case 2, 4, 6, 8: // 偶数毫米刻度
                            tickHeight = 30
                            let minorTick = Path { path in
                                path.move(to: CGPoint(x: minorX, y: 0))
                                path.addLine(to: CGPoint(x: minorX, y: tickHeight))
                            }
                            context.stroke(minorTick,
                                with: .linearGradient(
                                    Gradient(colors: [.blue.opacity(0.4), .blue.opacity(0.2)]),
                                    startPoint: CGPoint(x: minorX, y: 0),
                                    endPoint: CGPoint(x: minorX, y: tickHeight)
                                ),
                                lineWidth: 0.8
                            )
                        default: // 奇数毫米刻度
                            tickHeight = 25
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
            // 使用圆角矩形作为游标主体
            RoundedRectangle(cornerRadius: 8) // 圆角矩形
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.8), .blue.opacity(0.6)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 8, height: 250) // 增加宽度
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2) // 添加阴影效果
            
            // 圆形指示器
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 16, height: 16) // 增加圆形的大小
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2) // 添加阴影效果
                .offset(y: -8) // 将圆圈的偏移量调整为负值，使其位于游标顶部
            
            Text(String(format: "%.1f", position))
                .font(.system(size: 14, weight: .medium)) // 增加字体大小
                .foregroundColor(.blue)
                .padding(.top, 4)
        }
    }
}

// 添加新的信息展示组件
struct InfoItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    ContentView()
}
