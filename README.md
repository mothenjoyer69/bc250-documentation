# About
This page is for documentation and information on the ASRock/AMD BC-250, and about running it as a general purpose PC. These are compute units sold in a 4u rackmount chassis for the purpose of crypto mining. Thankfully everyone who bought these for that purpose lost a lot of money and is selling them off for cheap!

# Hardware info
- Features an AMD BC250 APU, codenamed 'Ariel', a cut-down variant of the APU in the PS5. It integrates 6x Zen 2 cores, at up to 3.49GHz (ish), as well as a 24CU RDNA2 iGPU (Codename 'cyan-skillfish'). The standard PS5 SoC has 36CUs.
- 1x M.2 2280 slot with support for NVMe (PCIe 2.0 x2) and SATA 3
- 1x DisplayPort, 1x GbE Ethernet, 2x USB 2.0, 2x USB 3.0
- 1x SPI header, 1x auto-start jumper, 1x clear CMOS jumper, 5x fans (non-standard connector), 1x TPM header
- NCT6686 SuperIO chip
- 220W TDP, so make sure you have a good quality power supply with PCIe 8-pin connectors available and a plan for cooling it. You can, in a pinch, get away with directly placing two 120mm fans directly on top of the heatsink. If you are doing custom cooling, don't forget the memory!!! Its GDDR6 it runs really hot!!!!

## Hardware Details

Further connector pinouts and a detailed listing of chip ID can be found on the [hardware page](./hardware.md).

### Power

`J1000` is a standard 8-pin 12V PCIe power connector and is sufficient

`J2000` and `J2001` are compatible with 8-pin Molex Micro-Fit connectors and are pinned as below:

```
   v                     v
[ LED1 12V 12V 12V ]  [ 12V 12V 12V GND ]
[ LED2 GND GND GND ]  [ GND GND GND PGD ]
```

For more detail on the non-power pins, check [their section of the hardware page](./hardware.md#j2000-and-j2001).

### Fans

`CPU_FAN1` is a normal 4-pin PWM-capable fan header. `J4003` exposes `CPU_FAN1` as `F1*` and provides four additional PWM fan control signals as follows, though no power is provided from this connector.

```
[ GND F1T F2T F3T F4T F5T DET     ]
[ GND F1P F2P F3P F4P F5P GND GND ]
   ^
```

The `F*T` pins are the tachometer outputs from each respective fan, and the `F*P` pins are the PWM outputs that can be sued to control their speeds. Note that the `F1*` pins are electically connected to `CPU_FAN1`.

# Memory
- 16GB GDDR6 shared between the GPU and CPU. By default, this will be set to either 8GB/8GB (CPU/GPU) or 4GB/12GB, depending on your firmware revision, and requires flashing modified firmware to change. 
- I've seen people mention using Smokeless_UMAF to try and expose these settings; Don't try it, you may cause permanent damage.
- If you are using these boards for gaming, make sure that you set the VRAM allocation to 512MB for the best experience (After flashing firmware).

# OS Support
- Linux:
  - At this point, Linux support is almost perfect. Pretty much any distro shipping a modern kernel + mesa should work fine.
  - Don't run LTS distros on this hardware.
- Windows:
  - No
  - It will boot, but the GPU is not supported by any drivers and is unlikely to ever be. Everything else seems to work alright, so I guess if you've been kicked in the head recently you could use it for non-GPU focused workloads.
- MacOS:
  - Next person to ask this will be asked to find out if the PCIe bracket counts as a flared base.
  
# Making it work
It should all just work with any recent release from Fedora/Bazzite etc. However, HW encode/decode *will not work* because we are missing the required firmware. This probably won't change any time soon, as Sony are the ones blocking this. 
## Mesa
- Upstream support [landed](https://gitlab.freedesktop.org/mesa/mesa/-/merge_requests/33116) in Mesa 25.1. This should be shipped by most big distros at this point
- You may also need to set ``ttm.pages_limit=3959290`` and ``ttm.page_pool_size=3959290`` as kernel options to access more than 8GB of the shared memory. Thanks Magnap :)
  
# Advanced
## Modified firmware
## ***ANY DAMAGE OR ISSUES CAUSED BY FLASHING THIS MODIFIED IMAGE IS YOUR RESPONSIBILITY ENTIRELY***
- A modified firmware image is available at [this repo](https://gitlab.com/TuxThePenguin0/bc250-bios/) (Credit and massive thanks to [Segfault](https://github.com/TuxThePenguin0)). He is responsible for most of the information on running these boards. Say thank you.
- Flashing via a hardware programmer is recommended. Get yourself a CH347, or a Raspberry Pi Pico, or anything else capable of recovering from a bad BIOS flash.
- ***DO NOT FLASH ANYTHING WITHOUT HAVING A KNOWN GOOD BACKUP***
  - SPI flash header pinout:
    ```
      [ GND SCLK MOSI    ]
      [ VCC  CS  MISO  ? ]
         ^
      ```
- VRAM allocation is configured within: ``Chipset -> GFX Configuration -> GFX Configuration``. Set ``Integrated Graphics Controller`` to forced, and ``UMA Mode`` to  ``UMA_SPECIFIED``, and set the VRAM limit to your desired size. 512MB is best for general APU use. You will have a worse experience overall with a 4/12 split, outside of specific circumstances. Credit to [Segfault](https://github.com/TuxThePenguin0)
- Many of the newly exposed settings are untested, and could either do nothing, or completely obliterate you and everyone else within a 100km radius. Or maybe they work fine. Be careful, though.
- Note: If your board shipped with P4.00G (or any other BIOS revision that modified the memory split) you may need to fully clear the firmware settings as it can apparently get a little stuck. Removing the coin cell and using the CLR_CMOS header should suffice.

## NCT6686 SuperIO
- In order for ``lm-sensors`` to recognize the chip (ID ``0xd441``), you must load the nct6683 driver. You can so via ``modprobe nct6683 force=true`` or by adding ``options nct6683 force=true`` to ``/etc/modprobe.d/sensors.conf``, and ``nct6683``to ``/etc/modules-load.d/99-sensors.conf`` and regenerate your initramfs.
- Once enabled you should see a bunch more sensor data reported, including important temps :)
- Massive thanks to [yeyus](https://github.com/yeyus) for [this info](https://github.com/mothenjoyer69/bc250-documentation/issues/3).

## Performance
- A GPU governor is available [here](https://gitlab.com/mothenjoyer69/oberon-governor). You should use it. Values are set in /etc/oberon-config.yaml.
- This is also available as a Fedora COPR package [here](https://copr.fedorainfracloud.org/coprs/g/exotic-soc/oberon-governor/).
  - You can also use the following commands to set the clocks manually:
    ```
    echo vc 0 <CLOCK> <VOLTAGE> > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    echo c > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
    ```

# Additional notes:
- These boards more or less just work now, and all you need to do is install a distro, install the GPU governor, and then go to town. 
- Please don't make issues asking for help with anything *but* these boards.
- A discord server exists [here](https://discord.gg/uDvkhNpxRQ). This is a community of people running and pushing the limits of these boards. Feel free to say hi.

# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)
- [yeyus](https://github.com/yeyus)

# WALL OF SHAME!!!!!!!
1. ![SHAMEFUL](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/WALL_OF_SHAME_1.png)
2. ![BOO](https://github.com/mothenjoyer69/bc250-documentation/blob/main/images/WALL_OF_SHAME_2.png)
