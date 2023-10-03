// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let release = "min.v5.1.2.5"

let frameworks = [
    "ffmpegkit": "66c859860382999b52a8a053ae7f088fbc066b028f045e032f1900e79c247037",
    "libavcodec": "ca961f609253d6d4b7d288080f338a957586fdb213e409237047743041583ef0",
    "libavdevice": "9abb6de9664acf3a7316521fed546bed9392bbdcb42503edfd324243d0f54bc7",
    "libavfilter": "c03dbb7ff3f966fed113705fe40eac544de67c0674702b14cc843d5ee48fe362",
    "libavformat": "a14d53de180f6683248bc005651903027a71d7c8d06b0720a1e430380727dab2",
    "libavutil": "31fc9792b45c1dd3f4c8c053262153936746fa2d7431f4fbba0a2fef1a77c38b",
    "libswresample": "03e4e74105eecbe5a4a1029adae9e283029c7136b47210432f4b694e5c8ed1c0",
    "libswscale": "b7f871042e6c10edef9150ae8858b0a697b88722f747840373588f19884b7182",
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
