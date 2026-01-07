import Foundation

public enum NetworkError: Error {
    case badURL
    case invalidResponse
    case decodingError
}

public class TCGDex {
    
    private let baseURL = "https://api.tcgdex.net/v2/en"
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    public init() {
        decoder.dateDecodingStrategy = .iso8601
    }
    
    public func cards() async throws -> [CardBrief] {
        return try await fetch("/cards")
    }
    
    public func card(id: String) async throws -> CardType? {
        return try await fetch("/cards/\(id)")
    }
    
    public func set(id: String) async throws -> Set? {
        return try await fetch("/sets/\(id)")
    }
    
    public func sets() async throws -> [SetBrief] {
        return try await fetch("/sets")
    }
    
    public func serie(id: String) async throws -> Serie? {
        return try await fetch("/series/\(id)")
    }
    
    public func series() async throws -> [SerieBrief] {
        return try await fetch("/series")
    }
    
    
    private func fetch<T: Decodable>(_ endpoint: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw NetworkError.badURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print(error)
            
            throw NetworkError.decodingError
        }
    }
    
}

public struct Serie : Codable, Identifiable {
    public let id: String
    public let logo: String
    public let name: String
    public let sets: [SetBrief]
}


public struct SetBrief: Codable, Sendable, Identifiable  {
    public let id: String
    public let name: String
    public let logo: String?
    public let cardCount: SetBriefCardCount
}

public struct SetBriefCardCount : Codable, Sendable {
    public let total: Int
    public let official: Int
}

public struct Legal: Codable, Sendable {
    public let expanded: Bool
    public let standard: Bool
}

public struct Set: Codable, Sendable, Identifiable {
    public let cardCount: SetCardCount
    public let cards: [CardBrief]
    public let id: String
    public let logo: String
    public let legal: Legal
    public let name: String
    public let releaseDate: String
    public let serie: SerieBrief
    public let symbol: String
}

public struct SerieBrief: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
}

public struct SetCardCount : Codable, Sendable {
    public let firstEd: Int
    public let holo: Int
    public let normal: Int
    public let official: Int
    public let reverse: Int
    public let total: Int
}

public struct CardBrief: Codable, Sendable, Identifiable {
    public let id: String
    public let localId: String
    public let name: String
    public let image: String?
}

public enum CardType: Decodable, Sendable, Identifiable {
    case pokemon(PokemonCard)
    case trainer(TrainerCard)
    case energy(EnergyCard)
    
    public var id: String {
        switch self {
        case .pokemon(let data):
            return data.id
        case .trainer(let data):
            return data.id
        case .energy(let data):
            return data.id
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case category = "category"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .category)
        
        switch type {
        case "Pokemon":
            let data = try PokemonCard(from: decoder)
            self = .pokemon(data)
        case "Trainer":
            let data = try TrainerCard(from: decoder)
            self = .trainer(data)
        case "Energy":
            let data = try EnergyCard(from: decoder)
            self = .energy(data)
        default:
            throw DecodingError.dataCorruptedError(forKey: .category, in: container, debugDescription: "Unknown type")
        }
    }
}

public protocol Card {
    var id: String {get}
    var localId: String {get}
    var name: String {get}
    var image: String? {get}
    var category: String {get}
    var illustrator: String? {get}
    var rarity: String? {get}
    var set: SetBrief {get}
    var variants: CardVariants {get}
    var boosters: [Booster]? {get}
    var pricing: Pricing {get}
    var updated: Date {get}
    var legal: Legal {get}
}

public struct TrainerCard: Card, Codable, Sendable, Identifiable {
    public let id: String
    public let localId: String
    public let name: String
    public let image: String?
    public let category: String
    public let illustrator: String?
    public let rarity: String?
    public let set: SetBrief
    public let variants: CardVariants
    public let boosters: [Booster]?
    public let pricing: Pricing
    public let updated: Date
    public let legal: Legal
    
    public let effect: String
    public let trainerType: String?
}

public struct EnergyCard: Card, Codable, Sendable, Identifiable {
    public let id: String
    public let localId: String
    public let name: String
    public let image: String?
    public let category: String
    public let illustrator: String?
    public let rarity: String?
    public let set: SetBrief
    public let variants: CardVariants
    public let boosters: [Booster]?
    public let pricing: Pricing
    public let updated: Date
    public let legal: Legal
    
    public let effect: String?
    public let energyType: String
}

public struct PokemonCard: Card, Codable, Sendable, Identifiable {
    public let id: String
    public let localId: String
    public let name: String
    public let image: String?
    public let category: String
    public let illustrator: String?
    public let rarity: String?
    public let set: SetBrief
    public let variants: CardVariants
    public let boosters: [Booster]?
    public let pricing: Pricing
    public let updated: Date
    public let legal: Legal
    
    public let dexId: [Int]?
    public let hp: Int?
    public let types: [String]?
    public let evolveFrom: String?
    public let description: String?
    public let level: String?
    public let stage: String?
    public let suffix: String?
    public let item: PokemonCardItem?
}

public struct PokemonCardItem : Codable, Sendable {
    public let name: String
    public let effect: String
}

public struct CardVariants: Codable, Sendable {
    public let normal: Bool
    public let reverse: Bool
    public let holo: Bool
    public let firstEdition: Bool
}

public struct Booster: Codable, Sendable, Identifiable{
    public let id: String
    public let name: String
    public let logo: String?
    public let artworkFront: String?
    public let artworkBack: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case logo
        case artworkFront = "artwork_front"
        case artworkBack = "artwork_back"
    }
}

public struct Pricing: Codable, Sendable {
    public let tcgplayer: TCGPlayerPricing?
    public let cardmarket: CardMarketPricing?
}

public struct TCGPlayerPricing: Codable, Sendable {
    public let updated: Date
    public let unit: String
    public let normal: TCGPlayerPricingVariants?
    public let holofoil: TCGPlayerPricingVariants?
    public let reverseholofoil : TCGPlayerPricingVariants?
    
    enum CodingKeys: String, CodingKey {
        case updated
        case unit
        case normal
        case holofoil
        case reverseholofoil = "reverse-holofoil"
    }
}

public struct TCGPlayerPricingVariants: Codable, Sendable {
    public let lowPrice: Double?
    public let midPrice: Double?
    public let highPrice: Double?
    public let marketPrice: Double?
    public let directLowPrice: Double?
    
}

public struct CardMarketPricing: Codable, Sendable {
    public let updated: Date
    public let unit: String
    public let avg: Double?
    public let low: Double?
    public let trend: Double?
    public let avg1: Double?
    public let avg7: Double?
    public let avg30: Double?
    public let avgHolo: Double?
    public let lowHolo: Double?
    public let trendHolo: Double?
    public let avg1Holo: Double?
    public let avg7Holo: Double?
    public let avg30Holo: Double?
    
    enum CodingKeys: String, CodingKey, Sendable {
        case updated
        case unit
        case avg
        case low
        case trend
        case avg1
        case avg7
        case avg30
        case avgHolo = "avg-holo"
        case lowHolo = "low-holo"
        case trendHolo = "trend-holo"
        case avg1Holo = "avg1-holo"
        case avg7Holo = "avg7-holo"
        case avg30Holo = "avg30-holo"
        
    }
}
