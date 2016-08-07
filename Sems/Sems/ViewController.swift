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
    
    var tapeLoader = TapeLoader()
    
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
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapContext = CGContext(data: &self.screen.buffer, width: 320, height: 240, bitsPerComponent: 8, bytesPerRow: 4 * 320, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        let cgImage = bitmapContext!.makeImage()
        
        DispatchQueue.main.async { [unowned self] in
            self.screenView.image = NSImage(cgImage: cgImage!, size: NSZeroSize)
        }
    }
    
    // MARK: Tape loader
    func tapeBlockRequested() -> UnsafeMutablePointer<UInt8>? {
        var tapeBlock: TapeBlock?
        
        do {
            tapeBlock = try tapeLoader.readBlock()
        } catch TapeLoaderErrors.OutOfData {
            NSLog("Out of data")
        } catch {
            NSLog("error")
        }
        
        var data: UnsafeMutablePointer<UInt8>? = nil
        
        if let block = tapeBlock {
            data = UnsafeMutablePointer(block.data)
        }
        
        return data
    }
    
    // MARK: Menu selectors
    @IBAction func openTape(_ sender: AnyObject) {
        if vm.tapeAvailable {
            tapeLoader.close()
            vm.tapeAvailable = false
        }
        
        let dialog = NSOpenPanel()
        
        dialog.title = "Choose a file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["tap"]
        
        if dialog.runModal() == NSModalResponseOK {
            if let result = dialog.url {
                let path = result.path!
                
                do {
                    try tapeLoader.open(path: path)
                    vm.tapeAvailable = true
                } catch TapeLoaderErrors.FileNotFound {
                    NSLog("File not found")
                } catch {
                    NSLog("Weird error")
                }
            }
        }
    }
    
    @IBAction func resetMachine(_ sender: AnyObject) {
        tapeLoader.close()
        vm.tapeAvailable = false
        vm.reset()
    }
}

