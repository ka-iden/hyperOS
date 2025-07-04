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
- [dd](https://www.gnu.org/software/coreutils/manual/html_node/dd-invocation.html) (for creating the bootable image)
- [gcc (which includes ld)](https://gcc.gnu.org) (for compiling and linking C code, when we get there)

Due to the fact that many tools such as `dd` are not available or have suitable replacements on Windows, I have switched to using WSL2 for building and running this project. If you are on any distribution of linux, you can move ahead and install the tools using your package manager.

## Building

To build the project, you can either use the provided `build.sh` script or run the commands manually. The script will assemble the `boot.asm` file, create a bootable image, and run it in QEMU.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
NASM is licensed under the [Simplified BSD license](https://github.com/netwide-assembler/nasm/blob/master/LICENSE).  
QEMU is licensed under the [GNU General Public License v2.0](https://gitlab.com/qemu-project/qemu/-/raw/master/LICENSE).  
GNU Coreutils and Binutils (which include tools such as gcc, ld, and dd) are licensed under the [GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html).  
