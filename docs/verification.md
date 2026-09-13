# Final-state verification

Run these checks after a cold boot. Pass the ADB selector explicitly when more
than one Android device is attached.

```sh
adb shell getprop sys.boot_completed
adb shell settings get secure accessibility_enabled
adb shell settings get secure enabled_accessibility_services
adb shell dumpsys window | grep -E 'mCurrentFocus|mFocusedApp'
adb shell pm list packages -d | sort
```

Expected observations on the working configuration:

- `sys.boot_completed` is `1`.
- Accessibility is enabled.
- The enabled-service list contains Projectivy's accessibility service.
- Projectivy is focused after boot and after pressing HOME from a normal app.
- The selected Claro management, content and launcher packages are disabled.
- The Claro remote pairing and global-key-handler packages remain installed.

The exact Projectivy service component used in this investigation was:

```text
com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService
```

Also test with the physical remote: navigation, BACK, HOME, volume and launching
at least one streaming application. ADB success alone does not prove that the
remote or media stack survived.
