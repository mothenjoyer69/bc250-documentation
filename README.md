# BC-250 Documentation
Documentation for running the AMD BC-250 powered ASRock mining boards as a desktop.

# Hardware Notes
- AMD BC-250 SOC, a cut-down variant of the SOC in the PS5. This provides, roughly, a Ryzen 5 4500 + RX 6700 in terms of performance.
- 16GB memory, split by default as 8/8. Firmware patch allows for unified shared memory.
- M.2 slot supports NVMe (PCIe 2.0 x2) and SATA.
- GPU reclocking works but is not automatic, run the following to set it to "max":
  ```
  echo vc 0 2000 1000 > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
  echo c > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
  ```
- Alternatively, https://gitlab.com/TuxThePenguin0/oberon-governor is a GPU clock governor designed for the BC-250.
# Mesa
- A temporary workaround is modifying the following line in src/amd/addrlib/src/amdgpu_asic_addr.h:
  ```
  #define AMDGPU_NAVI10_RANGE     0x01, 0x0A //# 1  <= x < 10
  ```
  and changing it to
  ```
  #define AMDGPU_NAVI10_RANGE     0x01, 0x8A //# 1  <= x < 10
  ```
  Premade Mesa builds should be possible, however currently a manual build is required. ``RADV_DEBUG=nocompute`` is a required environment variable to set, in order to resolve Vulkan issues.

# Kernel
- ``amdgpu.sg_display=0`` is required to boot kernel 6.6 and later. 

# Issues
- Issues with OpenGL applications crashing/causing lockups.
- Enabling IOMMU causes a GPU related crash on startup. 



# Getting it working
- A Fedora copr repository exists for patched mesa updates: https://copr.fedorainfracloud.org/coprs/mothenjoyer69/bc250-mesa/
- AUR builds by @jvyden are available:
	- Mesa https://aur.archlinux.org/packages/mesa-amd-bc250

# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)
