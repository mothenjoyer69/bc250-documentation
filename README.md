# BC-250 Documentation
Documentation for running the AMD BC-250 boards for anything other than crypto crap. 

# Hardware Notes
- AMD BC-250 AMD, a cut-down variant of the SOC in the PS5. It integrates 6x Zen 2 cores, at up to 3.49GHz (ish), as well as an RDNA2 iGPU.
- 16GB memory, split by default as 8/8. A modified BIOS is available that allows modification of the memory split.
- M.2 slot supports NVMe (PCIe 2.0 x2) and SATA.
- A GPU governor is available [here](https://gitlab.com/TuxThePenguin0/oberon-governor). You should use it.
  - You can also use the following commands to set the clocks manually:
    ```
    echo vc 0 <CLOCK> <VOLTAGE> > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    echo c > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    ```

# Mesa
- Upstream Mesa currently lacks support for this specific GPU (Cyan Skillfish), however efforts are underway to get that fixed.
  - A temporary workaround is modifying the following line in ``src/amd/addrlib/src/amdgpu_asic_addr.h``:
    ```
    #define AMDGPU_NAVI10_RANGE     0x01, 0x0A //# 1  <= x < 10
    ```
    and changing it to
    ```
    #define AMDGPU_NAVI10_RANGE     0x01, 0x8A //# 1  <= x < 10
    ```
    Patched Mesa builds are available via copr, [here](https://copr.fedorainfracloud.org/coprs/mothenjoyer69/bc250-mesa/). You must set ``RADV_DEBUG=nocompute`` to resolve issues with Vulkan visual issues. Some OpenGL workloads cause a GPU hang, and ROCM will trigger a GPU reset, however rusticl works.

# Kernel
- ``amdgpu.sg_display=0`` is required to boot kernel 6.6 and later. 

# Firmware
- A modified firmware dump is available at https://gitlab.com/TuxThePenguin0/bc250-bios/ (Credit and massive thanks to [Segfault](https://github.com/TuxThePenguin0))
- Flashing via a hardware programmer is recommended. Get yourself a CH347, or a Raspberry Pi Pico, or anything else capable of recovering from a bad BIOS flash.
- ***DO NOT FLASH ANYTHING WITHOUT HAVING A KNOWN GOOD BACKUP***
  - SPI flash header pinout: 
    ![SPI flash header pinout](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/SPI_PINOUT.jpg)
  - VRAM allocation is configured within: ``Chipset -> GFX Configuration -> GFX Configuration``. Set ``Integrated Graphics Controller`` to forced, and ``UMA Mode`` to  ``UMA_SPECIFIED``, and set the VRAM limit to your desired size. 512MB appears to be the best for general APU use. Credit to [Segfault](https://github.com/TuxThePenguin0) for both the BIOS modification and information on changing the VRAM limit.
- Many of the newly exposed settings are untested, and could either do nothing, or completely obliterate you and everyone else within a 100km radius. Or maybe they work fine. Be careful, though. 

# Getting it working
- Any standard distro should boot with ``amdgpu.sg_display=0`` added to your kernel command line, however you will not get GPU acceleration until you have installed a patched mesa (look above).
- A Bazzite image should eventually be available, so you can get yourself a Steam Machine 2.0.

# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)
