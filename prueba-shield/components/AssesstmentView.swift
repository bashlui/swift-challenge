import SwiftUI

// MARK: - Home Assessment View
struct AssessmentView: View {
    @State private var currentScore: Int = 0
    @State private var showingResults = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackground()
                
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "house.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(DesignSystem.primaryBlue)
                        
                        Text("Evaluación Térmica del Hogar")
                            .font(DesignSystem.title2())
                            .foregroundColor(DesignSystem.primaryText)
                            .multilineTextAlignment(.center)
                        
                        Text("Analiza la preparación de tu hogar contra el calor extremo")
                            .font(DesignSystem.body())
                            .foregroundColor(DesignSystem.textGray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, DesignSystem.padding)
                    
                    if !showingResults {
                        QuizView(onComplete: { score in
                            currentScore = score
                            showingResults = true
                        })
                    } else {
                        ResultsView(score: currentScore, onReset: {
                            showingResults = false
                            currentScore = 0
                        })
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Energy Explanation Helper
struct EnergyExplanation {
    let icon: String
    let color: Color
    let title: String
    let description: String
}

extension ResultsView {
    private func getEnergyExplanations(score: Int) -> [EnergyExplanation] {
        let missingPoints = 16 - score
        var explanations: [EnergyExplanation] = []
        
        // Explicaciones basadas en qué tan baja es la puntuación
        if missingPoints >= 8 { // Score muy bajo (0-8)
            explanations.append(EnergyExplanation(
                icon: "thermometer.sun.fill",
                color: .red,
                title: "Sobrecalentamiento del hogar",
                description: "Sin aislamiento y protección solar, tu hogar absorbe calor excesivo, forzando al AC a trabajar constantemente."
            ))
        }
        
        if missingPoints >= 6 { // Score bajo-medio (0-10)
            explanations.append(EnergyExplanation(
                icon: "wind",
                color: DesignSystem.primaryBlue,
                title: "Ventilación deficiente",
                description: "La falta de ventilación cruzada obliga a usar aire acondicionado incluso cuando el exterior está fresco."
            ))
        }
        
        if missingPoints >= 4 { // Score medio (0-12)
            explanations.append(EnergyExplanation(
                icon: "sun.max.fill",
                color: .orange,
                title: "Ganancia solar directa",
                description: "Ventanas sin protección y superficies oscuras aumentan la temperatura interior hasta 10°C más."
            ))
        }
        
        if missingPoints >= 2 { // Score alto pero no perfecto (0-14)
            explanations.append(EnergyExplanation(
                icon: "house.fill",
                color: .green,
                title: "Optimización térmica",
                description: "Pequeñas mejoras en aislamiento y sombra pueden generar ahorros significativos a largo plazo."
            ))
        }
        
        return explanations
    }
    
    private func calculateMonthlySavings(score: Int) -> Int {
        let missingPoints = 16 - score
        let percentageSavings = missingPoints * 15
        
        // Estimación basada en factura eléctrica promedio en México ($1,500-3,000 MXN/mes)
        let averageElectricBill = 2250 // MXN
        let acPercentageOfBill = 0.6 // 60% de la factura suele ser AC en climas calurosos
        
        let acCost = Double(averageElectricBill) * acPercentageOfBill
        let savings = acCost * (Double(percentageSavings) / 100.0)
        
        return Int(savings)
    }
}

// MARK: - Quiz View
struct QuizView: View {
    @State private var answers: [Int] = Array(repeating: -1, count: 8)
    let onComplete: (Int) -> Void
    
    let questions = [
        ("¿Tu techo es de color claro o tiene material reflectante?", "Los techos claros pueden reducir hasta 30% del calor interior"),
        ("¿Tienes ventilación cruzada en tu hogar?", "Aberturas en lados opuestos permiten que el aire circule naturalmente"),
        ("¿Usas cortinas térmicas o persianas que bloqueen el sol?", "Pueden reducir hasta 77% del calor que entra por ventanas"),
        ("¿Tienes árboles o estructuras que den sombra a tu casa?", "La sombra puede reducir la temperatura exterior hasta 9°C"),
        ("¿Cuentas con aislamiento térmico en paredes y techo?", "El aislamiento mantiene temperaturas interiores estables"),
        ("¿Tienes ventiladores de techo o aire acondicionado?", "Mejoran la circulación y reducen la sensación térmica"),
        ("¿Las ventanas tienen doble vidrio o película solar?", "Reducen significativamente la transferencia de calor"),
        ("¿Mantienes cerradas puertas y ventanas durante el día?", "Evita que entre aire caliente del exterior")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Question Cards
                questionCards
                
                // Progress Indicator
                progressIndicator
                
                // Results Button
                resultsButton
                
                Spacer(minLength: 20)
            }
        }
    }
    
    private var questionCards: some View {
        ForEach(0..<questions.count, id: \.self) { index in
            CardView {
                VStack(alignment: .leading, spacing: 16) {
                    questionHeader(for: index)
                    answerButtons(for: index)
                }
            }
            .padding(.horizontal, DesignSystem.padding)
        }
    }
    
    private func questionHeader(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pregunta \(index + 1) de \(questions.count)")
                .font(DesignSystem.caption())
                .foregroundColor(DesignSystem.textGray)
            
            Text(questions[index].0)
                .font(DesignSystem.headline())
                .foregroundColor(DesignSystem.primaryText)
                .fontWeight(.medium)
            
            Text(questions[index].1)
                .font(DesignSystem.caption())
                .foregroundColor(DesignSystem.textGray)
                .italic()
        }
    }
    
    private func answerButtons(for index: Int) -> some View {
        HStack(spacing: 12) {
            AnswerButton(
                title: "Sí",
                isSelected: answers[index] == 2,
                color: DesignSystem.primaryBlue
            ) {
                answers[index] = 2
            }
            
            AnswerButton(
                title: "Parcial",
                isSelected: answers[index] == 1,
                color: DesignSystem.secondaryBlue
            ) {
                answers[index] = 1
            }
            
            AnswerButton(
                title: "No",
                isSelected: answers[index] == 0,
                color: DesignSystem.textGray
            ) {
                answers[index] = 0
            }
        }
    }
    
    private var progressIndicator: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(0..<questions.count, id: \.self) { index in
                    Circle()
                        .fill(answers[index] != -1 ? DesignSystem.primaryBlue : DesignSystem.borderGray)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text("\(answers.filter { $0 != -1 }.count) de \(questions.count) completadas")
                .font(DesignSystem.caption())
                .foregroundColor(DesignSystem.textGray)
        }
        .padding()
    }
    
    private var resultsButton: some View {
        PrimaryButton(title: "Ver Resultados") {
            let totalScore = answers.reduce(0, +)
            onComplete(totalScore)
        }
        .disabled(answers.contains(-1))
        .opacity(answers.contains(-1) ? 0.6 : 1.0)
        .padding(.horizontal, DesignSystem.padding)
    }
}

struct AnswerButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DesignSystem.body())
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? color : DesignSystem.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(color, lineWidth: 1.5)
                        )
                )
        }
    }
}

// MARK: - Results View
struct ResultsView: View {
    let score: Int
    let onReset: () -> Void
    
    var scoreLevel: (String, Color, String, [String], String) {
        switch score {
        case 14...16:
            return ("Excelente", DesignSystem.primaryBlue, "Tu hogar está óptimamente preparado contra el calor extremo",
                   ["Mantén las mejoras actuales", "Considera automatización domótica", "Evalúa sistemas de energía solar"],
                   "🏆")
        case 10...13:
            return ("Muy Bueno", DesignSystem.secondaryBlue, "Tu hogar tiene muy buena preparación térmica",
                   ["Optimiza horarios de ventilación", "Considera mejorar aislamiento", "Evalúa cortinas térmicas adicionales"],
                   "⭐")
        case 6...9:
            return ("Bueno", DesignSystem.accentBlue, "Tu hogar tiene preparación moderada",
                   ["Instala cortinas térmicas", "Mejora la ventilación cruzada", "Considera pintar el techo de blanco", "Planta árboles estratégicamente"],
                   "👍")
        case 3...5:
            return ("Necesita mejoras", DesignSystem.textGray, "Tu hogar requiere adaptaciones importantes",
                   ["Prioriza aislamiento térmico", "Instala ventiladores de techo", "Usa cortinas reflectantes", "Pinta superficies de colores claros", "Mejora ventilación"],
                   "⚠️")
        case 0...2:
            return ("Crítico", Color.red, "Tu hogar necesita adaptaciones urgentes",
                   ["Aislamiento térmico inmediato", "Instalación de aire acondicionado", "Cortinas térmicas en todas las ventanas", "Ventilación forzada", "Techos reflectantes", "Sombra con árboles o toldos"],
                   "🚨")
        default: return ("", DesignSystem.textGray, "", [], "")
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Score Display
                CardView {
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .stroke(DesignSystem.borderGray, lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(score) / 16.0)
                                .stroke(scoreLevel.1, lineWidth: 8)
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.5), value: score)
                            
                            VStack(spacing: 4) {
                                Text(scoreLevel.4)
                                    .font(.title)
                                Text("\(score)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(DesignSystem.primaryText)
                                Text("/ 16")
                                    .font(DesignSystem.caption())
                                    .foregroundColor(DesignSystem.textGray)
                            }
                        }
                        
                        VStack(spacing: 8) {
                            Text(scoreLevel.0)
                                .font(DesignSystem.title2())
                                .fontWeight(.semibold)
                                .foregroundColor(scoreLevel.1)
                            
                            Text(scoreLevel.2)
                                .font(DesignSystem.body())
                                .foregroundColor(DesignSystem.textGray)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Efficiency percentage
                        HStack {
                            Text("Eficiencia térmica:")
                                .font(DesignSystem.body())
                                .foregroundColor(DesignSystem.textGray)
                            Text("\(Int((Double(score) / 16.0) * 100))%")
                                .font(DesignSystem.body())
                                .fontWeight(.bold)
                                .foregroundColor(scoreLevel.1)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.padding)
                
                // Recommendations
                if !scoreLevel.3.isEmpty {
                    CardView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(DesignSystem.primaryBlue)
                                
                                Text("Plan de Mejoras Recomendado")
                                    .font(DesignSystem.headline())
                                    .foregroundColor(DesignSystem.primaryText)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(Array(scoreLevel.3.enumerated()), id: \.offset) { index, tip in
                                    HStack(alignment: .top, spacing: 12) {
                                        Text("\(index + 1)")
                                            .font(DesignSystem.caption())
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .frame(width: 24, height: 24)
                                            .background(
                                                LinearGradient(
                                                    colors: [DesignSystem.primaryBlue, DesignSystem.secondaryBlue],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .clipShape(Circle())
                                        
                                        Text(tip)
                                            .font(DesignSystem.body())
                                            .foregroundColor(DesignSystem.primaryText)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.padding)
                }
                
                // Energy savings estimation
                if score < 14 {
                    CardView {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("Potencial de Ahorro")
                                    .font(DesignSystem.headline())
                                    .foregroundColor(DesignSystem.primaryText)
                                Spacer()
                            }
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Reducción de temperatura:")
                                        .font(DesignSystem.caption())
                                        .foregroundColor(DesignSystem.textGray)
                                    Text("Hasta \(16 - score) °C")
                                        .font(DesignSystem.body())
                                        .fontWeight(.bold)
                                        .foregroundColor(DesignSystem.primaryBlue)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Ahorro energético:")
                                        .font(DesignSystem.caption())
                                        .foregroundColor(DesignSystem.textGray)
                                    Text("Hasta \((16 - score) * 15)%")
                                        .font(DesignSystem.body())
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            // Nueva explicación del por qué del ahorro
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.orange)
                                    Text("¿Por qué este ahorro?")
                                        .font(DesignSystem.body())
                                        .fontWeight(.semibold)
                                        .foregroundColor(DesignSystem.primaryText)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    let explanations = getEnergyExplanations(score: score)
                                    ForEach(Array(explanations.enumerated()), id: \.offset) { index, explanation in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: explanation.icon)
                                                .font(.caption)
                                                .foregroundColor(explanation.color)
                                                .frame(width: 16)
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(explanation.title)
                                                    .font(DesignSystem.caption())
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(DesignSystem.primaryText)
                                                
                                                Text(explanation.description)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(DesignSystem.textGray)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            
                                            Spacer()
                                        }
                                        .padding(.vertical, 2)
                                    }
                                }
                                
                                // Cálculo detallado
                                HStack {
                                    Image(systemName: "calculator")
                                        .foregroundColor(DesignSystem.primaryBlue)
                                    Text("Cálculo estimado:")
                                        .font(DesignSystem.caption())
                                        .fontWeight(.semibold)
                                        .foregroundColor(DesignSystem.primaryText)
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("• Cada mejora térmica reduce ~15% el uso de climatización")
                                        .font(.system(size: 10))
                                        .foregroundColor(DesignSystem.textGray)
                                    Text("• Temperaturas más frescas = menor tiempo de AC encendido")
                                        .font(.system(size: 10))
                                        .foregroundColor(DesignSystem.textGray)
                                    Text("• Ahorro promedio: $\(calculateMonthlySavings(score: score)) MXN/mes")
                                        .font(.system(size: 10))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.top, 8)
                            .padding(12)
                            .background(DesignSystem.lightGray)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, DesignSystem.padding)
                }
                
                // Action Button
                PrimaryButton(title: "Nueva Evaluación") {
                    onReset()
                }
                .padding(.horizontal, DesignSystem.padding)
                
                Spacer(minLength: 20)
            }
        }
    }
}
