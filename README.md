# Z80VirtualMachineKit

This a personal project oriented to learn to code in Swift.

The target is to create a complete ZX Spectrum emulator library for Mac OS X.

To compile this project you must install XCode 8 Beta and enable Swift 3 support.

Some Bus and BusComponent structures have been inspired by the work in https://efepuntomarcos.wordpress.com/2012/08/27/hazte-un-spectrum-1-parte/#comments (develop of YASS emulator).

DebuggerZ80VirtualMachine contains a sample debugger application that uses Z80VirtualMachineKit. It can be used to inspect the emulator registers and memory. It shows a basic screen with the output produced by the ULA. You can load blocks of code into RAM memory as well as into ROM, and execute that code until a HALT opcode is decoded or in a step by step basis.

The emulator is completely unusable by now.
