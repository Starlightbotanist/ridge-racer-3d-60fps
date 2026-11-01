Ridge Racer 3D USA - 60 FPS

Target: USA revision 0, CTR-P-ARRE, title 0004000000035800.

Includes camera interpolation during turns and drifts, matching nitrous effect
transforms, rival badge position interpolation, allocation/history handling,
VBlank corrections and the original author's file-read queue crash fix.
Simulation and animation retain their original progression rates. The lower
screen, menus and pause screens remain at their native 30 FPS. The optional
hold-SELECT FPS counter is removed.

Choose one archive
  ridge-racer-3d-usa-60fps.zip
    Standard: retains bloom/glare and motion blur.
  ridge-racer-3d-usa-60fps-no-bloom.zip
    Removes bloom/glare; retains motion blur.
  ridge-racer-3d-usa-60fps-no-motion-blur.zip
    Retains bloom/glare; removes motion blur.
  ridge-racer-3d-usa-60fps-no-bloom-no-motion-blur.zip
    Removes both effects, as in the previous release.

Every version contains the complete patch and the same fixes. Install only
one version. The loose release code.ips is the standard version; exheader.bin
is identical in every version.

Installation in Azahar
1. Stop the game and disable other FPS, animation and post-processing mods.
2. Remove the previous code.ips from both the title's mod folder and its exefs
   subfolder. An existing exefs/code.ips takes precedence over the root file.
3. Copy the chosen archive's 0004000000035800 folder into the Azahar user
   folder's load/mods directory. Both files are required:
     load/mods/0004000000035800/code.ips
     load/mods/0004000000035800/exheader.bin
4. Cold boot the USA game and use its regular save. Save states from another
   patch can restore old executable code.

The header reserves an additional 200 KiB of loader-owned BSS memory. CPU
boost and memory-mode flags retain their original values. Remove both mod
files to uninstall. The ROM and regular game save are not modified.

README.md contains build instructions. TESTING.txt records validation and
limits. Source and build files are included; game files and the original
author's base IPS are not included.

Base 60 FPS/crash-fix patch: AEONG_AEONG
https://gbatemp.net/threads/i-created-a-60-fps-patch-for-ridge-racer-3d-on-the-3ds.684957/
