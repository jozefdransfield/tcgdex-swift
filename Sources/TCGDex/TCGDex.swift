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
    
    public init(id: String, logo: String, name: String, sets: [SetBrief]) {
        self.id = id
        self.logo = logo
        self.name = name
        self.sets = sets
    }
}


public struct SetBrief: Codable, Sendable, Identifiable  {
    public let id: String
    public let name: String
    public let logo: String?
    public let cardCount: SetBriefCardCount
    
    public init(id: String, name: String, logo: String?, cardCount: SetBriefCardCount) {
        self.id = id
        self.name = name
        self.logo = logo
        self.cardCount = cardCount
    }
}

public struct SetBriefCardCount : Codable, Sendable {
    public let total: Int
    public let official: Int
    
    public init(total: Int, official: Int) {
        self.total = total
        self.official = official
    }
}

public struct Legal: Codable, Sendable {
    public let expanded: Bool
    public let standard: Bool
    
    public init(expanded: Bool, standard: Bool) {
        self.expanded = expanded
        self.standard = standard
    }
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
    
    public init(cardCount: SetCardCount, cards: [CardBrief], id: String, logo: String, legal: Legal, name: String, releaseDate: String, serie: SerieBrief, symbol: String) {
        self.cardCount = cardCount
        self.cards = cards
        self.id = id
        self.logo = logo
        self.legal = legal
        self.name = name
        self.releaseDate = releaseDate
        self.serie = serie
        self.symbol = symbol
    }
}

public struct SerieBrief: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct SetCardCount : Codable, Sendable {
    public let firstEd: Int
    public let holo: Int
    public let normal: Int
    public let official: Int
    public let reverse: Int
    public let total: Int
    
    public init(firstEd: Int, holo: Int, normal: Int, official: Int, reverse: Int, total: Int) {
        self.firstEd = firstEd
        self.holo = holo
        self.normal = normal
        self.official = official
        self.reverse = reverse
        self.total = total
    }
}

public struct CardBrief: Codable, Sendable, Identifiable {
    public let id: String
    public let localId: String
    public let name: String
    public let image: String?
    
    public init(id: String, localId: String, name: String, image: String?) {
        self.id = id
        self.localId = localId
        self.name = name
        self.image = image
    }
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
    
    public init(id: String, localId: String, name: String, image: String?, category: String, illustrator: String?, rarity: String?, set: SetBrief, variants: CardVariants, boosters: [Booster]?, pricing: Pricing, updated: Date, legal: Legal, effect: String, trainerType: String?) {
        self.id = id
        self.localId = localId
        self.name = name
        self.image = image
        self.category = category
        self.illustrator = illustrator
        self.rarity = rarity
        self.set = set
        self.variants = variants
        self.boosters = boosters
        self.pricing = pricing
        self.updated = updated
        self.legal = legal
        self.effect = effect
        self.trainerType = trainerType
    }
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
    
    public init(id: String, localId: String, name: String, image: String?, category: String, illustrator: String?, rarity: String?, set: SetBrief, variants: CardVariants, boosters: [Booster]?, pricing: Pricing, updated: Date, legal: Legal, effect: String?, energyType: String) {
        self.id = id
        self.localId = localId
        self.name = name
        self.image = image
        self.category = category
        self.illustrator = illustrator
        self.rarity = rarity
        self.set = set
        self.variants = variants
        self.boosters = boosters
        self.pricing = pricing
        self.updated = updated
        self.legal = legal
        self.effect = effect
        self.energyType = energyType
    }
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
    
    public init(id: String, localId: String, name: String, image: String?, category: String, illustrator: String?, rarity: String?, set: SetBrief, variants: CardVariants, boosters: [Booster]?, pricing: Pricing, updated: Date, legal: Legal, dexId: [Int]?, hp: Int?, types: [String]?, evolveFrom: String?, description: String?, level: String?, stage: String?, suffix: String?, item: PokemonCardItem?) {
        self.id = id
        self.localId = localId
        self.name = name
        self.image = image
        self.category = category
        self.illustrator = illustrator
        self.rarity = rarity
        self.set = set
        self.variants = variants
        self.boosters = boosters
        self.pricing = pricing
        self.updated = updated
        self.legal = legal
        self.dexId = dexId
        self.hp = hp
        self.types = types
        self.evolveFrom = evolveFrom
        self.description = description
        self.level = level
        self.stage = stage
        self.suffix = suffix
        self.item = item
    }
}

public struct PokemonCardItem : Codable, Sendable {
    public let name: String
    public let effect: String
    
    public init(name: String, effect: String) {
        self.name = name
        self.effect = effect
    }
}

public struct CardVariants: Codable, Sendable {
    public let normal: Bool
    public let reverse: Bool
    public let holo: Bool
    public let firstEdition: Bool
    
    public init(normal: Bool, reverse: Bool, holo: Bool, firstEdition: Bool) {
        self.normal = normal
        self.reverse = reverse
        self.holo = holo
        self.firstEdition = firstEdition
    }
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
    
    public init(id: String, name: String, logo: String?, artworkFront: String?, artworkBack: String?) {
        self.id = id
        self.name = name
        self.logo = logo
        self.artworkFront = artworkFront
        self.artworkBack = artworkBack
    }
}

public struct Pricing: Codable, Sendable {
    public let tcgplayer: TCGPlayerPricing?
    public let cardmarket: CardMarketPricing?
    
    public init(tcgplayer: TCGPlayerPricing?, cardmarket: CardMarketPricing?) {
        self.tcgplayer = tcgplayer
        self.cardmarket = cardmarket
    }
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
    
    public init(updated: Date, unit: String, normal: TCGPlayerPricingVariants?, holofoil: TCGPlayerPricingVariants?, reverseholofoil: TCGPlayerPricingVariants?) {
        self.updated = updated
        self.unit = unit
        self.normal = normal
        self.holofoil = holofoil
        self.reverseholofoil = reverseholofoil
    }
}

public struct TCGPlayerPricingVariants: Codable, Sendable {
    public let lowPrice: Double?
    public let midPrice: Double?
    public let highPrice: Double?
    public let marketPrice: Double?
    public let directLowPrice: Double?
    
    public init(lowPrice: Double?, midPrice: Double?, highPrice: Double?, marketPrice: Double?, directLowPrice: Double?) {
        self.lowPrice = lowPrice
        self.midPrice = midPrice
        self.highPrice = highPrice
        self.marketPrice = marketPrice
        self.directLowPrice = directLowPrice
    }
    
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
    
    public init(updated: Date, unit: String, avg: Double?, low: Double?, trend: Double?, avg1: Double?, avg7: Double?, avg30: Double?, avgHolo: Double?, lowHolo: Double?, trendHolo: Double?, avg1Holo: Double?, avg7Holo: Double?, avg30Holo: Double?) {
        self.updated = updated
        self.unit = unit
        self.avg = avg
        self.low = low
        self.trend = trend
        self.avg1 = avg1
        self.avg7 = avg7
        self.avg30 = avg30
        self.avgHolo = avgHolo
        self.lowHolo = lowHolo
        self.trendHolo = trendHolo
        self.avg1Holo = avg1Holo
        self.avg7Holo = avg7Holo
        self.avg30Holo = avg30Holo
    }
}
