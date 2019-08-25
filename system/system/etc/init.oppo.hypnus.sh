#!/system/bin/sh
#
#ifdef VENDOR_EDIT
#jie.cheng@swdp.shanghai, 2015/11/09, add init.oppo.hypnus.sh
function log2kernel()
{
    echo "hypnus: "$1 > /dev/kmsg
}

loop_times=15

#wait data partition
if [ "$0" != "/data/oppo_lib/init.oppo.hypnus.sh" ]; then
    iter=0
    while [ iter -lt $loop_times ]; do
        #TODO: ext4 and f2fs
        if [ "`stat -f -c '%t' /data/`" == "ef53" -o "`stat -f -c '%t' /data/`" == "f2f52010" ]; then
            break
        fi
        log2kernel "wait for data partition, retry: iter=$iter"
        iter=$(($iter+1));
        sleep 2
    done

    if [ iter -ge $loop_times ]; then
        log2kernel "data partition is not mounted, Installation maybe fail"
    fi

    if [ -f /data/oppo_lib/init.oppo.hypnus.sh ]; then
        /system/bin/sh /data/oppo_lib/init.oppo.hypnus.sh
        log2kernel "run /data/oppo_lib/init.oppo.hypnus.sh"
        exit 0
    fi
else
        log2kernel "load sh from data partition"
fi

complete=`getprop sys.boot_completed`
enable=`getprop persist.sys.enable.hypnus`

if [ ! -n "$complete" ] ; then
     complete=0
fi

case "$enable" in
    "1")
        log2kernel "module insmod beging!"
        #disable core_ctl
        echo 1 > /sys/devices/system/cpu/cpu0/core_ctl/disable
        n=0
        while [ n -lt 3 ]; do
            #load data folder module if it is exist
            if [ -f /data/oppo_lib/hypnus.ko ]; then
                insmod /data/oppo_lib/hypnus.ko -f boot_completed=$complete
            else
                insmod /system/lib/modules/hypnus.ko -f boot_completed=$complete
            fi
            if [ $? != 0 ];then
                n=$(($n+1));
                log2kernel "Error: insmod hypnus.ko failed, retry: n=$n"
            else
                log2kernel "module insmod succeed!"
                break
            fi
        done

        if [ n -ge 3 ]; then
             log2kernel "Fail to insmod hypnus module!!"
        fi

        chown system:system /sys/kernel/hypnus/scene_info
        chown system:system /sys/kernel/hypnus/action_info
        chown system:system /sys/kernel/hypnus/view_info
        chown system:system /sys/kernel/hypnus/notification_info
        chown system:system /sys/kernel/hypnus/log_state
        chown system:system /sys/kernel/hypnus/perfmode
        chmod 0664 /sys/kernel/hypnus/notification_info
        chmod 0664 /sys/kernel/hypnus/touch_boost
        chown system:system /sys/kernel/hypnus/touch_boost
        chown system:system /sys/kernel/hypnus/high_perfmode
        chown system:system /sys/kernel/hypnus/reload_config
        chcon u:object_r:sysfs_hypnus:s0 /sys/kernel/hypnus/view_info
        # 1 queuebuffer only; 2 queue and dequeuebuffer;
        setprop persist.report.tid 2
        chown system:system /data/hypnus
        log2kernel "module insmod end!"
        ;;
    "0")
        rmmod hypnus
        log2kernel "Remove hypnus module"
        # Bring up all cores online
        echo 1 > /sys/devices/system/cpu/cpu0/online
        echo 1 > /sys/devices/system/cpu/cpu1/online
        echo 1 > /sys/devices/system/cpu/cpu2/online
        echo 1 > /sys/devices/system/cpu/cpu3/online
        echo 1 > /sys/devices/system/cpu/cpu4/online
        echo 1 > /sys/devices/system/cpu/cpu5/online
        echo 1 > /sys/devices/system/cpu/cpu6/online
        echo 1 > /sys/devices/system/cpu/cpu7/online
        #unisolate all cores
        echo 0 > /sys/devices/system/cpu/cpu0/isolate
        echo 0 > /sys/devices/system/cpu/cpu1/isolate
        echo 0 > /sys/devices/system/cpu/cpu2/isolate
        echo 0 > /sys/devices/system/cpu/cpu3/isolate
        echo 0 > /sys/devices/system/cpu/cpu4/isolate
        echo 0 > /sys/devices/system/cpu/cpu5/isolate
        echo 0 > /sys/devices/system/cpu/cpu6/isolate
        echo 0 > /sys/devices/system/cpu/cpu7/isolate

        # Enable low power modes
        echo 0 > /sys/module/lpm_levels/parameters/sleep_disabled

        #governor settings
        echo 576000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        echo 1708800 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
        echo 652800 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_min_freq
        echo 2208000 > /sys/devices/system/cpu/cpu6/cpufreq/scaling_max_freq

        #enable core_ctl
        echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/disable
        ;;
esac
#endif /* VENDOR_EDIT */

