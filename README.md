# PixeneOS

GrapheneOS with additionals:

- Userdebug builds with `ro.adb.secure=1`
- [afsr](https://github.com/chenxiaolong/afsr) (>= commit adcae036b68684828edf5eb90be1500abd5cf491)
- [avbroot](https://github.com/chenxiaolong/avbroot) (>= version 3.3.0)
- [BCR](https://github.com/chenxiaolong/BCR) (>= version 1.65)
- [Custota](https://github.com/chenxiaolong/Custota) (>= version 4.5)
- [Magisk](https://github.com/pixincreate/Magisk) (>= version 27006) -- optional
- [MSD](https://github.com/chenxiaolong/MSD)
- [my-avbroot-setup](https://github.com/chenxiaolong/my-avbroot-setup)
- [OEMUnlockOnBoot](https://github.com/chenxiaolong/OEMUnlockOnBoot) (>= version 1.1)

## TO-DO

- [ ] Complete functions
- [ ] Update README.md
- [ ] Safe checks
  - [x] Check if files are already present. If yes, throw a warning and skip
  - [ ] Check for untracked files and add `-dirty` suffix to the version
  - [x] Verify the source
  - [ ] Clean up
  - [x] Rewrite Downloader
