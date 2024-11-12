# BC-250 Documentation
Documentation for running the AMD BC-250 boards for anything other than crypto crap. 

# Hardware Notes
- AMD BC-250 AMD, a cut-down variant of the SOC in the PS5. It integrates 6x Zen 2 cores, at up to 3.49GHz (ish), as well as an RDNA2 iGPU.
- 16GB GDDR6 shared between the CPU and GPU.
- M.2 slot supports NVMe (PCIe 2.0 x2) and SATA.
- I/O includes: 1x DisplayPort, 1x GbE Ethernet, 2x USB 2.0, 2x USB 3.0.

# Mesa
- Upstream Mesa currently lacks support for this specific GPU (Cyan Skillfish), however efforts are underway to get that fixed.
  - A temporary workaround is modifying the following line in ``src/amd/addrlib/src/amdgpu_asic_addr.h``:
    ```
    ---#define AMDGPU_NAVI10_RANGE     0x01, 0x0A //# 1  <= x < 10
    +++#define AMDGPU_NAVI10_RANGE     0x01, 0x8A //# 1  <= x < 10
    ```
    Patched Mesa builds are available via copr, [here]( dnf copr enable @exotic-soc/bc250-mesa/). You must set ``RADV_DEBUG=nocompute`` to resolve issues with Vulkan visual issues. Some OpenGL workloads cause a GPU hang, and ROCM will trigger a GPU reset, however rusticl works.

# Kernel
- Kernels prior to 6.5 should boot without modification. You may need to disable modesetting until you have installed patched mesa.
- ``amdgpu.sg_display=0`` is required to boot kernel 6.6 and later. 

# Memory
- On P2.16, P3.00, and P5.00 BIOS the memory will be split 8/8. On P4.00G, it will be split 4/12. The only way to change this at this stage is flashing modified firmware.

# Firmware
- ***ANY DAMAGE OR ISSUES CAUSED BY FLASHING THIS MODIFIED IMAGE IS YOUR RESPONSIBILITY ENTIRELY***
- A modified firmware image is available at [this repo](https://gitlab.com/TuxThePenguin0/bc250-bios/) (Credit and massive thanks to [Segfault](https://github.com/TuxThePenguin0))
- Flashing via a hardware programmer is recommended. Get yourself a CH347, or a Raspberry Pi Pico, or anything else capable of recovering from a bad BIOS flash.
- ***DO NOT FLASH ANYTHING WITHOUT HAVING A KNOWN GOOD BACKUP***
  - SPI flash header pinout: 
    ![SPI flash header pinout](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/SPI_PINOUT.jpg)
  - VRAM allocation is configured within: ``Chipset -> GFX Configuration -> GFX Configuration``. Set ``Integrated Graphics Controller`` to forced, and ``UMA Mode`` to  ``UMA_SPECIFIED``, and set the VRAM limit to your desired size. 512MB appears to be the best for general APU use. Credit to [Segfault](https://github.com/TuxThePenguin0) for both the BIOS modification and information on changing the VRAM limit.
- Many of the newly exposed settings are untested, and could either do nothing, or completely obliterate you and everyone else within a 100km radius. Or maybe they work fine. Be careful, though. 
- Note: If your board shipped with P4.00G (or any other BIOS revision that modified the memory split) you may need to fully clear the firmware settings. Removing the coin cell and using the CLR_CMOS header should suffice.
# Performance
- A GPU governor is available [here](https://gitlab.com/TuxThePenguin0/oberon-governor). You should use it.
  - You can also use the following commands to set the clocks manually:
    ```
    echo vc 0 <CLOCK> <VOLTAGE> > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    echo c > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    ```

# Additional notes:
- I have repeatedly recieved requests for help from people who have not read through this page correctly. These boards are extremely weird, and they have a LOT of quirks that need to be worked around. If a fix has been mentioned on this page, its almost 100% required for it to work properly. Please do not purchase one and expect it work like a typical desktop PC. No installer images will be provided, unless you want to build them. If so, let me know :) 


# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)

# WALL OF SHAME
1. ![SHAMEFUL](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/WALL_OF_SHAME_1.png)
