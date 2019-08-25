#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:67108864:268ad5b6a75d7c20a9b5e996cff29f03d99b78df; then
  applypatch  EMMC:/dev/block/bootdevice/by-name/boot:67108864:85d43c5ecf00d015f28334d8282d9ec770506473 EMMC:/dev/block/bootdevice/by-name/recovery 268ad5b6a75d7c20a9b5e996cff29f03d99b78df 67108864 85d43c5ecf00d015f28334d8282d9ec770506473:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
