# FAQ

### Why did my settings get reset after updating to Custota 5.12?

- Custota `v5.12` contained a major regression where settings failed to migrate properly which resulted in a reset
- Unfortunately, the app now requires the user to set the OTA URL again, to get the next update
- This issue has been fixed [Custota 5.13](https://github.com/chenxiaolong/Custota/blob/v5.13/CHANGELOG.md), `6dc6c4f` on July 18, 2025
  - This version will automatically restore the old settings without any manual intervention
  - If the settings are configured again in Custota `v5.12`, the new settings will not be touched and will be restored in `v5.13` as usual
  
### I'm getting an error on boot saying `Device is corrupt. It can't be trusted`. What can I do? What are my options?

- Flash the OTA, switch partitions, flash it again. Then sideload the OTA on both partitions *before* flashing custom keys (see farewelltospring's [comment](https://github.com/schnatterer/rooted-graphene/issues/96#issuecomment-2986363782) in [#96](https://github.com/schnatterer/rooted-graphene/issues/96) for details).
- See [#89](https://github.com/schnatterer/rooted-graphene/issues/89) and [#96](https://github.com/schnatterer/rooted-graphene/issues/96) for details. 

### Root does not seem to exist after update

- Check [chenxiaolong/avbroot#455 (comment)](https://github.com/chenxiaolong/avbroot/issues/455#issuecomment-2955973508) contains some approaches to troubleshooting.
The following command is known to work (at the expense of restoring Magisk's settings to its default state):

```bash
su -c 'rm -r /data/adb/magisk* && reboot'
```

Also check [rooted-graphene#5](https://github.com/rooted-graphene/ota/issues/5).

