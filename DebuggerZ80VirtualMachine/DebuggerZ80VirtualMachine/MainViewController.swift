//
//  MainViewController.swift
//  DebuggerZ80VirtualMachine
//
//  Created by Jose Luis Fernandez-Mayoralas on 31/12/15.
//  Copyright © 2015 lomocorp. All rights reserved.
//

import Cocoa
import Z80VirtualMachineKit

class MainViewController: NSViewController {

    @IBOutlet weak var PcTextField: NSTextFieldCell!

    var vm = Z80VirtualMachineKit()

    override func viewDidLoad() {
        super.viewDidLoad()
        PcTextField!.title = vm.getCpuRegs().pc.hexStr()
    }
}
