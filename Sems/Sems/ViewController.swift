//
//  ViewController.swift
//  Sems
//
//  Created by Jose Luis Fernandez-Mayoralas on 27/6/16.
//  Copyright © 2016 Jose Luis Fernandez-Mayoralas. All rights reserved.
//

import Cocoa
import Z80VirtualMachineKit

private let kColorSpace = CGColorSpaceCreateDeviceRGB()
private let kInstantLoadEnabled = "(Instant load enabled)"
private let kInstantLoadDisabled = "(Instant load disabled)"

class ViewController: NSViewController, Z80VirtualMachineStatus {
    @IBOutlet weak var screenView: NSImageView!
    
    var screen: VmScreen!
    var vm: Z80VirtualMachineKit!
    let appVersionString = String(
        format: "Sems v%@.%@",
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String,
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
        
        vm.run()
    }
    
    override func viewDidAppear() {
        self.view.window!.title = String(format: "%@ %@", appVersionString, kInstantLoadDisabled)
    }

    // MARK: Initialization
    func setup() {
        screenView.imageScaling = .scaleProportionallyUpOrDown
        
        screen = VmScreen(zoomFactor: 2)
        
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
        
        do {
            try vm.loadRomAtAddress(0x0000, data: buffer)
        } catch RomErrors.bufferLimitReach {
            self.errorShow(messageText: "Memory full !!")
        } catch {
            self.errorShow(messageText: "Unknown error !!")
        }
    }
    
    private func errorShow(messageText: String) {
        let alert = NSAlert()
        alert.alertStyle = NSAlertStyle.critical
        alert.addButton(withTitle: "OK")
        
        alert.messageText = messageText
        alert.runModal()
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
        let bitmapContext = CGContext(data: &screen.buffer, width: screen.width, height: screen.height, bitsPerComponent: 8, bytesPerRow: 4 * screen.width, space: kColorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        let cgImage = bitmapContext!.makeImage()
        
        DispatchQueue.main.async { [unowned self] in
            self.screenView.image = NSImage(cgImage: cgImage!, size: NSZeroSize)
        }
    }
    
    
    // MARK: Menu selectors
    @IBAction func openTape(_ sender: AnyObject) {
        let dialog = NSOpenPanel()
        
        dialog.title = "Choose a file"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes = ["tap", "tzx"]
        
        if dialog.runModal() == NSModalResponseOK {
            if let result = dialog.url {
                let path = result.path

                do {
                    try self.vm.openTape(path: path)
                } catch TapeLoaderError.FileNotFound {
                    self.errorShow(messageText: "File not found")
                } catch TapeLoaderError.UnsupportedTapeBlockFormat {
                    self.errorShow(messageText: "Unsupported tape block format")
                } catch {
                    self.errorShow(messageText: "Weird error")
                }
            }
        }
    }
    
    @IBAction func playTape(_ sender: AnyObject) {
        guard !self.vm.instantLoadEnabled() else {
            self.errorShow(messageText: "Cannot play a tape when instant load is enabled")
            return
        }
        
        if vm.tapeIsPlaying() {
            vm.stopTape()
        } else {
            do {
                try vm.startTape()
            } catch TapeLoaderError.NoTapeOpened {
                self.errorShow(messageText: "No tape has been opened")
            } catch TapeLoaderError.EndOfTape {
                self.errorShow(messageText: "Reached the end of the tape")
            } catch {
                self.errorShow(messageText: "Unknown error")
            }
        }
    }
    
    @IBAction func resetMachine(_ sender: AnyObject) {
        vm.reset()
    }
    
    @IBAction func warpEmulation(_ sender: AnyObject) {
        self.vm.toggleWarp()
    }
    
    @IBAction func toggleInstantLoad(_ sender: AnyObject) {
        if self.vm.instantLoadEnabled() {
            self.view.window!.title = String(format: "%@ %@", self.appVersionString, kInstantLoadDisabled)
            self.vm.disableInstantLoad()
        } else {
            self.view.window!.title = String(format: "%@ %@", self.appVersionString, kInstantLoadEnabled)
            self.vm.enableInstantLoad()
        }
    }
}

