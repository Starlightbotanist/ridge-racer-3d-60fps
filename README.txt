Ridge Racer 3D USA - 60 FPS effects fix

Target: USA revision 0, CTR-P-ARRE, title 0004000000035800.

Corrects displaced nitrous exhaust flames during drifts. Effect world, inverse
world and camera transforms now use matching interpolation histories.

Adds position interpolation for rival badges, both above cars and at the screen
edge. Their movement updates between simulation ticks without advancing their
native animation or gameplay updates twice.

Retains the camera-pose correction, original simulation/animation rates,
motion-blur disable and full-screen bloom/glare disable. Menus and pause
screens retain their native frame rate. The optional hold-SELECT FPS counter
remains removed.

Installation in Azahar
1. Stop the game and disable other FPS, animation and motion-blur cheats/mods.
2. Remove the previous code.ips from both the title's mod folder and its exefs
   subfolder. An older exefs/code.ips takes precedence over the title-folder file.
3. Copy the included 0004000000035800 folder into the Azahar user folder's
   load/mods directory. Both files are required:
     load/mods/0004000000035800/code.ips
     load/mods/0004000000035800/exheader.bin
4. Cold boot the USA game and use its regular game save. Do not load an emulator
   save state containing code from a previous patch.

The header retains the same additional 200 KiB of loader-owned BSS memory.
CPU boost and memory-mode flags are unchanged. Remove both mod files to
uninstall. Installing the patch does not modify the ROM or regular game save.

See TESTING.txt for validation and limits. The source folder contains the added
routines and their layout; it is not a complete reconstruction of the game or
base patch. Extracted game code, saves and diagnostic tools are not included.

Base 60 FPS/crash-fix patch: AEONG_AEONG
https://gbatemp.net/threads/i-created-a-60-fps-patch-for-ridge-racer-3d-on-the-3ds.684957/
