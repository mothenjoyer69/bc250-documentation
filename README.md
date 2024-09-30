# BC-250 Documentation
Documentation for running the AMD BC-250 powered ASRock mining boards as a desktop.

# Hardware Notes
- AMD BC-250 SOC, a cut-down variant of the SOC in the PS5. This provides, roughly, a Ryzen 5 4500 + RX 6700 in terms of performance.
- 16GB memory, in an 8/8 split to the CPU and GPU. Cannot currently be modified.
- M.2 slot supports NVMe + SATA (Hypothetically).
- GPU relocking is possible via:
  ```
  echo vc 0 2000 1100 > /sys/devices/pci0000:00/0000:00:08.1/0000:01:00.0/pp_od_clk_voltage
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
- 6.5 and lower should work without modification. 6.6 should work with commit 5a3ccb1400339268c5e3dc1fa044a7f6c7f59a02 reverted. 

# Issues
- Some Vulkan software/games experience major texture corruption.
- Issues with OpenGL locking up system.
- Enabling IOMMU causes a GPU related crash on startup. 

# Todo
1. GPU
   - Investigate Vulkan corruption issues
   - Investigate OpenGL hangs
2. Memory
   - Investigate modified memory split
3. General
   - Produce testing images.

# Testing Images
- Still WIP
- RPMs for patched kernel + mesa should be available. Expect crashes, glitches, and artefacts.


# Credits
- [Segfault](https://github.com/TuxThePenguin0)
- [neggles](https://github.com/neggles)
