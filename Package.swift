import PackageDescription

let package = Package(
    name: "swift-weather-scrape",
    dependencies: [
        //.Package(url: "https://github.com/IBM-Swift/OpenSSL-OSX.git", Version(0, 2, 5)),
        .Package(url: "https://github.com/IBM-Swift/CommonCrypto.git", Version(0, 1, 3)),
    ]
)
