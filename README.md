# About
This page is for documentation and information on the ASRock/AMD BC-250, and about running it as a general purpose PC. 

# Hardware info
- Features an AMD BC250 APU, a cut-down variant of the APU in the PS5. It integrates 6x Zen 2 cores, at up to 3.49GHz (ish), as well as a 24CU RDNA2 iGPU, as opposed to the 36 available in a standard PS5 Ariel SoC.
- 1x M.2 2280 slot with support for NVMe (PCIe 2.0 x2) and SATA 3.
- 1x DisplayPort, 1x GbE Ethernet, 2x USB 2.0, 2x USB 3.0.
- 1x SPI header, 1x auto-start jumper, 1x clear CMOS jumper, 2x mystery headers.
- NCT6686 SuperIO chip.
- 220W TDP, so make sure you have a good quality power supply with 2x PCIe 8-pin connectors available and a plan for cooling it. You can, in a pinch, get away with directly placing two 120mm fans directly on top of the heatsink. If you are doing custom cooling, don't forget the memory!!! Its GDDR6 it runs really hot!!!!

# Memory
- 16GB GDDR6 shared between the GPU and CPU. By default, this will be set to either 8GB/8GB (CPU/GPU) or 4GB/12GB, depending on your firmware revision, and requires flashing modified firmware to change. 
- I've seen people mention using Smokeless_UMAF to try and expose these settings; Don't try it, you may cause permanent damage.
- If you are using these boards for gaming, make sure that you set the VRAM allocation to 512MB for the best experience (After flashing firmware).

# OS Support
- Linux:
  - Works reasonably well with most hardware functional, with the exception of the GPU which requires patching mesa. Fedora is recommended, however it would be simple to get literally any distro running with the exception of any that rely on Flatpak for package distribution. 
- Windows:
  - No
  - It will boot,	but the	GPU is not supported and is unlikely to ever be. Everything else seems to work alright,	so I guess you could use it for	non-GPU focused	workloads.

# Making it work
## Simple setup script
- This should perform all of the required steps, *except* for flashing the modified firmware. 
- It should work fine on Fedora 40+ (COPR builds are not available for F39) and on Nobara 40+.  
- Run ``curl -s https://raw.githubusercontent.com/mothenjoyer69/bc250-documentation/refs/heads/main/fedora-setup.sh | sh`` as the root user (not with sudo) and sit back.
- Credit to [neggles](https://github.com/neggles) for the original version.

## Mesa
- Upstream Mesa currently lacks support for this specific GPU (Cyan Skillfish), however [work](https://gitlab.freedesktop.org/mesa/mesa/-/issues/11982) is underway to get that fixed.
  - A temporary workaround is recompiling Mesa to fake support for the GPU.  You can do this by adding [this](https://raw.githubusercontent.com/mothenjoyer69/bc250-documentation/refs/heads/main/BC250-mesa.patch) patch to Mesa .
  	- Alternatively, patched Mesa builds are available via copr, [here](https://copr.fedorainfracloud.org/coprs/g/exotic-soc/bc250-mesa/). 
  - You must set ``RADV_DEBUG=nocompute`` in ``/etc/environment`` to resolve issues with Vulkan visual issues. 
  - Some OpenGL workloads cause a GPU hang still, and most compute loads will trigger a GPU reset when the compute instance is closed. This would normally be fine, but it is unrecoverable on these boards.
  - Flatpak applications will fail to run due to the bundled mesa not having the required patches. 

## Kernel
- Kernels prior to 6.5 should boot without anything special, however anything newer will boot into a black screen. Add ``amdgpu.sg_display=0`` to your kernel command line to resolve this issue. On Fedora you can do this via ``grubby --update-kernel=ALL --args=console=amdgpu.sg_display=0``, 

# Advanced
## Modified firmware
## ***ANY DAMAGE OR ISSUES CAUSED BY FLASHING THIS MODIFIED IMAGE IS YOUR RESPONSIBILITY ENTIRELY***
- A modified firmware image is available at [this repo](https://gitlab.com/TuxThePenguin0/bc250-bios/) (Credit and massive thanks to [Segfault](https://github.com/TuxThePenguin0)). He is responsible for most of the information on running these boards. Say thank you.
- Flashing via a hardware programmer is recommended. Get yourself a CH347, or a Raspberry Pi Pico, or anything else capable of recovering from a bad BIOS flash.
- ***DO NOT FLASH ANYTHING WITHOUT HAVING A KNOWN GOOD BACKUP***
  - SPI flash header pinout:
    ![SPI flash header pinout](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/SPI_PINOUT.jpg)
- VRAM allocation is configured within: ``Chipset -> GFX Configuration -> GFX Configuration``. Set ``Integrated Graphics Controller`` to forced, and ``UMA Mode`` to  ``UMA_SPECIFIED``, and set the VRAM limit to your desired size. 512MB appears to be the best for general APU use. Credit to [Segfault](https://github.com/TuxThePenguin0)
- Many of the newly exposed settings are untested, and could either do nothing, or completely obliterate you and everyone else within a 100km radius. Or maybe they work fine. Be careful, though. 
- Note: If your board shipped with P4.00G (or any other BIOS revision that modified the memory split) you may need to fully clear the firmware settings as it can apparently get a little stuck. Removing the coin cell and using the CLR_CMOS header should suffice.        

# NCT6686 SuperIO
- In order for ``lm-sensors`` to recognize the chip (ID ``0xd441``), you must load the nct6683 driver. You can so via ``modprobe nct6683 force=true`` or by adding ``options nct6683 force=true`` to ``/etc/modprobe.d/sensors.conf``, and ``nct6683``to ``/etc/modules-load.d/99-sensors.conf`` and regenerate your initramfs.
- Once enabled you should see a bunch more sensor data reported, including important temps :)
- Massive thanks to [yeyus](https://github.com/yeyus) for [this info](https://github.com/mothenjoyer69/bc250-documentation/issues/3).

# Performance
- A GPU governor is available [here](https://gitlab.com/mothenjoyer69/oberon-governor). You should use it. Values are set in /etc/oberon-governor.yaml.
  - You can also use the following commands to set the clocks manually:
    ```
    echo vc 0 <CLOCK> <VOLTAGE> > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    echo c > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    ```

# Additional notes:
- I have repeatedly recieved requests for help from people who have not read through this page correctly. Please do not purchase these boards if any part of this page is confusing. These are not, and will not ever be, standard desktop boards, and expecting them to be is a stupid thing to do.
- I have seen an alarming number of people I have personally helped out attempt to claim the information uncovered by Segfault as their own. You all suck, credit people properly. Many of these people also seem to fall under the above note.
- God XDA sucks

# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)

# WALL OF SHAME!!!!!!!
1. ![SHAMEFUL](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/WALL_OF_SHAME_1.png)
2. ![BOO](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/WALL_OF_SHAME_2.png)
