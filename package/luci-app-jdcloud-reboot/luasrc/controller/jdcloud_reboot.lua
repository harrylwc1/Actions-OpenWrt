module("luci.controller.jdcloud_reboot", package.seeall)

function index()
entry({"admin", "system", "jdcloud_reboot"},
      cbi("jdcloud_reboot"),
      _("JDCloud Reboot"), 60).dependent = false
end
