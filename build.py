"""Build the USA revision 0 patch from the original game and base IPS."""
import argparse
import hashlib
import os
from pathlib import Path
import struct
import subprocess

ROOT = Path(__file__).resolve().parent
BASE = 0x100000
TEXT_SIZE = 0x27B000
TITLE_ID = "0004000000035800"
CODE_SHA256 = "a128741ca5b0ace56534c937f59164dc16f8c39e957a07c5a6c2fc824dd229b8"
BASE_IPS_SHA256 = "5494759a0ebd2b84c6350376a2c187a1bdbd87d7db9abc8903f2ed3372395e8b"
TEXT_SHA256 = "b74b40f1bac08cd7098e018410e6d796e3f667ac236411443ebac1f0b8b886b9"
IPS_SHA256 = "9e4e5f530c9d3514367262cc7ee3bf181a065fd5b8d7fb2fffe673c93822396a"
HEADER_SHA256 = "1efdf2fe1675df1ba61872c51dfd21b9097c52ea5519297d2ef366fa27b769de"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def checked(data, expected, name):
    actual = digest(data)
    if actual != expected:
        raise ValueError(f"{name}: SHA256 {actual}; expected {expected}")
    return data


def apply_ips(original, patch):
    if not patch.startswith(b"PATCH"):
        raise ValueError("Invalid IPS header")
    image = bytearray(original)
    cursor = 5
    while patch[cursor:cursor + 3] != b"EOF":
        if cursor + 5 > len(patch):
            raise ValueError("Truncated IPS record")
        offset = int.from_bytes(patch[cursor:cursor + 3], "big")
        size = int.from_bytes(patch[cursor + 3:cursor + 5], "big")
        cursor += 5
        if size:
            payload = patch[cursor:cursor + size]
            if len(payload) != size:
                raise ValueError("Truncated IPS payload")
            cursor += size
        else:
            if cursor + 3 > len(patch):
                raise ValueError("Truncated IPS run")
            size = int.from_bytes(patch[cursor:cursor + 2], "big")
            payload = patch[cursor + 2:cursor + 3] * size
            cursor += 3
        if not size or offset + size > TEXT_SIZE:
            raise ValueError("IPS record outside executable text")
        image[offset:offset + size] = payload
    if cursor + 3 != len(patch):
        raise ValueError("Unexpected IPS trailer")
    return image


def make_ips(original, image):
    regions = []
    for offset in range(0, TEXT_SIZE, 4):
        if image[offset:offset + 4] == original[offset:offset + 4]:
            continue
        if regions and offset - regions[-1][1] <= 4:
            regions[-1] = (regions[-1][0], offset + 4)
        else:
            regions.append((offset, offset + 4))
    patch = bytearray(b"PATCH")
    for start, end in regions:
        payload = image[start:end]
        if len(payload) >= 65536:
            raise ValueError("IPS record too large")
        patch += start.to_bytes(3, "big") + len(payload).to_bytes(2, "big") + payload
    return bytes(patch + b"EOF")


def write_word(image, address, value):
    struct.pack_into("<I", image, address - BASE, value)


def branch(source, target, link=False):
    delta = target - source - 8
    if delta % 4 or not -0x2000000 <= delta < 0x2000000:
        raise ValueError("ARM branch out of range")
    return (0xEB000000 if link else 0xEA000000) | ((delta // 4) & 0xFFFFFF)


def build(args):
    original = checked(args.code.read_bytes(), CODE_SHA256, "Original decompressed .code")
    base_patch = checked(args.base_ips.read_bytes(), BASE_IPS_SHA256, "Base crash-fix IPS")
    header = bytearray(args.exheader.read_bytes())
    if len(header) != 2048:
        raise ValueError("Original extended header must be 2048 bytes")
    old_bss = struct.unpack_from("<I", header, 0x3C)[0]
    struct.pack_into("<I", header, 0x3C, old_bss + 0x32000)
    checked(header, HEADER_SHA256, "Patched extended header")

    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    source = ROOT / "source"

    def tool(name, *arguments):
        executable = "arm-none-eabi-" + name + (".exe" if os.name == "nt" else "")
        command = str(args.toolchain / executable) if args.toolchain else executable
        return subprocess.check_output([command, *map(str, arguments)], cwd=output, text=True)

    options = ["-Os", "-march=armv6k", "-mfpu=vfp", "-mfloat-abi=hard",
               "-ffreestanding", "-fno-strict-aliasing", "-fno-math-errno",
               "-fno-trapping-math", "-ffunction-sections", "-fdata-sections",
               "-fno-unwind-tables", "-fno-asynchronous-unwind-tables",
               "-Wall", "-Wextra", "-Werror"]
    for name in ("affine", "cache"):
        tool("gcc", *options, "-c", source / (name + ".c"), "-o", name + ".o")
    for name in ("hooks", "wait", "quaternion"):
        tool("as", "-march=armv6k", "-mfpu=vfp", source / (name + ".s"), "-o", name + ".o")
    tool("ld", "-T", source / "layout.ld", "affine.o", "cache.o", "hooks.o",
         "wait.o", "quaternion.o", "-o", "mod.elf")

    elf = (output / "mod.elf").read_bytes()
    elf_header = struct.unpack_from("<16sHHIIIIIHHHHHH", elf)
    if elf_header[0][:7] != b"\x7fELF\x01\x01\x01" or elf_header[2] != 40:
        raise ValueError("Expected a little-endian ARM ELF32 file")
    sections = [struct.unpack_from("<10I", elf, elf_header[6] + i * elf_header[11])
                for i in range(elf_header[12])]
    symbols = {line.split()[2]: int(line.split()[0], 16)
               for line in tool("nm", "mod.elf").splitlines() if len(line.split()) == 3}
    image = apply_ips(original, base_patch)

    # Restore replaced base-patch stubs and the optional FPS-counter call.
    for start, end in [(0x37AEAC, 0x37AED0), (0x37AF84, 0x37AF8C),
                       (0x37AFB8, 0x37AFF0), (0x37AFF8, 0x37B000),
                       (0x16BF14, 0x16BF24), (0x32C7F0, 0x32C7F4),
                       (0x201174, 0x201178)]:
        image[start - BASE:end - BASE] = original[start - BASE:end - BASE]
    for section in sections:
        if section[1] == 1 and section[2] & 2 and section[5]:
            address, size = section[3], section[5]
            if not BASE <= address or address + size > BASE + TEXT_SIZE:
                raise ValueError("Linked section outside executable text")
            image[address - BASE:address - BASE + size] = elf[section[4]:section[4] + size]

    # All phase readers share the reserved BSS state at this base address.
    for address in (0x3337E0, 0x37AFF4):
        write_word(image, address, 0x47D000)
    for address in (0x13886C, 0x138ABC, 0x15FEB8, 0x16BBA0, 0x16BEAC,
                    0x16BF24, 0x16BFE0, 0x16C0C0, 0x17C0A8, 0x18A614, 0x1AC784):
        write_word(image, address, 0xE12FFF1E)
    hooks = [(0x32C1FC, "frame_hook", True), (0x245E78, "matrix_first", False),
             (0x245E40, "matrix_second", False), (0x354A00, "bind_world", False),
             (0x354ACC, "bind_view", False), (0x349964, "allocate_hook", False),
             (0x1E64E0, "destroy_hook", False), (0x37AFB4, "wait_for_vblank", False),
             (0x1E2020, "scene_hook", False), (0x1FD280, "camera_destroy_hook", False),
             (0x34BD50, "effect_bind", False), (0x34BEFC, "effect_first", True),
             (0x34BF28, "effect_second", True), (0x1BF2D4, "badge_camera34", True),
             (0x1BF2F8, "badge_camera44", True), (0x1BF538, "badge_car_position", True),
             (0x1BB678, "badge_back_render", False)]
    for address, name, link in hooks:
        write_word(image, address, branch(address, symbols[name], link))
    checked(image[:TEXT_SIZE], TEXT_SHA256, "Rebuilt executable text")
    patch = checked(make_ips(original, image), IPS_SHA256, "Rebuilt IPS")
    if apply_ips(original, patch) != image:
        raise ValueError("IPS round-trip mismatch")

    destination = output / TITLE_ID
    destination.mkdir(exist_ok=True)
    (destination / "code.ips").write_bytes(patch)
    (destination / "exheader.bin").write_bytes(header)
    print(f"Verified release bytes written to {destination}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--code", type=Path, required=True, help="Original decompressed USA .code")
    parser.add_argument("--exheader", type=Path, required=True, help="Original 2048-byte game exheader")
    parser.add_argument("--base-ips", type=Path, required=True, help="AEONG_AEONG's crash-fix IPS")
    parser.add_argument("--toolchain", type=Path, help="Directory containing arm-none-eabi tools")
    parser.add_argument("--output", type=Path, default=ROOT / "build")
    args = parser.parse_args()
    try:
        build(args)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Build failed: {error}\n")


if __name__ == "__main__":
    main()
