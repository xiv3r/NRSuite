Import("env")
import os

def merge_bin_action(source, target, env):
    board = env.BoardConfig()
    flash_size = board.get("upload.flash_size", "4MB")
    build_dir = env.subst("$BUILD_DIR")

    bootloader = os.path.join(build_dir, "bootloader.bin")
    partitions = os.path.join(build_dir, "partitions.bin")
    firmware = os.path.join(build_dir, "firmware.bin")
    merged = os.path.join(build_dir, "merged-firmware.bin")

    # Bootloader offset differs by chip family
    mcu = board.get("build.mcu", "esp32")
    boot_offset = "0x0" if mcu in ("esp32s3", "esp32", "esp32s2") else "0x0"
    if mcu == "esp32c3":
        boot_offset = "0x0"

    chip = mcu

    cmd = (
        f'"{env.subst("$PYTHONEXE")}" -m esptool '
        f'--chip {chip} merge_bin -o "{merged}" '
        f'--flash_size {flash_size} '
        f'{boot_offset} "{bootloader}" '
        f'0x8000 "{partitions}" '
        f'0x10000 "{firmware}"'
    )
    print(f"Merging binaries -> {merged}")
    env.Execute(cmd)

env.AddPostAction("$BUILD_DIR/${PROGNAME}.bin", merge_bin_action)