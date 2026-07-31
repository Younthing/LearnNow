import Foundation
import LearnNowContentKit
import SwiftUI

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

struct LessonScreen: View {
    let model: LessonScreenModel
    let onBack: () -> Void
    let onSelectPage: (Int) -> Void
    let onAnswer: (String, String) -> Void
    let onRetryExercise: (String) -> Void
    let onCallToAction: (LearnNowLessonCallToAction) -> Void

    private var selectionBinding: Binding<Int> {
        Binding(
            get: { model.currentPageIndex },
            set: { onSelectPage($0) }
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = LearnNowSpacing.screenHorizontal(for: geometry.size.width)

            VStack(spacing: 18) {
                LessonTopBar(
                    title: model.title,
                    horizontalPadding: horizontalPadding,
                    onBack: onBack
                )

                LessonSegments(count: model.pageCount, currentIndex: model.currentPageIndex)
                    .padding(.horizontal, horizontalPadding)
                    .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
                    .frame(maxWidth: .infinity)

                TabView(selection: selectionBinding) {
                    ForEach(Array(model.pages.enumerated()), id: \.element.id) { index, page in
                        LessonPageView(
                            page: page,
                            horizontalPadding: horizontalPadding,
                            onAnswer: onAnswer,
                            onRetryExercise: onRetryExercise,
                            onCallToAction: onCallToAction
                        )
                        .tag(index)
                    }
                }
                .learnNowLessonTabStyle()
            }
        }
        .accessibilityIdentifier("screen.lesson")
    }
}

private extension View {
    @ViewBuilder
    func learnNowLessonTabStyle() -> some View {
#if os(macOS)
        self
#else
        tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
}

private struct LessonTopBar: View {
    let title: String
    let horizontalPadding: CGFloat
    let onBack: () -> Void

    var body: some View {
        HStack {
            CircleIconButton(systemImage: "arrow.left", role: .brand, action: onBack)
            Spacer()
            Text(title)
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("lesson.title")
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.top, LearnNowSpacing.screenTop)
        .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
        .frame(maxWidth: .infinity)
    }
}

private struct LessonSegments: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(LearnNowPalette.base)
                        .frame(height: index == currentIndex ? 7 : 6)
                        .softOuter(radius: 4, x: 2, y: 2)

                    Capsule()
                        .fill(LearnNowSemanticRole.brandGradient)
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: index == currentIndex ? 7 : 6,
                            alignment: .leading
                        )
                        .opacity(index <= currentIndex ? 1 : 0)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct LessonPageView: View {
    let page: LessonScreenModel.Page
    let horizontalPadding: CGFloat
    let onAnswer: (String, String) -> Void
    let onRetryExercise: (String) -> Void
    let onCallToAction: (LearnNowLessonCallToAction) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                LessonHeroSection(page: page)

                LessonBlockList(
                    blocks: page.blocks,
                    exercisesByID: page.exercisesByID,
                    contentRootURL: page.contentRootURL,
                    onAnswer: onAnswer,
                    onRetryExercise: onRetryExercise
                )

                if let action = page.callToAction {
                    FullWidthButton(
                        title: action.title,
                        accent: action.accent,
                        action: { onCallToAction(action.kind) }
                    )
                    .accessibilityIdentifier("lesson.cta")
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, 12)
            .padding(.bottom, 30)
            .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct LessonHeroSection: View {
    let page: LessonScreenModel.Page

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            MetadataChip(text: page.badge, accent: page.accent)
            Text(page.title)
                .font(LearnNowTypography.sheetTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct LessonBlockList: View {
    let blocks: [LessonContentBlock]
    let exercisesByID: [String: LessonScreenModel.Exercise]
    let contentRootURL: URL?
    let onAnswer: (String, String) -> Void
    let onRetryExercise: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                LessonContentBlockView(
                    block: block,
                    exercisesByID: exercisesByID,
                    contentRootURL: contentRootURL,
                    onAnswer: onAnswer,
                    onRetryExercise: onRetryExercise
                )
            }
        }
    }
}

private struct LessonContentBlockView: View {
    let block: LessonContentBlock
    let exercisesByID: [String: LessonScreenModel.Exercise]
    let contentRootURL: URL?
    let onAnswer: (String, String) -> Void
    let onRetryExercise: (String) -> Void

    @ViewBuilder
    var body: some View {
        switch block {
        case let .paragraph(content):
            InlineContentText(content: content)
                .font(LearnNowTypography.body)
                .foregroundStyle(LearnNowPalette.textSecondary)
                .lineSpacing(6)

        case let .heading(level, content):
            InlineContentText(content: content)
                .font(headingFont(level: level))
                .foregroundStyle(LearnNowPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

        case let .list(ordered, items):
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(ordered ? "\(index + 1)." : "•")
                            .font(LearnNowTypography.label)
                            .foregroundStyle(LearnNowSemanticRole.brand.foreground)
                        InlineContentText(content: item.content)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textSecondary)
                    }
                }
            }

        case let .callout(title, tone, accent, body):
            ContentCalloutCard(
                title: title,
                tone: tone,
                accent: LearnNowAccent(accent)
            ) {
                LessonBlockList(
                    blocks: body,
                    exercisesByID: exercisesByID,
                    contentRootURL: contentRootURL,
                    onAnswer: onAnswer,
                    onRetryExercise: onRetryExercise
                )
            }

        case let .code(language, code):
            CodeSampleCard(language: language, code: code)

        case let .table(header, rows, columnAlignments):
            LessonTableCard(
                header: header,
                rows: rows,
                columnAlignments: columnAlignments
            )

        case let .image(path, alt, caption):
            ContentImageCard(
                path: path,
                alt: alt,
                caption: caption,
                contentRootURL: contentRootURL
            )

        case let .singleChoice(exerciseID):
            if let exercise = exercisesByID[exerciseID] {
                LessonExerciseView(
                    exercise: exercise,
                    onAnswer: { optionID in onAnswer(exerciseID, optionID) },
                    onRetry: { onRetryExercise(exerciseID) }
                )
            }
        }
    }

    private func headingFont(level: Int) -> Font {
        switch level {
        case ...1: LearnNowTypography.sheetTitle
        case 2: LearnNowTypography.sectionTitle
        default: LearnNowTypography.cardTitle
        }
    }
}

private struct LessonExerciseView: View {
    let exercise: LessonScreenModel.Exercise
    let onAnswer: (String) -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("随堂练习", systemImage: "square.and.pencil")
                .font(LearnNowTypography.sectionTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            InlineContentText(content: exercise.prompt)
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(LearnNowPalette.textSecondary)
                .lineSpacing(4)

            ForEach(exercise.options) { option in
                LessonOptionButton(option: option) {
                    onAnswer(option.id)
                }
                .accessibilityIdentifier("lesson.option.\(option.id)")
            }

            if let feedback = exercise.feedback {
                FeedbackCard(feedback: feedback)
            }

            if exercise.showsRetry {
                FullWidthButton(title: "重新思考", accent: nil, action: onRetry)
                    .accessibilityIdentifier("lesson.retry.\(exercise.id)")
            }
        }
        .padding(.top, 10)
    }
}

private struct LessonOptionButton: View {
    let option: LessonScreenModel.Option
    let action: () -> Void

    @ScaledMetric(relativeTo: .subheadline) private var badgeSize: CGFloat = 34

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                InsetCircle(size: badgeSize) {
                    Text(option.badge)
                        .font(LearnNowTypography.label)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                InlineContentText(content: option.content)
                    .font(LearnNowTypography.label)
                    .foregroundStyle(labelColor)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                if let statusIcon {
                    Image(systemName: statusIcon)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(labelColor)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .softOuter(radius: 10, x: 5, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!option.isEnabled)
    }

    private var borderColor: Color {
        switch option.presentation {
        case .correct: LearnNowSemanticRole.brand.foreground
        case .incorrect: LearnNowSemanticRole.danger.foreground
        case .normal: .clear
        }
    }

    private var borderWidth: CGFloat {
        option.presentation == .normal ? 0 : 2
    }

    private var labelColor: Color {
        switch option.presentation {
        case .correct: LearnNowSemanticRole.brand.foreground
        case .incorrect: LearnNowSemanticRole.danger.foreground
        case .normal: LearnNowPalette.textSecondary
        }
    }

    private var statusIcon: String? {
        switch option.presentation {
        case .correct: "checkmark.circle.fill"
        case .incorrect: "xmark.circle.fill"
        case .normal: nil
        }
    }
}

private struct FeedbackCard: View {
    let feedback: LearnNowLessonFeedback

    var body: some View {
        InsetCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(feedback.title)
                    .font(LearnNowTypography.cardTitle)
                    .foregroundStyle(LearnNowPalette.color(for: feedback.accent))
                InlineContentText(content: feedback.body)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .lineSpacing(4)
            }
        }
    }
}

private struct ContentCalloutCard<Content: View>: View {
    let title: String
    let tone: ContentTone
    let accent: LearnNowAccent
    @ViewBuilder let content: Content

    init(
        title: String,
        tone: ContentTone,
        accent: LearnNowAccent,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.tone = tone
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        InsetCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Label(title, systemImage: systemImage)
                    .font(LearnNowTypography.label)
                    .foregroundStyle(LearnNowPalette.color(for: accent))
                content
            }
        }
    }

    private var systemImage: String {
        switch tone {
        case .information: "lightbulb.fill"
        case .success: "checkmark.seal.fill"
        case .warning: "exclamationmark.triangle.fill"
        }
    }
}

private struct CodeSampleCard: View {
    let language: String?
    let code: String

    var body: some View {
        InsetCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 10) {
                if let language, !language.isEmpty {
                    MetadataChip(text: language, accent: .purple)
                }
                // Diagrams rely on monospace column alignment. Soft-wrapping a line
                // mid-Chinese-word (or mid-arrow row) destroys the drawing — same as
                // the broken "输入 / 处理 / 输出" slab. Keep each source line intact
                // and scroll horizontally when the phone is narrower than the drawing.
                ScrollView(.horizontal, showsIndicators: true) {
                    Text(code)
                        .font(LearnNowTypography.body.monospaced())
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

private struct LessonTableCard: View {
    let header: [TableCell]
    let rows: [[TableCell]]
    let columnAlignments: [LearnNowContentKit.TableColumnAlignment?]?

    @ScaledMetric(relativeTo: .body) private var minimumColumnWidth: CGFloat = 96

    var body: some View {
        InsetCard(contentPadding: 12) {
            ScrollView(.horizontal, showsIndicators: true) {
                Grid(alignment: .topLeading, horizontalSpacing: 12, verticalSpacing: 0) {
                    GridRow {
                        ForEach(Array(header.enumerated()), id: \.offset) { column, cell in
                            cellView(
                                cell,
                                column: column,
                                rowLabel: nil,
                                isHeader: true
                            )
                        }
                    }

                    ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                        Divider()
                            .gridCellColumns(max(header.count, 1))

                        GridRow {
                            ForEach(Array(row.enumerated()), id: \.offset) { column, cell in
                                cellView(
                                    cell,
                                    column: column,
                                    rowLabel: rowIndex + 1,
                                    isHeader: false
                                )
                            }
                        }
                    }
                }
                .frame(minWidth: minimumTableWidth, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        }
        .accessibilityElement(children: .contain)
    }

    private var minimumTableWidth: CGFloat {
        CGFloat(max(header.count, 1)) * minimumColumnWidth
    }

    private func alignment(for column: Int) -> TextAlignment {
        guard let columnAlignments, column < columnAlignments.count else {
            return .leading
        }
        switch columnAlignments[column] {
        case .center?:
            return .center
        case .right?:
            return .trailing
        case .left?, nil:
            return .leading
        }
    }

    private func frameAlignment(for column: Int) -> Alignment {
        switch alignment(for: column) {
        case .center:
            .center
        case .trailing:
            .trailing
        default:
            .leading
        }
    }

    @ViewBuilder
    private func cellView(
        _ cell: TableCell,
        column: Int,
        rowLabel: Int?,
        isHeader: Bool
    ) -> some View {
        let plain = cell.content.map(\.plainText).joined()
        let headerPlain = column < header.count
            ? header[column].content.map(\.plainText).joined()
            : ""
        let label: String = {
            if isHeader {
                return "表头，第 \(column + 1) 列，\(plain)"
            }
            let row = rowLabel ?? 1
            if headerPlain.isEmpty {
                return "第 \(row) 行，第 \(column + 1) 列，\(plain)"
            }
            return "第 \(row) 行，第 \(column + 1) 列，表头 \(headerPlain)，\(plain)"
        }()

        InlineContentText(content: cell.content)
            .font(isHeader ? LearnNowTypography.label : LearnNowTypography.body)
            .foregroundStyle(
                isHeader ? LearnNowPalette.textPrimary : LearnNowPalette.textSecondary
            )
            .multilineTextAlignment(alignment(for: column))
            .frame(
                minWidth: minimumColumnWidth,
                maxWidth: .infinity,
                alignment: frameAlignment(for: column)
            )
            .padding(.vertical, 10)
            .accessibilityLabel(label)
            .accessibilityAddTraits(isHeader ? .isHeader : [])
    }
}

private struct ContentImageCard: View {
    let path: String
    let alt: String
    let caption: [InlineContent]?
    let contentRootURL: URL?

    var body: some View {
        InsetCard(contentPadding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                LocalContentImage(path: path, alt: alt, contentRootURL: contentRootURL)
                if let caption {
                    InlineContentText(content: caption)
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }
            }
        }
    }
}

private struct LocalContentImage: View {
    let path: String
    let alt: String
    let contentRootURL: URL?

    var body: some View {
        Group {
#if canImport(AppKit)
            if let url = resourceURL, let image = NSImage(contentsOf: url) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
            }
#elseif canImport(UIKit)
            if let url = resourceURL, let image = UIImage(contentsOfFile: url.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                placeholder
            }
#else
            placeholder
#endif
        }
        .accessibilityLabel(alt)
    }

    private var resourceURL: URL? {
        if let contentRootURL, let candidate = safeContentURL(root: contentRootURL) {
            return candidate
        }
        if let exact = Bundle.main.url(forResource: path, withExtension: nil) {
            return exact
        }
        let value = path as NSString
        let directory = value.deletingLastPathComponent
        let file = value.lastPathComponent as NSString
        return Bundle.main.url(
            forResource: file.deletingPathExtension,
            withExtension: file.pathExtension.isEmpty ? nil : file.pathExtension,
            subdirectory: directory.isEmpty ? nil : directory
        )
    }

    private func safeContentURL(root: URL) -> URL? {
        guard !path.hasPrefix("/"),
              !path.split(separator: "/").contains("..")
        else { return nil }
        let standardizedRoot = root.standardizedFileURL
        let candidate = standardizedRoot.appendingPathComponent(path).standardizedFileURL
        let rootPrefix = standardizedRoot.path.hasSuffix("/")
            ? standardizedRoot.path
            : standardizedRoot.path + "/"
        guard candidate.path.hasPrefix(rootPrefix) else { return nil }
        return FileManager.default.fileExists(atPath: candidate.path) ? candidate : nil
    }

    private var placeholder: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo")
                .font(.largeTitle)
            Text(alt)
                .font(LearnNowTypography.screenSubtitle)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(LearnNowPalette.textMuted)
        .frame(maxWidth: .infinity, minHeight: 140)
    }
}

#Preview("Lesson") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        LessonScreen(
            model: LearnNowFlowState.lessonPreview.lessonScreenModel,
            onBack: {},
            onSelectPage: { _ in },
            onAnswer: { _, _ in },
            onRetryExercise: { _ in },
            onCallToAction: { _ in }
        )
    }
}
