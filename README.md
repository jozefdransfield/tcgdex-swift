#TCGDex Swift

The SDK provides objects that model the tcgdex data and a service to access them via.

## Documentation

_The full API/SDK documentation in progress at [API Documentation - TCGdex](https://www.tcgdex.dev)_


## Installation

Add https://github.com/jozefdransfield/tcgdex-swift as Package Dependency in XCode

## Usage

```swift

import TCGDex


let api = TCGDex(lang: .English)

api.cards() // Fetch all cards
api.card(id: "id") // Fetch a card
api.sets() // Fetch all the sets
api.set(id: "id") // Fet a set
api.series() // Fetch all the series 
api.serie(id: "id") // Fetch a serie

```
