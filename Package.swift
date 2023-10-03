// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.5"

let frameworks = [
    "ffmpegkit": "236e1442012fc05d707ea96db5c20b106eef10a5c03735e0626f70ca0fcf9c1a",
    "libavcodec": "cc86f795728b2325e31a58f54d1fb38e7e327d33f3ec664db2f375bd48e57b75",
    "libavdevice": "96c4033ab9bccc9941e3e74034194ecbea10abdb0b557b7aafe71884b77d9e93",
    "libavfilter": "ad922bfe9c6029d58e9380fad287cc0561b33db96dc1321a63925a7a755dbc12",
    "libavformat": "b1cf9184569be43a382634530abf35d5396990eb9c422cb84006ff0c59968bb7",
    "libavutil": "0be1b97fc8e9b8d3a36b4dd28ad99496bbfa2f6dffe28aca031ec3c10a2def91",
    "libswresample": "ced5d68bc6b9e7f7073feabdee049637124b2314e133733fea04deae5311acdc",
    "libswscale": "916b2ac0caa8aa6ae323c3b7e00268c7edf344e5c47f76f883e103c1448cdea6",
]

func xcframework(_ package: Dictionary<String, String>.Element) -> Target {
    let url = "https://github.com/okiookio/ffmpeg-kit-spm/releases/download/\(release)/\(package.key).xcframework.zip"
    return .binaryTarget(name: package.key, url: url, checksum: package.value)
}

let linkerSettings: [LinkerSetting] = [
    .linkedFramework("AudioToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedFramework("AVFoundation", .when(platforms: [.macOS, .iOS, .macCatalyst])),
    .linkedFramework("CoreMedia", .when(platforms: [.macOS])),
    .linkedFramework("OpenGL", .when(platforms: [.macOS])),
    .linkedFramework("VideoToolbox", .when(platforms: [.macOS, .iOS, .macCatalyst, .tvOS])),
    .linkedLibrary("z"),
    .linkedLibrary("lzma"),
    .linkedLibrary("bz2"),
    .linkedLibrary("iconv"),
]

let libAVFrameworks = frameworks.filter { $0.key != "ffmpegkit" }

let package = Package(
    name: "ffmpeg-kit-spm",
    platforms: [.iOS(.v12), .macOS(.v10_15), .tvOS(.v11), .watchOS(.v7)],
    products: [
        .library(
            name: "FFmpeg-Kit",
            type: .dynamic,
            targets: ["FFmpeg-Kit", "ffmpegkit"]),
        .library(
            name: "FFmpeg",
            type: .dynamic,
            targets: ["FFmpeg"] + libAVFrameworks.map { $0.key }),
    ] + libAVFrameworks.map { .library(name: $0.key, targets: [$0.key]) },
    dependencies: [],
    targets: [
        .target(
            name: "FFmpeg-Kit",
            dependencies: frameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
        .target(
            name: "FFmpeg",
            dependencies: libAVFrameworks.map { .byName(name: $0.key) },
            linkerSettings: linkerSettings),
    ] + frameworks.map { xcframework($0) })
