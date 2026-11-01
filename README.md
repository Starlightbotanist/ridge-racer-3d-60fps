# Ridge Racer 3D - 60 FPS

Rendering and animation corrections for the USA revision 0 game, based on
[AEONG_AEONG's 60 FPS and crash-fix patch](https://gbatemp.net/threads/i-created-a-60-fps-patch-for-ridge-racer-3d-on-the-3ds.684957/).

**[Download the patch](https://github.com/Starlightbotanist/ridge-racer-3d-60fps/releases/latest)**

Target: **USA revision 0**, product code `CTR-P-ARRE`, title ID `0004000000035800`.
This repository contains the added C/ARM routines, their linker layout, a build
script, and four IPS/header variants. It does not contain the game executable,
assets, saves, or the original author's complete source.

## Changes

- Preserves the original simulation and animation rates while rendering races at up to 60 FPS.
- Interpolates camera position and orientation in world space to correct car alternation during fast turns and drifts.
- Keeps nitrous effect world, inverse-world and camera transforms consistent between frames.
- Interpolates rival badge positions above cars and at the screen edge.
- Separates transform history by object and render context, invalidates reused allocations, and handles missing or ambiguous history.
- Retains AEONG_AEONG's file-read queue crash correction.

The optional hold-SELECT FPS counter is removed. The lower screen, menus and
pause screens retain their native 30 FPS rendering. The additional BSS memory
reservation is 200 KiB.

## Choose a version

Every version includes the same timing, camera, effect, badge and crash fixes.
The standard version retains the game's bloom/glare and motion blur.

| Version | Bloom/glare | Motion blur | Release archive |
| --- | --- | --- | --- |
| Standard (default) | Retained | Retained | `ridge-racer-3d-usa-60fps.zip` |
| No bloom | Removed | Retained | `ridge-racer-3d-usa-60fps-no-bloom.zip` |
| No motion blur | Retained | Removed | `ridge-racer-3d-usa-60fps-no-motion-blur.zip` |
| No bloom or motion blur | Removed | Removed | `ridge-racer-3d-usa-60fps-no-bloom-no-motion-blur.zip` |

Use one version at a time. Each archive contains the complete `code.ips` and
`exheader.bin` pair; the optional versions replace the standard version.
"No bloom or motion blur" retains the effect settings of the previous release.
The loose release assets and the repository's `0004000000035800` folder are
the standard version. The other pairs are under `variants` in the repository.

## Install in Azahar

1. Stop the game and disable other FPS, animation and motion-blur cheats/mods.
2. Remove the previous `code.ips` from both the title's mod folder and its `exefs`
   subfolder. An existing `exefs/code.ips` takes precedence over the title-folder file.
3. Extract the release and copy the `0004000000035800` folder into your Azahar
   user folder's `load/mods` directory. Both files are required:

   ```text
   load/mods/0004000000035800/code.ips
   load/mods/0004000000035800/exheader.bin
   ```

4. Cold boot the USA game and use its regular game save. Emulator save states
   made with another patch can restore old executable code.

Remove both mod files to uninstall. The ROM and regular save are not modified
by installing the patch.

## Build

The build requires Python 3, devkitARM, and these locally supplied inputs:

- The original decompressed `.code` from your USA revision 0 game.
- The original game's 2048-byte extended header, before any patch.
- The original **60 FPS plus crash-fix** `code.ips` from AEONG_AEONG.

The original IPS is an input dependency; it is not included here. The build
overlays the assembled routines and native hooks on that patch. The script
checks input hashes and verifies each variant's release hashes before writing
the installable files. All variants share one compiled code layout.

Native Windows PowerShell example:

```powershell
python .\build.py `
  --code 'C:\private\rr3d-usa\code.bin' `
  --exheader 'C:\private\rr3d-usa\exheader.bin' `
  --base-ips 'C:\private\rr3d-base-patch\code.ips' `
  --toolchain 'C:\devkitPro\devkitARM\bin'
```

The default output goes to `build/standard/0004000000035800`. Select another
version with `--variant no-bloom`, `--variant no-motion-blur`, or
`--variant no-bloom-no-motion-blur`; `--variant all` builds all four pairs.
The tested toolchain is
**devkitARM release 47, GCC 7.1.0**. The fixed linker layout guards routine
sizes. A different compiler or a source change may require updating the layout
and release identities before producing a different build.

Source files:

| File | Purpose |
| --- | --- |
| `source/affine.c`, `source/quaternion.s` | Rotation-aware affine and quaternion interpolation |
| `source/cache.c` | Transform history, effect transforms and rival badge positions |
| `source/hooks.s` | Native entry hooks, camera view reconstruction and object lifetime handling |
| `source/wait.s` | VBlank wait with counter wrap/reset handling |
| `source/layout.ld` | Fixed code placement and section-size checks |
| `source/hooks.json`, `source/variants.json` | Native hooks, effect selection and release hashes |
| `build.py` | Input validation, compilation, patch assembly and output verification |

## Validation and limits

The shared interpolation routines have compiled ARM coverage for camera poses,
affine transforms, object ownership, invalidation, animation stepping, effect
matrices and both badge consumers. The relocated blur-alpha helper is checked
against the original author's implementation. Each variant's binary is checked
to differ only at its selected post-processing callback entries.
[TESTING.txt](TESTING.txt) records gameplay conditions and limits;
[MANIFEST.json](MANIFEST.json) records the checked-in file hashes.

The lower screen intentionally remains at 30 FPS, including minimap markers.
Every course, vehicle, particle effect and nitrous type has not been covered.
Physical 3DS and other regions are untested with this revision.

## Credits

**AEONG_AEONG** created the original 60 FPS interpolation and crash-fix patch.
This project builds on that work. See the
[original release thread](https://gbatemp.net/threads/i-created-a-60-fps-patch-for-ridge-racer-3d-on-the-3ds.684957/)
for its release and installation documentation.
