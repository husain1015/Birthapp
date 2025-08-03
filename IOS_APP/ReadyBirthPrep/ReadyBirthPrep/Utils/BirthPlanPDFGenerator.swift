import UIKit
import PDFKit

class BirthPlanPDFGenerator {
    
    // MARK: - Colors
    private let primaryColor = UIColor(red: 236/255, green: 72/255, blue: 153/255, alpha: 1.0) // Pink
    private let secondaryColor = UIColor(red: 147/255, green: 51/255, blue: 234/255, alpha: 1.0) // Purple
    private let accentColor = UIColor(red: 248/255, green: 113/255, blue: 113/255, alpha: 1.0) // Light Red
    private let backgroundColor = UIColor(red: 252/255, green: 231/255, blue: 243/255, alpha: 1.0) // Light Pink
    private let textColor = UIColor(red: 31/255, green: 41/255, blue: 55/255, alpha: 1.0) // Dark Gray
    
    // MARK: - Fonts
    private let titleFont = UIFont.systemFont(ofSize: 32, weight: .bold)
    private let headerFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    private let subheaderFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    private let bodyFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    private let captionFont = UIFont.systemFont(ofSize: 10, weight: .light)
    
    // MARK: - Page Setup
    private let pageWidth: CGFloat = 8.5 * 72.0
    private let pageHeight: CGFloat = 11 * 72.0
    private let margin: CGFloat = 50
    private var currentY: CGFloat = 0
    
    func generatePDF(for birthPlan: BirthPlan, userName: String) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: AppConstants.clinicName,
            kCGPDFContextAuthor: userName,
            kCGPDFContextTitle: "My Birth Plan"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            currentY = margin
            
            // Draw header with gradient background
            drawHeader(context: context, userName: userName)
            
            // Draw sections
            drawEnvironmentSection(context: context, environment: birthPlan.environment)
            
            if needNewPage() { 
                context.beginPage()
                currentY = margin
            }
            
            drawSupportTeamSection(context: context, supportPeople: birthPlan.supportPeople)
            
            if needNewPage() {
                context.beginPage()
                currentY = margin
            }
            
            drawPainManagementSection(context: context, preferences: birthPlan.painManagement)
            
            if needNewPage() {
                context.beginPage()
                currentY = margin
            }
            
            drawLaborPositionsSection(context: context, positions: birthPlan.laboringPositions)
            
            if needNewPage() {
                context.beginPage()
                currentY = margin
            }
            
            drawNewbornCareSection(context: context, preferences: birthPlan.newbornProcedures)
            
            if !birthPlan.customPreferences.isEmpty {
                if needNewPage() {
                    context.beginPage()
                    currentY = margin
                }
                drawCustomPreferencesSection(context: context, preferences: birthPlan.customPreferences)
            }
            
            // Draw footer on last page
            drawFooter(context: context)
        }
        
        return data
    }
    
    // MARK: - Header
    private func drawHeader(context: UIGraphicsPDFRendererContext, userName: String) {
        let headerHeight: CGFloat = 150
        
        // Draw gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: pageWidth, height: headerHeight)
        gradientLayer.colors = [primaryColor.cgColor, secondaryColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: currentContext)
            let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            gradientImage?.draw(in: CGRect(x: 0, y: 0, width: pageWidth, height: headerHeight))
        }
        
        // Draw title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: titleFont,
            .foregroundColor: UIColor.white
        ]
        
        let title = "My Birth Plan"
        let titleSize = title.size(withAttributes: titleAttributes)
        let titleRect = CGRect(
            x: (pageWidth - titleSize.width) / 2,
            y: 40,
            width: titleSize.width,
            height: titleSize.height
        )
        title.draw(in: titleRect, withAttributes: titleAttributes)
        
        // Draw user name
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        
        let nameText = userName
        let nameSize = nameText.size(withAttributes: nameAttributes)
        let nameRect = CGRect(
            x: (pageWidth - nameSize.width) / 2,
            y: titleRect.maxY + 10,
            width: nameSize.width,
            height: nameSize.height
        )
        nameText.draw(in: nameRect, withAttributes: nameAttributes)
        
        // Draw date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateText = dateFormatter.string(from: Date())
        let dateSize = dateText.size(withAttributes: nameAttributes)
        let dateRect = CGRect(
            x: (pageWidth - dateSize.width) / 2,
            y: nameRect.maxY + 5,
            width: dateSize.width,
            height: dateSize.height
        )
        dateText.draw(in: dateRect, withAttributes: nameAttributes)
        
        currentY = headerHeight + 30
    }
    
    // MARK: - Environment Section
    private func drawEnvironmentSection(context: UIGraphicsPDFRendererContext, environment: BirthEnvironment) {
        drawSectionHeader(title: "Environment Preferences", icon: "🏠")
        
        var items: [(String, String)] = []
        items.append(("Lighting", environment.lighting.rawValue))
        items.append(("Temperature", environment.temperature.rawValue))
        items.append(("Visitors", environment.visitors.rawValue))
        
        if environment.music {
            items.append(("Music", environment.musicPlaylist ?? "Yes"))
        }
        
        if environment.aromatherapy {
            items.append(("Aromatherapy", "Yes"))
        }
        
        drawInfoGrid(items: items)
        currentY += 20
    }
    
    // MARK: - Support Team Section
    private func drawSupportTeamSection(context: UIGraphicsPDFRendererContext, supportPeople: [SupportPerson]) {
        drawSectionHeader(title: "Support Team", icon: "👥")
        
        for person in supportPeople {
            drawPersonCard(person: person)
        }
        
        currentY += 20
    }
    
    private func drawPersonCard(person: SupportPerson) {
        let cardHeight: CGFloat = 60
        let cardRect = CGRect(x: margin, y: currentY, width: pageWidth - (margin * 2), height: cardHeight)
        
        // Draw card background
        let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 10)
        backgroundColor.setFill()
        cardPath.fill()
        
        // Draw person icon
        let iconRect = CGRect(x: margin + 15, y: currentY + 15, width: 30, height: 30)
        drawCircleIcon(in: iconRect, text: String(person.name.prefix(1)), backgroundColor: primaryColor)
        
        // Draw person details
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: subheaderFont,
            .foregroundColor: textColor
        ]
        
        let detailsX = iconRect.maxX + 15
        person.name.draw(at: CGPoint(x: detailsX, y: currentY + 12), withAttributes: nameAttributes)
        
        let detailsAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: UIColor.gray
        ]
        
        let details = "\(person.relationship) • \(person.role)"
        details.draw(at: CGPoint(x: detailsX, y: currentY + 32), withAttributes: detailsAttributes)
        
        currentY += cardHeight + 10
    }
    
    // MARK: - Pain Management Section
    private func drawPainManagementSection(context: UIGraphicsPDFRendererContext, preferences: PainManagementPreferences) {
        drawSectionHeader(title: "Pain Management", icon: "💊")
        
        // Natural methods
        if !preferences.naturalMethods.isEmpty {
            drawSubheader(title: "Natural Methods")
            
            let columns = 2
            let itemWidth = (pageWidth - (margin * 2) - 20) / CGFloat(columns)
            var currentX = margin
            var row = 0
            
            for (index, method) in preferences.naturalMethods.enumerated() {
                if index > 0 && index % columns == 0 {
                    row += 1
                    currentX = margin
                    currentY += 40
                }
                
                drawCheckItem(
                    text: method.rawValue,
                    x: currentX,
                    y: currentY,
                    width: itemWidth
                )
                
                currentX += itemWidth + 20
            }
            
            currentY += 50
        }
        
        // Medical preferences
        drawSubheader(title: "Medical Preferences")
        drawInfoBox(
            title: "Epidural",
            value: preferences.epiduralPreference.rawValue,
            color: colorForEpidural(preferences.epiduralPreference)
        )
        
        currentY += 20
    }
    
    // MARK: - Labor Positions Section
    private func drawLaborPositionsSection(context: UIGraphicsPDFRendererContext, positions: [LaborPosition]) {
        drawSectionHeader(title: "Preferred Labor Positions", icon: "🤸‍♀️")
        
        let iconSize: CGFloat = 60
        let spacing: CGFloat = 20
        let columns = 3
        let totalWidth = pageWidth - (margin * 2)
        let itemWidth = (totalWidth - (spacing * CGFloat(columns - 1))) / CGFloat(columns)
        
        var currentX = margin
        var row = 0
        
        for (index, position) in positions.enumerated() {
            if index > 0 && index % columns == 0 {
                row += 1
                currentX = margin
                currentY += iconSize + 30
            }
            
            // Draw position card
            _ = CGRect(x: currentX, y: currentY, width: itemWidth, height: iconSize + 25)
            
            // Icon background
            let iconRect = CGRect(
                x: currentX + (itemWidth - iconSize) / 2,
                y: currentY,
                width: iconSize,
                height: iconSize
            )
            
            let iconPath = UIBezierPath(roundedRect: iconRect, cornerRadius: iconSize / 2)
            accentColor.withAlphaComponent(0.2).setFill()
            iconPath.fill()
            
            // Position icon
            drawPositionIcon(position: position, in: iconRect)
            
            // Position name
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: captionFont,
                .foregroundColor: textColor
            ]
            
            let nameRect = CGRect(
                x: currentX,
                y: iconRect.maxY + 5,
                width: itemWidth,
                height: 20
            )
            
            position.rawValue.draw(
                in: nameRect,
                withAttributes: nameAttributes + [.paragraphStyle: centeredParagraphStyle()]
            )
            
            currentX += itemWidth + spacing
        }
        
        currentY += iconSize + 50
    }
    
    // MARK: - Newborn Care Section
    private func drawNewbornCareSection(context: UIGraphicsPDFRendererContext, preferences: NewbornPreferences) {
        drawSectionHeader(title: "Newborn Care", icon: "👶")
        
        var items: [(String, String, Bool)] = []
        items.append(("Immediate skin-to-skin", preferences.immediateSkintToSkin ? "Yes" : "No", preferences.immediateSkintToSkin))
        items.append(("Delayed cord clamping", preferences.delayedCordClamping ? "Yes" : "No", preferences.delayedCordClamping))
        items.append(("Vitamin K", preferences.vitaminK.rawValue, preferences.vitaminK == .yes))
        items.append(("Eye ointment", preferences.eyeOintment ? "Yes" : "No", preferences.eyeOintment))
        items.append(("Hepatitis B vaccine", preferences.hepatitisB ? "Yes" : "No", preferences.hepatitisB))
        items.append(("Feeding preference", preferences.feeding.rawValue, true))
        
        drawPreferencesList(items: items)
        currentY += 20
    }
    
    // MARK: - Custom Preferences Section
    private func drawCustomPreferencesSection(context: UIGraphicsPDFRendererContext, preferences: [CustomPreference]) {
        drawSectionHeader(title: "Additional Preferences", icon: "📝")
        
        let grouped = Dictionary(grouping: preferences, by: { $0.category })
        
        for (category, prefs) in grouped.sorted(by: { $0.key < $1.key }) {
            drawSubheader(title: category)
            
            for pref in prefs {
                drawCustomPreferenceItem(preference: pref)
            }
            
            currentY += 10
        }
    }
    
    // MARK: - Footer
    private func drawFooter(context: UIGraphicsPDFRendererContext) {
        let footerY = pageHeight - 80
        
        // Draw separator line
        let separatorPath = UIBezierPath()
        separatorPath.move(to: CGPoint(x: margin, y: footerY))
        separatorPath.addLine(to: CGPoint(x: pageWidth - margin, y: footerY))
        UIColor.lightGray.setStroke()
        separatorPath.lineWidth = 0.5
        separatorPath.stroke()
        
        // Draw clinic info
        let clinicAttributes: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: UIColor.gray
        ]
        
        let clinicText = "\(AppConstants.clinicName) • \(AppConstants.clinicPhone)"
        let clinicSize = clinicText.size(withAttributes: clinicAttributes)
        clinicText.draw(
            at: CGPoint(x: (pageWidth - clinicSize.width) / 2, y: footerY + 10),
            withAttributes: clinicAttributes
        )
        
        let addressText = AppConstants.clinicAddress
        let addressSize = addressText.size(withAttributes: clinicAttributes)
        addressText.draw(
            at: CGPoint(x: (pageWidth - addressSize.width) / 2, y: footerY + 25),
            withAttributes: clinicAttributes
        )
        
        // Draw creation date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let dateText = "Created on \(dateFormatter.string(from: Date()))"
        let dateSize = dateText.size(withAttributes: clinicAttributes)
        dateText.draw(
            at: CGPoint(x: (pageWidth - dateSize.width) / 2, y: footerY + 40),
            withAttributes: clinicAttributes
        )
    }
    
    // MARK: - Helper Methods
    private func drawSectionHeader(title: String, icon: String) {
        let headerHeight: CGFloat = 50
        let headerRect = CGRect(x: margin - 10, y: currentY, width: pageWidth - (margin * 2) + 20, height: headerHeight)
        
        // Draw background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = headerRect
        gradientLayer.colors = [primaryColor.withAlphaComponent(0.1).cgColor, secondaryColor.withAlphaComponent(0.1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.cornerRadius = 10
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            gradientLayer.render(in: currentContext)
            let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            gradientImage?.draw(in: headerRect)
        }
        
        // Draw icon
        let iconAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24)
        ]
        icon.draw(at: CGPoint(x: margin, y: currentY + 13), withAttributes: iconAttributes)
        
        // Draw title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: headerFont,
            .foregroundColor: textColor
        ]
        title.draw(at: CGPoint(x: margin + 40, y: currentY + 15), withAttributes: titleAttributes)
        
        currentY += headerHeight + 15
    }
    
    private func drawSubheader(title: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: subheaderFont,
            .foregroundColor: secondaryColor
        ]
        title.draw(at: CGPoint(x: margin, y: currentY), withAttributes: attributes)
        currentY += 25
    }
    
    private func drawInfoGrid(items: [(String, String)]) {
        let columns = 2
        let spacing: CGFloat = 20
        let totalWidth = pageWidth - (margin * 2)
        let itemWidth = (totalWidth - spacing) / CGFloat(columns)
        
        var currentX = margin
        var row = 0
        
        for (index, item) in items.enumerated() {
            if index > 0 && index % columns == 0 {
                row += 1
                currentX = margin
                currentY += 60
            }
            
            drawInfoCard(
                title: item.0,
                value: item.1,
                x: currentX,
                y: currentY,
                width: itemWidth
            )
            
            currentX += itemWidth + spacing
        }
        
        currentY += 60
    }
    
    private func drawInfoCard(title: String, value: String, x: CGFloat, y: CGFloat, width: CGFloat) {
        let cardHeight: CGFloat = 50
        let cardRect = CGRect(x: x, y: y, width: width, height: cardHeight)
        
        // Draw card background
        let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 8)
        UIColor.white.setFill()
        cardPath.fill()
        
        primaryColor.withAlphaComponent(0.2).setStroke()
        cardPath.lineWidth = 1
        cardPath.stroke()
        
        // Draw title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: UIColor.gray
        ]
        title.draw(at: CGPoint(x: x + 10, y: y + 8), withAttributes: titleAttributes)
        
        // Draw value
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: textColor
        ]
        value.draw(at: CGPoint(x: x + 10, y: y + 25), withAttributes: valueAttributes)
    }
    
    private func drawCheckItem(text: String, x: CGFloat, y: CGFloat, width: CGFloat) {
        // Draw checkmark
        let checkColor = UIColor.systemGreen
        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: x + 5, y: y + 12))
        checkmarkPath.addLine(to: CGPoint(x: x + 10, y: y + 17))
        checkmarkPath.addLine(to: CGPoint(x: x + 20, y: y + 7))
        checkColor.setStroke()
        checkmarkPath.lineWidth = 2
        checkmarkPath.stroke()
        
        // Draw text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: textColor
        ]
        
        let textRect = CGRect(x: x + 30, y: y, width: width - 35, height: 30)
        text.draw(in: textRect, withAttributes: textAttributes)
    }
    
    private func drawInfoBox(title: String, value: String, color: UIColor) {
        let boxHeight: CGFloat = 40
        let boxRect = CGRect(x: margin, y: currentY, width: pageWidth - (margin * 2), height: boxHeight)
        
        // Draw background
        let boxPath = UIBezierPath(roundedRect: boxRect, cornerRadius: 8)
        color.withAlphaComponent(0.1).setFill()
        boxPath.fill()
        
        // Draw title and value
        let attributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: textColor
        ]
        
        "\(title): ".draw(at: CGPoint(x: margin + 15, y: currentY + 12), withAttributes: attributes)
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: subheaderFont,
            .foregroundColor: color
        ]
        
        value.draw(at: CGPoint(x: margin + 80, y: currentY + 10), withAttributes: valueAttributes)
        
        currentY += boxHeight + 10
    }
    
    private func drawPreferencesList(items: [(String, String, Bool)]) {
        for item in items {
            let iconColor = item.2 ? UIColor.systemGreen : UIColor.systemOrange
            
            // Draw icon
            let iconRect = CGRect(x: margin, y: currentY, width: 20, height: 20)
            let iconPath = UIBezierPath(ovalIn: iconRect)
            iconColor.withAlphaComponent(0.2).setFill()
            iconPath.fill()
            
            let checkPath = UIBezierPath()
            if item.2 {
                checkPath.move(to: CGPoint(x: margin + 5, y: currentY + 10))
                checkPath.addLine(to: CGPoint(x: margin + 8, y: currentY + 13))
                checkPath.addLine(to: CGPoint(x: margin + 15, y: currentY + 6))
            } else {
                checkPath.move(to: CGPoint(x: margin + 6, y: currentY + 6))
                checkPath.addLine(to: CGPoint(x: margin + 14, y: currentY + 14))
                checkPath.move(to: CGPoint(x: margin + 14, y: currentY + 6))
                checkPath.addLine(to: CGPoint(x: margin + 6, y: currentY + 14))
            }
            iconColor.setStroke()
            checkPath.lineWidth = 2
            checkPath.stroke()
            
            // Draw text
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: textColor
            ]
            
            "\(item.0): ".draw(at: CGPoint(x: margin + 30, y: currentY + 2), withAttributes: textAttributes)
            
            let valueAttributes: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .foregroundColor: iconColor
            ]
            
            item.1.draw(at: CGPoint(x: margin + 180, y: currentY + 2), withAttributes: valueAttributes)
            
            currentY += 25
        }
    }
    
    private func drawCustomPreferenceItem(preference: CustomPreference) {
        let importance = preference.importance
        let importanceColor = importance == .mustHave ? UIColor.systemRed :
                            importance == .prefer ? UIColor.systemOrange :
                            UIColor.systemGreen
        
        // Draw importance indicator
        let indicatorRect = CGRect(x: margin, y: currentY + 5, width: 4, height: 20)
        let indicatorPath = UIBezierPath(roundedRect: indicatorRect, cornerRadius: 2)
        importanceColor.setFill()
        indicatorPath.fill()
        
        // Draw preference text
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: bodyFont,
            .foregroundColor: textColor
        ]
        
        let textRect = CGRect(x: margin + 15, y: currentY, width: pageWidth - margin - 100, height: 30)
        preference.preference.draw(in: textRect, withAttributes: textAttributes)
        
        // Draw importance label
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: captionFont,
            .foregroundColor: importanceColor
        ]
        
        let labelRect = CGRect(x: pageWidth - margin - 80, y: currentY + 5, width: 70, height: 20)
        importance.rawValue.draw(in: labelRect, withAttributes: labelAttributes)
        
        currentY += 35
    }
    
    private func drawCircleIcon(in rect: CGRect, text: String, backgroundColor: UIColor) {
        let circlePath = UIBezierPath(ovalIn: rect)
        backgroundColor.setFill()
        circlePath.fill()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let size = text.size(withAttributes: attributes)
        let drawRect = CGRect(
            x: rect.origin.x + (rect.width - size.width) / 2,
            y: rect.origin.y + (rect.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        
        text.draw(in: drawRect, withAttributes: attributes)
    }
    
    private func drawPositionIcon(position: LaborPosition, in rect: CGRect) {
        let icon: String
        switch position {
        case .standing: icon = "🚶‍♀️"
        case .handsKnees: icon = "🐈"
        case .birtingBall: icon = "⚪"
        case .squatting: icon = "🏋️‍♀️"
        case .sideLying: icon = "🛌"
        case .semiReclined: icon = "🪑"
        case .waterBirth: icon = "💧"
        }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 30)
        ]
        
        let size = icon.size(withAttributes: attributes)
        let drawPoint = CGPoint(
            x: rect.origin.x + (rect.width - size.width) / 2,
            y: rect.origin.y + (rect.height - size.height) / 2
        )
        
        icon.draw(at: drawPoint, withAttributes: attributes)
    }
    
    private func colorForEpidural(_ preference: EpiduralPreference) -> UIColor {
        switch preference {
        case .definitely: return .systemGreen
        case .probably: return .systemBlue
        case .openToDiscuss: return .systemOrange
        case .preferNot: return .systemOrange
        case .definitelyNot: return .systemRed
        }
    }
    
    private func centeredParagraphStyle() -> NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return style
    }
    
    private func needNewPage() -> Bool {
        return currentY > pageHeight - 150
    }
}

// MARK: - Dictionary Extension
extension Dictionary where Key == NSAttributedString.Key, Value == Any {
    static func + (lhs: [NSAttributedString.Key: Any], rhs: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var result = lhs
        for (key, value) in rhs {
            result[key] = value
        }
        return result
    }
}