import Testing
@testable import Geohash

struct SampleHashContainer {
    let hash: String
    
    var lat: Double? = nil
    var lon: Double? = nil

    var expectedCell: (latitude: (min: Double, max: Double), longitude: (min: Double, max: Double))?
    var expectedNeighbors: (
        north: String, east: String, south: String, west: String,
        northEast: String, southEast: String, northWest: String, southWest: String
    )?
    
    static let sampleHashes: [SampleHashContainer] = [
        .init(
            hash: "u4pruydqqvj",
            lat: 57.64911063015461,
            lon: 10.40743969380855,
            expectedCell: (
                latitude: (min: 57.649109959602356, max: 57.649111300706863),
                longitude: (min: 10.407439023256302, max: 10.407440364360809)
            ),
            expectedNeighbors: (
                north: "u4pruydqqvm", // n
                east:  "u4pruydqqvn", // e
                south: "u4pruydqquv", // s
                west:  "u4pruydqqvh", // w
                northEast: "u4pruydqqvq", // ne
                southEast: "u4pruydqquy", // se
                northWest: "u4pruydqqvk", // nw
                southWest: "u4pruydqquu"  // sw
            )
        )
    ]
}

@Suite("GeohashTests")
struct GeohashTests {
    @Test(arguments: SampleHashContainer.sampleHashes)
    func testDecode(sample: SampleHashContainer) async throws {
        let cell = Geohash.decode(hash: sample.hash)!
        #expect(cell.latitude.min == sample.expectedCell?.latitude.min)
        #expect(cell.latitude.max == sample.expectedCell?.latitude.max)
        #expect(cell.longitude.min == sample.expectedCell?.longitude.min)
        #expect(cell.longitude.max == sample.expectedCell?.longitude.max)
    }
    
    @Test(arguments: ["garbage", "u$pruydqqvj"])
    func testDecodeInvalidStrings(hash: String) async throws {
        #expect(Geohash.decode(hash: hash) == nil)
    }
    
    @Test(arguments: [
        ("u4pruydqqvj", 57.64911063015461, 10.40743969380855)
    ])
    func testEncode(testData: (String, Double, Double)) async throws {
        let (expectedHash, lat, lon) = testData
        
        for i in 1...expectedHash.count {
            let calculatedHash = Geohash.encode(latitude: lat, longitude: lon, length: i)
            #expect(calculatedHash == String(expectedHash.prefix(i)))
        }
    }
    
    @Test(arguments: SampleHashContainer.sampleHashes)
    func testGetAdjacent(sample: SampleHashContainer) {
        let north = Geohash.adjacent(geohash: sample.hash, direction: .n)
        let east = Geohash.adjacent(geohash: sample.hash, direction: .e)
        let south = Geohash.adjacent(geohash: sample.hash, direction: .s)
        let west = Geohash.adjacent(geohash: sample.hash, direction: .w)
        
        #expect(sample.expectedNeighbors?.north == north)
        #expect(sample.expectedNeighbors?.east == east)
        #expect(sample.expectedNeighbors?.south == south)
        #expect(sample.expectedNeighbors?.west == west)
    }
    
    @Test(arguments: SampleHashContainer.sampleHashes)
    func testGetNeighbors(sample: SampleHashContainer) {
        let neighbors = Geohash.neighbors(geohash: sample.hash)
        
        #expect(sample.expectedNeighbors?.north == neighbors[0])
        #expect(sample.expectedNeighbors?.east == neighbors[1])
        #expect(sample.expectedNeighbors?.south == neighbors[2])
        #expect(sample.expectedNeighbors?.west == neighbors[3])
        #expect(sample.expectedNeighbors?.northEast == neighbors[4])
        #expect(sample.expectedNeighbors?.southEast == neighbors[5])
        #expect(sample.expectedNeighbors?.northWest == neighbors[6])
        #expect(sample.expectedNeighbors?.southWest == neighbors[7])
    }
}
    
#if canImport(CoreLocation)
import CoreLocation

@Suite("GeohashCoreLocationTests")
struct GeohashCoreLocationTests {
    
    @Test(arguments: SampleHashContainer.sampleHashes)
    func testValid(sampleHash: SampleHashContainer) {
        let c = CLLocationCoordinate2D(geohash: sampleHash.hash)
        #expect(CLLocationCoordinate2DIsValid(c))
        #expect(c.geohash(length: 11) == sampleHash.hash)
    }
    
    @Test(arguments: ["garbage", "u$pruydqqvj"])
    func testInvalid(hash: String) {
        let isCoordinateValid = CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(geohash: hash))
        #expect(!isCoordinateValid)
    }
}

#endif
