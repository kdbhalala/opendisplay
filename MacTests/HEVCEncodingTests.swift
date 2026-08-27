import XCTest
import VideoToolbox
import CoreMedia

final class HEVCEncodingTests: XCTestCase {

    func testHEVCCompressionSessionCreation() {
        var encoder: VTCompressionSession?
        let spec: CFDictionary = [kVTVideoEncoderSpecification_EnableLowLatencyRateControl: kCFBooleanTrue] as CFDictionary
        var status = VTCompressionSessionCreate(
            allocator: nil,
            width: 1920,
            height: 1080,
            codecType: kCMVideoCodecType_HEVC,
            encoderSpecification: spec,
            imageBufferAttributes: nil,
            compressedDataAllocator: nil,
            outputCallback: nil,
            refcon: nil,
            compressionSessionOut: &encoder
        )

        // If hardware low latency is unsupported on specific GPU, fallback without spec
        if encoder == nil {
            status = VTCompressionSessionCreate(
                allocator: nil,
                width: 1920,
                height: 1080,
                codecType: kCMVideoCodecType_HEVC,
                encoderSpecification: nil,
                imageBufferAttributes: nil,
                compressedDataAllocator: nil,
                outputCallback: nil,
                refcon: nil,
                compressionSessionOut: &encoder
            )
        }

        XCTAssertEqual(status, noErr)
        XCTAssertNotNil(encoder)

        if let encoder {
            VTSessionSetProperty(encoder, key: kVTCompressionPropertyKey_RealTime, value: kCFBooleanTrue)
            VTSessionSetProperty(encoder, key: kVTCompressionPropertyKey_AllowFrameReordering, value: kCFBooleanFalse)
            VTSessionSetProperty(encoder, key: kVTCompressionPropertyKey_AverageBitRate, value: 15_000_000 as CFNumber)
            let prepStatus = VTCompressionSessionPrepareToEncodeFrames(encoder)
            XCTAssertEqual(prepStatus, noErr)
            VTCompressionSessionInvalidate(encoder)
        }
    }

    func testH264CompressionSessionCreation() {
        var encoder: VTCompressionSession?
        let status = VTCompressionSessionCreate(
            allocator: nil,
            width: 1280,
            height: 720,
            codecType: kCMVideoCodecType_H264,
            encoderSpecification: nil,
            imageBufferAttributes: nil,
            compressedDataAllocator: nil,
            outputCallback: nil,
            refcon: nil,
            compressionSessionOut: &encoder
        )
        XCTAssertEqual(status, noErr)
        XCTAssertNotNil(encoder)

        if let encoder {
            VTCompressionSessionInvalidate(encoder)
        }
    }
}
