_G._BOOTLOADER_VERSION = 0
local config = textutils.unserialise(fs.open("bootloader_config.cfg", "r").readAll())

dofile("drivers/filesystem.lua")

term.clear()
term.setCursorPos(1, 1)
print("SychOS BootLoader (".._BOOTLOADER_VERSION..")")

print("Mounting boot image ("..config.boot_image..")")
fs.mount(config.boot_image, "")

dofile("/kernel.lua")
