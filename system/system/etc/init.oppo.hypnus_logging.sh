#!/system/bin/sh
#
#ifdef VENDOR_EDIT
#yan.chen@swdp.shanghai, 2016/07/25
#enable=`getprop persist.sys.oppo.junklog`
enable=true

case "$enable" in
    "true")
        echo 1 > /sys/module/hypnus/parameters/enable_logging
        ;;
    "false")
        echo 0 > /sys/module/hypnus/parameters/enable_logging
        ;;
esac
