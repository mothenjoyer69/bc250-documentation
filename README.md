# BC-250 Documentation
Documentation for running the AMD BC-250 powered ASRock mining boards as a desktop.

# Hardware Notes
- AMD BC-250 SOC, a cut-down variant of the SOC in the PS5. This provides, roughly, a Ryzen 5 4500 + RX 6700 in terms of performance.
- 16GB memory, in an 8GB/8GB split to the CPU and GPU. Cannot currently be modified.
- M.2 slot supports NVMe + SATA (Hypothetically).
- GPU relocking is possible via:
  ```
  echo vc 0 2000 1000 > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
  echo c > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
  ```
# Mesa
- A temporary workaround is modifying the following line in src/amd/addrlib/src/amdgpu_asic_addr.h:
  ```
  #define AMDGPU_NAVI10_RANGE     0x01, 0x0A //# 1  <= x < 10
  ```
  and changing it to
  ```
  #define AMDGPU_NAVI10_RANGE     0x01, 0x8A //# 1  <= x < 10
  ```
  Premade Mesa builds should be possible, however currently a manual build is required.

# Kernel
- ``amdgpu.sg_display=0`` is required to boot kernel 6.6 and later. 

# Issues
- Issues with OpenGL applications crashing/causing lockups.
- Enabling IOMMU causes a GPU related crash on startup. 

# Todo
1. GPU
   - Investigate OpenGL hangs
2. Memory
   - Investigate modified memory split

# Getting it working
- A Fedora copr repository exists for patched mesa updates: https://copr.fedorainfracloud.org/coprs/mothenjoyer69/bc250-mesa/
- AUR builds by @jvyden are available:
	- Mesa https://aur.archlinux.org/packages/mesa-amd-bc250

# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)
