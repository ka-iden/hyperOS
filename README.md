# hyperOS

Making a little bootloader OS to test out some assembly.

> [!CAUTION]
> Abandon All Hope, Ye Who Enter Here  
> This project is a work in progress and will probably stay a work in progress forever. Expect to not see many commits or updates often, as this is a project that I will easily burn out on. See my [last attempt](https://github.com/ka-iden/ASM-Test) for reference.

## Features

- Entered protected mode! I have access to all 4GB of memory, and I can use the full 32-bit instruction set.
- Printing strings via functions (both 16-bit and 32-bit, check out [print16.asm](funcs/print16.asm) and [print32.asm](funcs/print32.asm))
- Handling keyboard inputs and printing characters (Real mode with BIOS interrupts, Protected mode with the keyboard controller)
- Handling special keypress cases such as moving the cursor using the arrow keys, enter to move to the next line, and the backspace key to move back and delete the last character.  
(Only in real mode at the moment, See the comments in [printTest32.asm](learning/printTest32.asm) for more information on what i'm doing for protected mode/32-bit)  
**Note that I am writing directly to video memory, so I am unable to actually see what is there.**

## Tools

To build the project, you need to have the following tools installed:

- [NASM](https://www.nasm.us) (for assembling the bootloader)
- [QEMU](https://www.qemu.org) (for running the bootloader in a virtual machine)
- [VSCode](https://code.visualstudio.com) is optional, you can run the commands below, but there is a [tasks.json](.vscode/tasks.json) file that will run the commands for you.

As a Windows user, I installed both NASM and QEMU with `winget` with the command:  
`winget install nasm qemu`  
And then added `C:\Program Files\qemu` and `C:\Users\{user}\AppData\Local\bin\NASM` to my `Path` environment variable.

## Building

With VSCode, you can build the project by pressing `Ctrl + Shift + B` and selecting `Build` from the list. This will run the `build` task in the `tasks.json` file.
You can also run the following commands in the terminal:

```bash
nasm -f bin -o boot.bin boot.asm
qemu-system-x86_64 boot.bin
```

This will assemble the `boot.asm` file and create a binary file called `boot.bin`, then run it in QEMU.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
NASM is licensed under the [Simplified BSD license](https://github.com/netwide-assembler/nasm/blob/master/LICENSE).
QEMU is licensed under the [GNU General Public License v2.0](https://gitlab.com/qemu-project/qemu/-/raw/master/LICENSE).
