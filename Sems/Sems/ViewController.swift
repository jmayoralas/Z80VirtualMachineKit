//
//  ViewController.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 27/6/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Cocoa
import Z80VirtualMachineKit

class ViewController: NSViewController, Z80VirtualMachineStatus {
    @IBOutlet weak var screenView: NSImageView!
    
    var screen: VmScreen!
    var vm: Z80VirtualMachineKit!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        vm.run()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // MARK: Initialization
    func setup() {
        screenView.imageScaling = .scaleProportionallyUpOrDown
        screen = VmScreen()
        vm = Z80VirtualMachineKit(screen)
        vm.delegate = self
        
        loadRom()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {(theEvent: NSEvent) -> NSEvent? in return self.onKeyDown(theEvent: theEvent)}
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) {(theEvent: NSEvent) -> NSEvent? in return self.onKeyUp(theEvent: theEvent)}
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {(theEvent: NSEvent) -> NSEvent? in return self.onFlagsChanged(theEvent: theEvent)}
    }

    func loadRom() {
        let data = NSDataAsset(name: "Rom48k")!.data
        var buffer = [UInt8](repeating: 0, count: data.count)
        (data as NSData).getBytes(&buffer, length: data.count)
        
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.critical
        alert.addButton(withTitle: "OK")
        
        do {
            try vm.loadRomAtAddress(0x0000, data: buffer)
        } catch RomErrors.bufferLimitReach {
            alert.messageText = "Memory full !!"
            alert.runModal()
        } catch {
            alert.messageText = "Unknown error !!"
            alert.runModal()
        }
    }
    
    // MARK: Keyboard handling
    private func onKeyDown(theEvent: NSEvent) -> NSEvent? {
        if !theEvent.modifierFlags.contains(.command) {
            if vm.isRunning() {
                vm.keyDown(char: KeyEventHandler.getChar(event: theEvent))
                return nil
            }
        }
        
        return theEvent
    }
    
    private func onKeyUp(theEvent: NSEvent) -> NSEvent? {
        if vm.isRunning() {
            vm.keyUp(char: KeyEventHandler.getChar(event: theEvent))
            return nil
        }
        return theEvent
    }
    
    private func onFlagsChanged(theEvent: NSEvent) -> NSEvent? {
        if vm.isRunning() {
            vm.specialKeyUpdate(special_keys: KeyEventHandler.getSpecialKeys(event: theEvent))
            return nil
        }
        return theEvent
    }
    
    // MARK: Screen handling
    func Z80VMScreenRefresh() {
        DispatchQueue.main.async { [unowned self] in
            self.screenView.image = self.imageFromARGB32Bitmap(self.screen.buffer, width: 320, height: 240)
        }
    }
    
    func imageFromARGB32Bitmap(_ pixels:[PixelData], width:Int, height:Int) -> NSImage {
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        assert(pixels.count == width * height)
        
        let providerRef = CGDataProvider(
            data: Data(bytes: UnsafePointer<UInt8>(pixels), count: pixels.count * sizeof(PixelData))
        )
        
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * sizeof(PixelData),
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef!,
            decode: nil,
            shouldInterpolate: true,
            intent: CGColorRenderingIntent.defaultIntent
        )
        
        return NSImage(cgImage: cgim!, size: NSZeroSize)
    }
}

