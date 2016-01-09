//
//  MainViewController.swift
//  DebuggerZ80VirtualMachine
//
//  Created by Jose Luis Fernandez-Mayoralas on 31/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Cocoa
import Z80VirtualMachineKit

@objc class MainViewController: NSViewController, Z80VirtualMachineStatus, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var PcTextField: ColorChangeTextField!
    
    @IBOutlet weak var IrTextField: ColorChangeTextField!
    @IBOutlet weak var SpTextField: ColorChangeTextField!
    @IBOutlet weak var ITextField: ColorChangeTextField!
    @IBOutlet weak var RTextField: ColorChangeTextField!
    
    @IBOutlet weak var MTextField: ColorChangeTextField!
    @IBOutlet weak var TTextField: ColorChangeTextField!
    
    @IBOutlet weak var instructionCounter: NSTextField!
    
    @IBOutlet weak var DataBusTextField: ColorChangeTextField!
    @IBOutlet weak var DataBusBinTextField: ColorChangeTextField!
    @IBOutlet weak var AddressBusTextField: ColorChangeTextField!
        
    @IBOutlet weak var ATextField: ColorChangeTextField!
    @IBOutlet weak var BTextField: ColorChangeTextField!
    @IBOutlet weak var IRTextField: ColorChangeTextField!
    @IBOutlet weak var ABinTextField: ColorChangeTextField!
    @IBOutlet weak var BBinTextField: ColorChangeTextField!
    @IBOutlet weak var DTextField: ColorChangeTextField!
    @IBOutlet weak var DBinTextField: ColorChangeTextField!
    @IBOutlet weak var HTextField: ColorChangeTextField!
    @IBOutlet weak var HBinTextField: ColorChangeTextField!
    @IBOutlet weak var IxhTextField: ColorChangeTextField!
    @IBOutlet weak var IxhBinTextField: ColorChangeTextField!
    @IBOutlet weak var IyhTextField: ColorChangeTextField!
    @IBOutlet weak var IyhBinTextField: ColorChangeTextField!
    @IBOutlet weak var FTextField: ColorChangeTextField!
    @IBOutlet weak var FBinTextField: ColorChangeTextField!
    @IBOutlet weak var CTextField: ColorChangeTextField!
    @IBOutlet weak var CBinTextField: ColorChangeTextField!
    @IBOutlet weak var ETextField: ColorChangeTextField!
    @IBOutlet weak var EBinTextField: ColorChangeTextField!
    @IBOutlet weak var LTextField: ColorChangeTextField!
    @IBOutlet weak var LBinTextField: ColorChangeTextField!
    @IBOutlet weak var IxlTextField: ColorChangeTextField!
    @IBOutlet weak var IxlBinTextField: ColorChangeTextField!
    @IBOutlet weak var IylTextField: ColorChangeTextField!
    @IBOutlet weak var IylBinTextField: ColorChangeTextField!
    @IBOutlet weak var memoryPeeker: NSTableView!
    
    var dumpAddress: Int!
    var memoryDump: [UInt8]!
    var insCounter: Int!

    var vm = Z80VirtualMachineKit()
    
    var matrix: NSMatrix!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vm.delegate = self
        
        NSEvent.addLocalMonitorForEventsMatchingMask(.KeyDownMask) { (theEvent) -> NSEvent? in
            switch theEvent.keyCode {
            case 96:
                self.f5Pressed()
                return nil
            case 97:
                self.f6Pressed()
                return nil
            default:
                break
            }
            
            return theEvent
        }
        
        for (index, column) in memoryPeeker.tableColumns.enumerate() {
            switch index {
            case 0:
                column.headerCell.stringValue = "Addr"
                column.width = 45
            case 1...16:
                column.headerCell.stringValue = "\(UInt8(index-1).hexStr())"
                column.width = 25
                column.headerCell.alignment = .Center
            case 17:
                column.headerCell.stringValue = "ASCII"
                column.width = 150
            default:
                break
            }
        }
        
        dumpAddress = 0x0000
        insCounter = -1
        _refreshMemoryDump()
        
        self.refreshView()
    }

    @IBAction func runClick(sender: AnyObject) {
        vm.run()
        refreshView()
        _refreshMemoryDump()
    }
    
    @IBAction func resetClick(sender: AnyObject) {
        vm.reset()
        refreshView()
        _refreshMemoryDump()
    }
    
    @IBAction func clearMemoryClick(sender: AnyObject) {
        vm.clearMemory()
        _refreshMemoryDump()
    }
    
    @IBAction func setPcClick(sender: AnyObject) {
        vm.setPc(UInt16(strtoul(PcTextField.stringValue, nil, 16)))
    }
    
    @IBAction func gotoClick(sender: AnyObject) {
        // get memory dump at address specified by AddressBus text field
        dumpAddress = Int(strtoul(AddressBusTextField.stringValue, nil, 16))
        _refreshMemoryDump()
    }
    
    @IBAction func loadProgramClick(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.runModal()
        
        let path = openPanel.URL?.path
        if path != nil {
            let data = NSData(contentsOfFile: path!)
            var buffer = [UInt8](count: data!.length, repeatedValue: 0)
            data!.getBytes(&buffer, length: data!.length)
            vm.loadRamAtAddress(Int(AddressBusTextField.stringValue)!, data: buffer)
            memoryPeeker.reloadData()
        }
    }
    
    func f5Pressed() {
        vm.step()
        insCounter!++
        
        self.refreshView()
    }
    
    func f6Pressed() {
        vm.clk()
        
        self.refreshView()
    }
    
    func refreshView() {
        let regs = vm.getCpuRegs()
        
        PcTextField!.stringValue = regs.pc.hexStr()
        IrTextField!.stringValue = "\(regs.ir.hexStr())"
        SpTextField!.stringValue = "\(regs.sp.hexStr())"
        ITextField!.stringValue = "\(regs.i.hexStr())"
        RTextField!.stringValue = "\(regs.r.hexStr())"
        
        MTextField!.stringValue = "\(vm.getMCycle())"
        TTextField!.stringValue = "\(vm.getTCycle())"
        
        instructionCounter.stringValue = "\(insCounter)"
        DataBusTextField!.stringValue = "\(vm.getDataBus().hexStr())"
        DataBusBinTextField!.stringValue = "\(vm.getDataBus().binStr)"
        AddressBusTextField!.stringValue = "\(vm.getAddressBus().hexStr())"
        
        ATextField!.stringValue = "\(regs.a.hexStr())"
        ABinTextField!.stringValue = regs.a.binStr
        FTextField!.stringValue = "\(regs.f.hexStr())"
        FBinTextField!.stringValue = regs.f.binStr
        BTextField!.stringValue = "\(regs.b.hexStr())"
        BBinTextField!.stringValue = regs.b.binStr
        CTextField!.stringValue = "\(regs.c.hexStr())"
        CBinTextField!.stringValue = regs.c.binStr
        DTextField!.stringValue = "\(regs.d.hexStr())"
        DBinTextField!.stringValue = regs.d.binStr
        ETextField!.stringValue = "\(regs.e.hexStr())"
        EBinTextField!.stringValue = regs.e.binStr
        HTextField!.stringValue = "\(regs.h.hexStr())"
        HBinTextField!.stringValue = regs.h.binStr
        LTextField!.stringValue = "\(regs.l.hexStr())"
        LBinTextField!.stringValue = regs.l.binStr
        IxhTextField!.stringValue = "\(regs.ixh.hexStr())"
        IxhBinTextField!.stringValue = regs.ixh.binStr
        IxlTextField!.stringValue = "\(regs.ixl.hexStr())"
        IxlBinTextField!.stringValue = regs.ixl.binStr
        IyhTextField!.stringValue = "\(regs.iyh.hexStr())"
        IyhBinTextField!.stringValue = regs.iyh.binStr
        IylTextField!.stringValue = "\(regs.iyl.hexStr())"
        IylBinTextField!.stringValue = regs.iyl.binStr
    }
    
    private func _refreshMemoryDump() {
        memoryDump = vm.dumpMemoryFromAddress(dumpAddress, toAddress: dumpAddress + 0xFF)
        memoryPeeker.reloadData()
    }
    
    // MARK: Z80VirtualMachineStatus delegate
    func Z80VMMemoryWriteAtAddress(address: Int, byte: UInt8) {
        if dumpAddress <= address && address < dumpAddress + 0x100 {
            memoryDump[address - dumpAddress] = byte
            memoryPeeker.reloadData()
        }
    }
    
    // MARK: NSTableViewDataSource
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 0x10
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        cellView.textField!.font = NSFont.init(name: "Courier", size: 12)
        
        switch tableColumn!.identifier {
        case "Addr":
            cellView.textField!.stringValue = "\(UInt16(dumpAddress + row * 0x10).hexStr())"
        case "Ascii":
            cellView.textField!.stringValue = ""
            let address = row * 0x10
            for byte in memoryDump[address...address + 0x0F] {
                cellView.textField!.stringValue += 32 <= byte && byte <= 126 ? String(UnicodeScalar(byte)) : "."
            }
        default:
            let address = Int(tableColumn!.identifier)! + row * 0x10
            cellView.textField!.stringValue = "\(memoryDump[address].hexStr())"
            cellView.textField!.alignment = .Center
        }
        
        return cellView
    }
}
