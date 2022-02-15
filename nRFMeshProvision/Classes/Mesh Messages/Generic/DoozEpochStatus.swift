//
/*
* Copyright (c) 2019, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

public struct DoozEpochStatus: GenericMessage {
    public static var opCode: UInt32 = 0x8222

    public var parameters: Data? {
        var data = Data() + tId
        let uTz = UInt16(mTzData & 0x1FF)
        print("📣mTzData: \(mTzData) (\(String(mTzData, radix: 2)))")
        print("📣mTzData & 0x1FF: \(uTz) (\(String(uTz, radix: 2)))")
        print("📣mCommand: \(mCommand) (\(String(mCommand, radix: 2)))")
        print("📣mIO: \(mIO) (\(String(mIO, radix: 2)))")
        print("📣mUnused: \(mUnused) (\(String(mUnused, radix: 2)))")
        let uTzByte1 = UInt8(truncatingIfNeeded: uTz & 0xFF)
        let uTzByte2 = UInt8(truncatingIfNeeded: (uTz << 8) & 0x7)
        let byte2 = UInt8(truncatingIfNeeded: mUnused << 6 | mIO << 5 | mCommand << 1 | uTzByte2)
        let packed = UInt16(byte2 | uTzByte1)
        print("📣packed: \(packed) (\(String(packed, radix: 2)))")
        data += packed
        print("📣mEpoch: \(mEpoch)")
        print("📣mCorrelation: \(mCorrelation)")
        data += mEpoch
        data += mCorrelation
        if let extra = mExtra {
            print("📣mExtra: \(String(describing: extra))")
            data += UInt8(extra)
        }
        return data    }

    public let mTzData: Int16
    public let mCommand: UInt8
    public let mIO: UInt8
    public let mUnused: UInt8
    public let mEpoch: UInt32
    public let mCorrelation: UInt32
    public let mExtra: UInt8?
    public let tId: UInt8

    /// Creates the DoozEpochStatus message.
    ///
    /// - parameters:
    ///   - tzData               The time zone value
    ///   - command              The command of this message (2: read current epoch time and timezone, 8: update epoch and timezone only if it's greater than the device, 15: override epoch and timezone)
    ///   - io                   Target IO
    ///   - unused               RFU
    ///   - epoch                The current Epoch
    ///   - correlation          Correlation to link request / response
    ///   - extra                RFU
    ///   - tId                  Transaction id
    public init(tzData: Int16, command: UInt8, io: UInt8, unused: UInt8, epoch: UInt32, correlation: UInt32, extra: UInt8?, tId: UInt8) {
        self.mTzData = tzData
        self.mCommand = command
        self.mIO = io
        self.mUnused = unused
        self.mEpoch = epoch
        self.mCorrelation = correlation
        self.mExtra = extra
        self.tId = tId
    }

    public init?(parameters: Data) {
        tId = parameters[0]
        let packed = UInt16(bitPattern: parameters.read(fromOffset: 1))
        print("📣packed: \(packed) (\(String(packed, radix: 2)))");
        self.mUnused = UInt8(truncatingIfNeeded: packed >> 14);
        print("📣mUnused: \(mUnused) (\(String(mUnused, radix: 2)))");
        self.mIO = UInt8(truncatingIfNeeded: (packed >> 13) & 0x1);
        print("📣mIO: \(mIO) (\(String(mIO, radix: 2)))");
        self.mCommand = UInt8(truncatingIfNeeded: (packed >> 9) & 0xF);
        print("📣mCommand: \(mCommand) (\(String(mCommand, radix: 2)))");
        var uTz = UInt16(packed & 0x1FF);
        self.mTzData = Int16(bitPattern: uTz)
        print("📣mTzData: \(mTzData) (\(String(uTz, radix: 2)))");
        self.mEpoch = parameters.read(fromOffset: 3);
        print("📣mEpoch: \(mEpoch)");
        self.mCorrelation = parameters.read(fromOffset: 7);
        print("📣mCorrelation: \(mCorrelation)");
        if parameters.count == 5 {
            self.mExtra = parameters.read(fromOffset: 11)
            print("📣mExtra: \(String(describing: mExtra))");
        } else {
            self.mExtra = nil
        }
    }
}
