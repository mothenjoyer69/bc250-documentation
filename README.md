# BC-250 Documentation
Documentation for running the AMD BC-250 boards for anything other than crypto crap. 

# Hardware Notes
- AMD BC-250 AMD, a cut-down variant of the SOC in the PS5. It integrates 6x Zen 2 cores, at up to 3.49GHz (ish), as well as an RDNA2 iGPU.
- 16GB GDDR6 shared between the CPU and GPU.
- M.2 slot supports NVMe (PCIe 2.0 x2) and SATA.
- I/O includes: 1x DisplayPort, 1x GbE Ethernet, 2x USB 2.0, 2x USB 3.0.
- NCT6686 SuperIO chip. Force load the ``nct6683`` kernel driver to use.

# Mesa
- Upstream Mesa currently lacks support for this specific GPU (Cyan Skillfish).
  - A temporary workaround is modifying the following line in ``src/amd/addrlib/src/amdgpu_asic_addr.h``:
    ```
    ---#define AMDGPU_NAVI10_RANGE     0x01, 0x0A //# 1  <= x < 10
    +++#define AMDGPU_NAVI10_RANGE     0x01, 0x8A //# 1  <= x < 10
    ```
    Patched Mesa builds are available via copr, [here](https://copr.fedorainfracloud.org/coprs/g/exotic-soc/bc250-mesa/). You must set ``RADV_DEBUG=nocompute`` as a systemwide environment variable to resolve issues with Vulkan glitches. ``echo 'RADV_DEBUG=nocompute' | sudo tee /etc/environment`` should work. Some OpenGL workloads cause a GPU hang, and ROCM will trigger an unrecoverable GPU reset.

# Kernel
- Kernels prior to 6.5 should boot without modification. You may need to disable modesetting until you have installed patched mesa.
- ``amdgpu.sg_display=0`` is required to boot kernel 6.6 and later. 

# Memory
- On P2.16, P3.00, and P5.00 BIOS the memory will be split 8/8. On P4.00G, it will be split 4/12. The only way to change this at this stage is flashing modified firmware.

# Firmware
- ***ANY DAMAGE OR ISSUES CAUSED BY FLASHING THIS MODIFIED IMAGE IS YOUR RESPONSIBILITY ENTIRELY***
- A modified firmware image is available at [this repo](https://gitlab.com/TuxThePenguin0/bc250-bios/) (Credit and massive thanks to [Segfault](https://github.com/TuxThePenguin0)). He is responsible for most of the information on running these boards. Say thank you.
- Flashing via a hardware programmer is recommended. Get yourself a CH347, or a Raspberry Pi Pico, or anything else capable of recovering from a bad BIOS flash.
- ***DO NOT FLASH ANYTHING WITHOUT HAVING A KNOWN GOOD BACKUP***
  - SPI flash header pinout: 
    ![SPI flash header pinout](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/SPI_PINOUT.jpg)
  - VRAM allocation is configured within: ``Chipset -> GFX Configuration -> GFX Configuration``. Set ``Integrated Graphics Controller`` to forced, and ``UMA Mode`` to  ``UMA_SPECIFIED``, and set the VRAM limit to your desired size. 512MB appears to be the best for general APU use. Credit to [Segfault](https://github.com/TuxThePenguin0) for both the BIOS modification and information on changing the VRAM limit.
- Many of the newly exposed settings are untested, and could either do nothing, or completely obliterate you and everyone else within a 100km radius. Or maybe they work fine. Be careful, though.
- Some information online suggests using Smokeless_UMAF with these boards. This is a bad idea unless you are comfortable with a brick.
- Note: If your board shipped with P4.00G (or any other BIOS revision that modified the memory split) you may need to fully clear the firmware settings. Removing the coin cell and using the CLR_CMOS header should suffice.
# Performance
- A GPU governor is available [here](https://gitlab.com/TuxThePenguin0/oberon-governor). You should use it.
  - You can also use the following commands to set the clocks manually:
    ```
    echo vc 0 <CLOCK> <VOLTAGE> > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    echo c > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    ```

# Windows:
- No. 

# Additional notes:
- I have repeatedly recieved requests for help from people who have not read through this page correctly. Please do not purchase these boards if any part of this page is confusing. These are not, and will not ever be, standard desktop boards, and expecting them to be is a stupid thing to do.
- I have seen an alarming number of people I have personally helped out attempt to claim the information uncovered by Segfault as their own. You all suck, credit people properly. Many of these people also seem to fall under the above note.


# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)

# WALL OF SHAME!!!!!!!
1. ![SHAMEFUL](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/WALL_OF_SHAME_1.png)
