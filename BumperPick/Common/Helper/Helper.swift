//
//  Helper.swift
//  BumperPick
//
//  Created by tauseef hussain on 09/06/25.
//

//
import SwiftUI
import AVKit

struct DosaBadgeShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16

        var path = Path()

        // Start from top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))

        // Line to just before top-right corner
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))

        // Rounded top-right corner
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                    radius: radius,
                    startAngle: .degrees(-90),
                    endAngle: .degrees(45), // 🧠 stop early to create a tilted curve
                    clockwise: false)

        // Smooth curve to bottom-right using quad curve
        path.addQuadCurve(to: CGPoint(x: rect.maxX - 12, y: rect.maxY - 4),
                          control: CGPoint(x: rect.maxX + 4, y: rect.midY + 10))

        // Line to bottom-left
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Close shape
        path.closeSubpath()

        return path
    }
}


struct RightTopRoundedBottomDiagonalShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16

        var path = Path()
        path.move(to: rect.origin) // top-left
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY)) // top edge
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                    radius: radius,
                    startAngle: Angle(degrees: -90),
                    endAngle: Angle(degrees: 0),
                    clockwise: false) // rounded top-right corner

        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 10)) // vertical right edge
        path.addLine(to: CGPoint(x: rect.maxX - 10, y: rect.maxY)) // diagonal cut
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY)) // bottom-left edge
        path.closeSubpath()

        return path
    }
}


struct RightSideRoundedShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16 // 16
        var path = Path()

        path.move(to: rect.origin)
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                    radius: radius,
                    startAngle: Angle(degrees: -90), //-90
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

//MARK: detect if a OfferCardView is visible on screen. its helps us to play or stop video
struct ViewVisibilityModifier: ViewModifier {
    let onVisibilityChanged: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            checkVisibility(geometry: geometry)
                        }
                        .onChange(of: geometry.frame(in: .global)) { _ in
                            checkVisibility(geometry: geometry)
                        }
                }
            )
    }

    private func checkVisibility(geometry: GeometryProxy) {
        let frame = geometry.frame(in: .global)
        let screenHeight = UIScreen.main.bounds.height
        let visible = frame.minY < screenHeight && frame.maxY > 0
        onVisibilityChanged(visible)
    }
}

extension View {
    func onVisibilityChanged(_ action: @escaping (Bool) -> Void) -> some View {
        self.modifier(ViewVisibilityModifier(onVisibilityChanged: action))
    }
}

//MARK: genratimg image from url
func loadImageFromURLString(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }.resume()
}

 func covertdateFormateFromString(from string: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd" // adjust this to match your backend format
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.date(from: string)
}

//MARK: load image from url
func loadImageFromURL(_ url: URL, completion: @escaping (UIImage?) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }.resume()
}

//MARK: genrate thumbnail from url video
func generateVideoThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
    DispatchQueue.global().async {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        let time = CMTime(seconds: 1, preferredTimescale: 60)

        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                completion(thumbnail)
            }
        } catch {
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}

// convert Date into string
 func dateFormatted(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    return formatter.string(from: date)
}

//Convert date formate
func convertDateFormate(_ input: String, _ inputFormat: String, _ outputFormat: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = inputFormat

    guard let date = formatter.date(from: input) else {
        return input // return original if parsing fails
    }

    formatter.dateFormat = outputFormat
    return formatter.string(from: date)
}

 func copyToLocalIfNeeded(_ originalURL: URL) -> URL? {
    let fileCoordinator = NSFileCoordinator()
    var error: NSError?

    let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
    let localURL = tempDir.appendingPathComponent(originalURL.lastPathComponent)

    if FileManager.default.fileExists(atPath: localURL.path) {
        return localURL // Already copied before
    }

    var resultURL: URL?
    fileCoordinator.coordinate(readingItemAt: originalURL, options: [], error: &error) { url in
        do {
            let data = try Data(contentsOf: url)
            try data.write(to: localURL)
            resultURL = localURL
        } catch {
            print("❌ Error copying file locally: \(error)")
        }
    }

    if let error = error {
        print("❌ File coordination error:", error.localizedDescription)
    }

    return resultURL
}


//MARK: generate video url
struct VideoPickerTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { receivedFile in
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(receivedFile.file.pathExtension)

            try FileManager.default.copyItem(at: receivedFile.file, to: tempURL)
            return VideoPickerTransferable(url: tempURL)
        }
    }
}

//MARK: add dotted devider line
struct DashedDivider: View {
    var color: Color = .gray.opacity(0.5)
    var dash: [CGFloat] = [5]
    var lineWidth: CGFloat = 1

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geometry.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: dash))
            .foregroundColor(color)
        }
        .frame(height: lineWidth)
    }
}


// MARK: - Share Sheet Helper for sharing app
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

//MARK: commonHeader we can use it anywher
struct CustomHeaderView: View {
    let title: String
    var showBackButton: Bool = false
    var onBack: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if showBackButton {
                    Button(action: {
                        onBack?()
                    }) {
                        Image("back")
                            .foregroundColor(.black)
                            .font(.system(size: 17, weight: .semibold))
                            .padding(8)
                    }
                }

                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.leading, showBackButton ? 0 : 8)

                Spacer()
            }
            .padding(.top, topSafeAreaInset())
            .padding(.bottom, 12)
            .padding(.horizontal)

            Divider()
                .background(Color.gray.opacity(0.1))
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private func topSafeAreaInset() -> CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first }
            .first

        return window?.safeAreaInsets.top ?? 20
    }
}

//MARK: custom label with *
struct CustomLabel: View {
    let text: String
    let required: Bool

    init(_ text: String, required: Bool = false) {
        self.text = text
        self.required = required
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
            if required {
                Text(" *")
                    .foregroundColor(appThemeRedColor)
                    .font(.subheadline)
            }
        }
    }
}

//MARK: this we are using setting option empty like  ?? "" just called by value.bound
extension Optional where Wrapped == String {
    var bound: String {
        get { self ?? "" }
        set { self = newValue }
    }
}
