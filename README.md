# BC-250 Documentation
Documentation for running the AMD BC-250 powered ASRock mining boards as a desktop.

# Hardware Notes
- AMD BC-250 SOC, a cut-down variant of the SOC in the PS5. This provides, roughly, a Ryzen 5 4500 + RX 6700 in terms of performance.
- 16GB memory, in an 8/8 split to the CPU and GPU. Cannot be changed currently, being looked into.
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
# Issues
- Some Vulkan software/games experience major texture corruption.
- Issues with OpenGL locking up system.
# Todo
1. GPU
   - Investigate Vulkan corruption issues
   - Investigate OpenGL hangs
2. Memory
   - Investigate modified memory split
3. General
   - Produce testing images.
# Testing Images
- WIP Debian image. WIP SteamOS/Chimera image
