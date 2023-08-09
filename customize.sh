SKIPUNZIP=1
SKIPMOUNT=false

mv $MODPATH/m $MODPATH/module.prop
mv $MODPATH/c $MODPATH/customize.sh
mv $MODPATH/ut $MODPATH/util_function.sh
mv $MODPATH/v $MODPATH/verify.prop
mv $MODPATH/un $MODPATH/uninstall.sh

if $BOOTMODE; then
  ui_print "- Installing from Magisk app"
else
  ui_print "*********************************************************"
  ui_print "! Install from recovery is NOT supported"
  ui_print "! Please install from Magisk app"
  abort "*********************************************************"
  
fi

TID=$(getprop ro.product.vendor.device)
Marketname=$(getprop ro.product.vendor.marketname)
Version=$(getprop ro.build.version.incremental)
Android=$(getprop ro.build.version.release)
CPU_ABI=$(getprop ro.product.cpu.abi)

	ui_print "*********************************************************"
	sleep 0.05
	ui_print "- Device:           $Marketname"
	sleep 0.05
    ui_print "- TID:              $TID"
    sleep 0.05
    ui_print "- ARM Version:      $CPU_ABI"
    sleep 0.05
	ui_print "- SDK Version:      $API"
	sleep 0.05
	ui_print "- Android Version:  Android $Android"
	sleep 0.05
	ui_print "- Build version:    $Version"
	ui_print "*********************************************************"
	sleep 2.0
	
ui_print "- Extracting verify"
unzip -o "$ZIPFILE" 'v' -d "$TMPDIR" >&2
if [ ! -f "$TMPDIR/v" ]; then
  ui_print "*********************************************************"
  ui_print "! Unable to extract verify.sh!"
  ui_print "! This zip may be corrupted, please try downloading again"
  abort "*********************************************************"
fi
. $TMPDIR/v

extract "$ZIPFILE" 'customize.sh' "$TMPDIR"
extract "$ZIPFILE" 'v' "$TMPDIR"
extract "$ZIPFILE" 'ut' "$TMPDIR"
. $TMPDIR/ut
check_android_api_version
check_magisk_version

if [ "$ARCH" != "arm" ] && [ "$ARCH" != "arm64" ]; then
  abort "! Unsupported platform: $ARCH"
else
  ui_print "- Device platform: $ARCH"
fi

ui_print "- Extracting module files"

extract "$ZIPFILE" 'module.prop' "$MODPATH"
extract "$ZIPFILE" 'un' "$MODPATH"

ui_print "- Extracting module libraries"
mkdir -p "$MODPATH/zygisk"
if [ "$ARCH" = "arm" ] || [ "$ARCH" = "arm64" ]; then
  extract "$ZIPFILE" "zygisk/armeabi-v7a.so" "$MODPATH/zygisk" true
  mv "$MODPATH/zygisk/armeabi-v7a.so" "$MODPATH/zygisk/armeabi-v7a.so"

  if [ "$IS64BIT" = true ]; then
    extract "$ZIPFILE" "zygisk/arm64-v8a.so" "$MODPATH/zygisk" true
    mv "$MODPATH/zygisk/armeabi-v8a.so" "$MODPATH/zygisk/arm64-v8a.so"
  fi
fi

set_perm_recursive "$MODPATH" 0 0 0755 0644
