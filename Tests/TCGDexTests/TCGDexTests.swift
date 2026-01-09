import Testing
import TCGDex

@Test func anUnknownCardComesBackAsNil() async throws {
    let result = try await TCGDex().card(id: "bad-id")
    
    #expect(result == nil)
}

@Test func canDecodeAPokemonCard() async throws {
    let result = try await TCGDex().card(id: "sv05-019")
    
    guard case .pokemon = result else {
        Issue.record("Expected to fetch a Pokemon card")
        return
    }
}

@Test func canDecodeAPokemonCardInADifferentLanguage() async throws {
    let result = try await TCGDex(lang: .Japanese).card(id: "VS1-004")
    
    guard case .pokemon = result else {
        Issue.record("Expected to fetch a Pokemon card")
        return
    }
}

@Test func canDecodeATrainerCard() async throws {
    let result = try await TCGDex().card(id: "bog-3")
    
    guard case .trainer = result else {
        Issue.record("Expected to fetch a Trainer card")
        return
    }
}

@Test func canDecodeAnEnergyCard() async throws {
    let result = try await TCGDex().card(id: "col1-90")
    
    guard case .energy = result else {
        Issue.record("Expected to fetch an Energy card")
        return
    }
}

@Test func canDecodeCards() async throws {
    let result = try await TCGDex().cards()
    
    #expect(!result.isEmpty)
}

@Test func canDecodeASet() async throws {
    let result = try await TCGDex().set(id: "swsh3")
    
    #expect(result != nil)
}

@Test func canDecodeSets() async throws {
    let result = try await TCGDex().sets()

    #expect(!result.isEmpty)
}

@Test func canDecodeASerie() async throws {
    let result = try await TCGDex().serie(id: "swsh")
    
    #expect(result != nil)
}

@Test func canDecodeASeries() async throws {
    let result = try await TCGDex().series()
    
    #expect(!result.isEmpty)
}

