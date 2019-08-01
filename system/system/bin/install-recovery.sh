#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/bootdevice/by-name/recovery:67108864:296b30bd6701e0cd3abb3df16cfea0cdab2b8502; then
  applypatch  EMMC:/dev/block/bootdevice/by-name/boot:67108864:3044e7a0c074f28481ee7d000802e74522c954e7 EMMC:/dev/block/bootdevice/by-name/recovery 296b30bd6701e0cd3abb3df16cfea0cdab2b8502 67108864 3044e7a0c074f28481ee7d000802e74522c954e7:/system/recovery-from-boot.p && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
else
  log -t recovery "Recovery image already installed"
fi
