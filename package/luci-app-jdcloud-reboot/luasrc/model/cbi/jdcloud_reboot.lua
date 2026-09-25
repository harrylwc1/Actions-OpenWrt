local m = Map("jdcloud_reboot", translate("JDCloud Reboot"),
translate("Switch to the other partition and reboot."))

local function get_info()
local json = luci.sys.exec("/usr/libexec/jdcloud-reboot-info 2>/dev/null")
if not json or json == "" then
return nil
end
local ok, data = pcall(function()
return require("luci.jsonc").parse(json)
end)
if ok then
return data
end
return nil
end

local info = get_info()

local s1 = m:section(TypedSection, "info", translate("Current"))
s1.anonymous = true
s1.addremove = false

local cur = s1:option(DummyValue, "_current", translate("Current Partition"))
cur.value = (info and info.current) or "unknown"

local curdev = s1:option(DummyValue, "_curdev", translate("Device"))
curdev.value = (info and info.current_device) or "-"

if info and info.other_info then
local s2 = m:section(TypedSection, "other", translate("Other Partition"))
s2.anonymous = true
s2.addremove = false

local o = s2:option(DummyValue, "_other", translate("Partition"))
o.value = info.other or "unknown"

local dn = s2:option(DummyValue, "_dn", translate("Device Name"))
dn.value = info.other_info.device_name or "-"

local hn = s2:option(DummyValue, "_hn", translate("Hostname"))
hn.value = info.other_info.hostname or "-"

local rv = s2:option(DummyValue, "_rv", translate("ROM Version"))
rv.value = info.other_info.rom_version or "-"

local kv = s2:option(DummyValue, "_kv", translate("Kernel Version"))
kv.value = info.other_info.kernel_version or "-"

local kd = s2:option(DummyValue, "_kd", translate("Kernel Device"))
kd.value = info.other_info.kernel_dev or "-"

local ks = s2:option(DummyValue, "_ks", translate("Kernel Start"))
ks.value = info.other_info.kernel_start or "-"

local kz = s2:option(DummyValue, "_kz", translate("Kernel Size"))
kz.value = info.other_info.kernel_size or "-"

local rd = s2:option(DummyValue, "_rd", translate("Rootfs Device"))
rd.value = info.other_info.rootfs_dev or "-"

local ru = s2:option(DummyValue, "_ru", translate("Rootfs PARTUUID"))
ru.value = info.other_info.rootfs_partuuid or "-"
end

if info then
local s3 = m:section(TypedSection, "uboot", translate("U-Boot Environment"))
s3.anonymous = true
s3.addremove = false

local f1 = s3:option(DummyValue, "_fb", "flag_boot_rootfs")
f1.value = info.flag_boot_rootfs or "-"

local f2 = s3:option(DummyValue, "_fl", "flag_last_success")
f2.value = info.flag_last_success or "-"
end

local s4 = m:section(TypedSection, "action", translate("Action"))
s4.anonymous = true
s4.addremove = false

local btn = s4:option(Button, "_switch", translate("Switch to other partition"))
btn.inputtitle = translate("Switch")
btn.inputstyle = "apply"
function btn.write(self, section)
luci.sys.call("/usr/bin/boot_alt.sh >/dev/null 2>&1 &")
luci.http.redirect(luci.dispatcher.build_url("admin", "system", "jdcloud_reboot"))
end

return m
