#!/system/bin/sh

config="$1"
para="$2"

function doSwitchEng {
    atm_mode=`getprop ro.boot.atm`
    if [[ ${para} == "mc" ]] || [[ ${para} == "ftm" ]] || [[ ${atm_mode} == "enable" ]]
    then
        setprop persist.sys.allcommode true
        setprop persist.sys.oppo.usbactive true
        setprop persist.sys.adb.engineermode 0
        is_mtk=`getprop ro.vendor.mediatek.platform`
        if [[ ${is_mtk} ]] ; then
            if [[ ${atm_mode} != "enable" ]]; then
                setprop sys.usb.config adb
                setprop persist.sys.usb.config adb
            fi
         else
            setprop sys.usb.config diag,adb
            setprop persist.sys.usb.config diag,adb
        fi

        if [[ ${para} = "mc" ]]; then
            setprop persist.sys.oppo.fromadbclear true
        fi
    fi
}

function doCpustressAging {
    cpustress_eng --cpu 8 --io 4 --vm 2 --vm-bytes 128M --timeout 24h
}


function doCacheAging {
    cachebench_eng
}

function doLoopDDRSwitch {
    while true
    do
    echo "{class: ddr, res: fixed, val: 1000}" > /sys/kernel/debug/aop_send_message
    cat /sys/kernel/debug/clk/measure_only_bimc_clk/clk_measure
    /system/bin/sleep 0
    echo "{class: ddr, res: fixed, val: 1800}" > /sys/kernel/debug/aop_send_message
    cat /sys/kernel/debug/clk/measure_only_bimc_clk/clk_measure
    /system/bin/sleep 0
    done
}

function doStopDDRSwitch {
    echo "{class: ddr, res: capped, val: 1800}" > /sys/kernel/debug/aop_send_message
}

case "$config" in
    "switchEng")
    doSwitchEng
    ;;
    "startCpustressAging")
    doCpustressAging
    ;;
    "startCacheAging")
    doCacheAging
    ;;
    "loopDDRSwitch")
    doLoopDDRSwitch
    ;;
    "stopDDRSwitch")
    doStopDDRSwitch
    ;;
esac
