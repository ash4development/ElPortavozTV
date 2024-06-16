import SwiftUI
import Nuke

extension Encodable {
    func toJson(encoder: JSONEncoder = JSONEncoder())throws -> Any {
        let data = try toData(encoder: encoder)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json
    }
    func toData(encoder: JSONEncoder = JSONEncoder())throws -> Data
    {
        let data = try encoder.encode(self)
        return data
    }
}
extension Decodable {
    static func objectFrom(json: Any, decoder: JSONDecoder = JSONDecoder())throws -> Self? {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        return try decoder.decode(Self.self, from: data)
    }
    static func objectFrom(data: Data, decoder: JSONDecoder =  JSONDecoder())throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
}
class GradientOverlayImageView: UIImageView {
    private lazy var  linear1: CAGradientLayer = {
        let l = CAGradientLayer()
        l.type = .axial

        l.colors = [ UIColor.clear.cgColor,
                     UIColor.black.withAlphaComponent(0.7).cgColor,
                     UIColor.black.cgColor]
        l.locations = [ 0,0.5 , 1]
        l.startPoint = CGPoint(x: 1, y: 1)
        l.endPoint = CGPoint(x: 0.0, y: 0)
        layer.addSublayer(l)
        return l
    }()
    override func layoutSubviews() {
        super.layoutSubviews()
        linear1.frame = bounds
    }
}
extension UIImageView {
    func loadRemote(url: URL, completion: @escaping (Bool, UIImage?) -> Void) {
        ImagePipeline.shared.loadData(with: url, completion: { result in
            switch result {
            case .success(let success):
                let image = UIImage(data: success.data)
                DispatchQueue.main.async {
                    completion(true, image)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(false, nil)
                }
            }
        })
    }
}

extension UIView {

    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
}
