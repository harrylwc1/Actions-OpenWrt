#!/bin/sh
set -e

SLOT_A_KERNEL_LABEL="0:HLOS"
SLOT_A_ROOTFS_LABEL="rootfs"
SLOT_B_KERNEL_LABEL="0:HLOS_1"
SLOT_B_ROOTFS_LABEL="rootfs_1"
COMMON_BOOTARGS='console=ttyMSM0,115200n8 cnss2.bdf_pci1=0x2'

log() { echo "[$(date '+%F %T')] $*" >&2; }

find_partition_by_label() {
    local label="$1"
    local d
    for d in /dev/mmcblk0p*; do
        [ -b "$d" ] || continue
        local partlabel
        partlabel=$(blkid -s PARTLABEL -o value "$d" 2>/dev/null)
        if [ "$partlabel" = "$label" ]; then
            echo "$d"
            return 0
        fi
    done
    return 1
}

detect_slot() {
    local rootfs_dev rootfs_num uuid rom_dev

    rootfs_dev=$(find_partition_by_label "$SLOT_A_ROOTFS_LABEL")
    if [ -n "$rootfs_dev" ]; then
        rootfs_num=$(echo "$rootfs_dev" | grep -oE '[0-9]+$')
        if dmesg 2>/dev/null | grep "Mounted root" | grep -q "179:${rootfs_num}"; then
            log "detect: dmesg -> A"
            echo "A"; return
        fi
    fi

    rootfs_dev=$(find_partition_by_label "$SLOT_B_ROOTFS_LABEL")
    if [ -n "$rootfs_dev" ]; then
        rootfs_num=$(echo "$rootfs_dev" | grep -oE '[0-9]+$')
        if dmesg 2>/dev/null | grep "Mounted root" | grep -q "179:${rootfs_num}"; then
            log "detect: dmesg -> B"
            echo "B"; return
        fi
    fi

    if [ -r /proc/cmdline ]; then
        local cmdline
        cmdline=$(cat /proc/cmdline)

        rootfs_dev=$(find_partition_by_label "$SLOT_A_ROOTFS_LABEL")
        if [ -n "$rootfs_dev" ]; then
            uuid=$(blkid -s PARTUUID -o value "$rootfs_dev" 2>/dev/null)
            if [ -n "$uuid" ] && echo "$cmdline" | grep -q "root=PARTUUID=${uuid}"; then
                log "detect: /proc/cmdline -> A"
                echo "A"; return
            fi
        fi

        rootfs_dev=$(find_partition_by_label "$SLOT_B_ROOTFS_LABEL")
        if [ -n "$rootfs_dev" ]; then
            uuid=$(blkid -s PARTUUID -o value "$rootfs_dev" 2>/dev/null)
            if [ -n "$uuid" ] && echo "$cmdline" | grep -q "root=PARTUUID=${uuid}"; then
                log "detect: /proc/cmdline -> B"
                echo "B"; return
            fi
        fi
    fi

    if [ -r /proc/mounts ]; then
        rom_dev=$(awk '$2=="/rom" {print $1}' /proc/mounts)
        if [ -n "$rom_dev" ]; then
            rootfs_dev=$(find_partition_by_label "$SLOT_A_ROOTFS_LABEL")
            if [ "$rom_dev" = "$rootfs_dev" ]; then
                log "detect: /proc/mounts -> A"
                echo "A"; return
            fi
            rootfs_dev=$(find_partition_by_label "$SLOT_B_ROOTFS_LABEL")
            if [ "$rom_dev" = "$rootfs_dev" ]; then
                log "detect: /proc/mounts -> B"
                echo "B"; return
            fi
        fi
    fi

    local flag
    flag=$(fw_printenv -n flag_boot_rootfs 2>/dev/null)
    case "$flag" in
        0) log "detect: fw_printenv -> A"; echo "A" ;;
        1) log "detect: fw_printenv -> B"; echo "B" ;;
        *) log "detect: unknown"; echo "unknown" ;;
    esac
}

switch_to_slot_a() {
    log "Switching to Slot A..."
    fw_setenv bootcmd bootipq
    fw_setenv bootargs "$COMMON_BOOTARGS"
    fw_setenv flag_boot_rootfs 0
    fw_setenv flag_last_success 0
    sync
    log "Slot A env set, rebooting..."
    reboot
}

switch_to_slot_b() {
    log "Switching to Slot B..."

    local kernel_dev rootfs_dev
    kernel_dev=$(find_partition_by_label "$SLOT_B_KERNEL_LABEL")
    [ -z "$kernel_dev" ] && { log "ERROR: no kernel partition"; exit 1; }

    rootfs_dev=$(find_partition_by_label "$SLOT_B_ROOTFS_LABEL")
    [ -z "$rootfs_dev" ] && { log "ERROR: no rootfs partition"; exit 1; }

    local kernel_start_dec kernel_start_hex
    kernel_start_dec=$(cat "/sys/class/block/$(basename "$kernel_dev")/start")
    [ -z "$kernel_start_dec" ] && { log "ERROR: no kernel start"; exit 1; }
    kernel_start_hex=$(printf '0x%x' "$kernel_start_dec")

    local kernel_size_dec kernel_size_hex
    kernel_size_dec=$(cat "/sys/class/block/$(basename "$kernel_dev")/size")
    [ -z "$kernel_size_dec" ] && { log "ERROR: no kernel size"; exit 1; }
    kernel_size_hex=$(printf '0x%x' "$kernel_size_dec")

    local rootfs_partuuid
    rootfs_partuuid=$(blkid -s PARTUUID -o value "$rootfs_dev")
    [ -z "$rootfs_partuuid" ] && { log "ERROR: no rootfs PARTUUID"; exit 1; }

    local magic
    magic=$(dd if="$kernel_dev" bs=1 count=4 2>/dev/null | hexdump -v -e '4/1 "%02x"')
    log "Kernel: $kernel_dev  start=$kernel_start_hex  size=$kernel_size_hex  magic=$magic"
    log "Rootfs: $rootfs_dev  PARTUUID=$rootfs_partuuid"

    fw_setenv bootcmd "mmc dev 0; mmc read 0x44000000 ${kernel_start_hex} ${kernel_size_hex}; setenv bootargs \"${COMMON_BOOTARGS} root=PARTUUID=${rootfs_partuuid} gpt rootwait vmalloc=1G\"; bootm 0x44000000"
    fw_setenv flag_boot_rootfs 1
    fw_setenv flag_last_success 1
    sync
    log "Slot B env set, rebooting..."
    reboot
}

CURRENT=$(detect_slot)
log "Current slot: $CURRENT"

case "$CURRENT" in
    A) switch_to_slot_b ;;
    B) switch_to_slot_a ;;
    *)
        log "ERROR: cannot determine current slot"
        exit 1
        ;;
esac
