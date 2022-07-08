import UIKit

protocol Convertible {
    var sourceTitle: String { get }
    var convertedTitle: String { get }
    func convert(value: Double) -> Double
}

enum Distance: Double {
    case kilometer = 1.0
    case mile = 1.6

    var title: String {
        switch self {
        case .kilometer: return "Kilometers"
        case .mile: return "Miles"
        }
    }
}

enum Weight: Double {
    case kilogram = 1.0
    case pound = 0.45359237

    var title: String {
        switch self {
        case .kilogram: return "Kilograms"
        case .pound: return "Pounds"
        }
    }
}

struct DistanceConverter: Convertible {
    private let source: Distance
    private let destination: Distance

    var sourceTitle: String {
        source.title
    }

    var convertedTitle: String {
        destination.title
    }

    init(from source: Distance, to destination: Distance) {
        self.source = source
        self.destination = destination
    }

    func convert(value: Double) -> Double {
        var factor = source.rawValue * destination.rawValue
        if source.rawValue < destination.rawValue {
            factor = source.rawValue / destination.rawValue
        }

        return value * factor
    }
}

struct MassConverter: Convertible {
    private let source: Weight
    private let destination: Weight

    var sourceTitle: String {
        source.title
    }

    var convertedTitle: String {
        destination.title
    }

    init(from source: Weight, to destination: Weight) {
        self.source = source
        self.destination = destination
    }

    func convert(value: Double) -> Double {
        var factor = source.rawValue * destination.rawValue
        if source.rawValue > destination.rawValue {
            factor = source.rawValue / destination.rawValue
        }

        return value * factor
    }
}

class Model {

    enum ConverterType {
        case mass
        case distance
    }

    var convertible: Convertible = DistanceConverter(from: .kilometer, to: .mile)

    var sourceTitle: String {
        convertible.sourceTitle
    }
    var destinationTitle: String {
        convertible.convertedTitle
    }

    private var type: ConverterType = .distance
    private var reversed = false

    init() {
        milesToKilometerConvertion()
    }

    func convert(value: String) -> String {
        guard let number = Double(value) else {
            return ""
        }

        return String(convertible.convert(value: number))
    }

    func changeConvertion() {
        reversed.toggle()

        switch type {
        case .mass:
            poundsToKilogramConvertion()
        case .distance:
            milesToKilometerConvertion()
        }
    }

    func milesToKilometerConvertion() {
        let source: Distance = reversed ? .mile : .kilometer
        let destination: Distance = reversed ? .kilometer: .mile
        type = .distance
        convertible = DistanceConverter(from: source, to: destination)
    }

    func poundsToKilogramConvertion() {
        let source: Weight = reversed ? .pound : .kilogram
        let destination: Weight = reversed ? .kilogram : .pound
        type = .mass
        convertible = MassConverter(from: source, to: destination)
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var configButton: UIButton!

    var model = Model()

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
        setupButtons()
        firstTextField.delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.becomeFirstResponder()
    }

    @IBAction func change(sender: UIButton) {
        model.changeConvertion()
        updateLabels()
        convert()
    }

    @IBAction func config(sender: UIButton) {
        showMeasurementOptions()
    }

    private func convert() {
        secondTextField.text = model.convert(value: firstTextField.text ?? "")
    }

    private func updateLabels() {
        firstLabel.text = model.sourceTitle
        secondLabel.text = model.destinationTitle
    }

    private func setupButtons() {
        setupButton(changeButton)
        setupButton(configButton)
    }

    private func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = changeButton.bounds.height / 2.0
        button.layer.masksToBounds = true

        button.layer.shadowRadius = 3.0
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = .init(width: 0, height: 3)
        button.layer.shadowOpacity = 0.4
        button.layer.masksToBounds = false
    }

    private func showMeasurementOptions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(
            .init(
                title: "Miles and Kilometers",
                style: .default,
                handler: { [weak self] _ in
                    self?.model.milesToKilometerConvertion()
                    self?.updateLabels()
                    self?.convert()
                }
            )
        )

        actionSheet.addAction(
            .init(
                title: "Pounds to Kilograms",
                style: .default,
                handler: { [weak self] _ in
                    self?.model.poundsToKilogramConvertion()
                    self?.updateLabels()
                    self?.convert()
                }
            )
        )

        present(actionSheet, animated: true)
    }

}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        firstTextField.text = newText
        convert()
        return false
    }
}
