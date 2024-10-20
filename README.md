# PixeneOS (GrapheneOS++)

## Description

PixeneOS is a `shell` script for patching GrapheneOS OTA (Over The Air) images with custom modules that gives you additional features.
This tool offers many features which are highly dependent on the upstream projects.

## Features

- [BCR](https://github.com/chenxiaolong/BCR) (>= version 1.65)
- [Custota](https://github.com/chenxiaolong/Custota) (>= version 4.5)
- [Magisk](https://github.com/pixincreate/Magisk) (>= version 27006) -- optional
- [MSD](https://github.com/chenxiaolong/MSD)
- [OEMUnlockOnBoot](https://github.com/chenxiaolong/OEMUnlockOnBoot) (>= version 1.1)

>[!NOTE]
> 1. This project is in no way affiliated with GrapheneOS or any of the projects mentioned above. This is a personal project solely created for personal use
> 2. At the moment, the project only supports Linux given compatibility issues with other operating systems (`libsepol` is highly Linux specific)

## Requirements

In order to use this project, you need the following (most of them will be taken care by the script itself except for `git` and `python`):

- A Linux machine. You can use `WSL` (Windows Subsystem for Linux) or a `VM` (Virtual Machine) if other operating systems
- Tools (needs to be in the path):
  - `git`
  - `python`
  - `avbroot`
  - `afsr`
  - `custota-tool`
- Modules:
  - `BCR`
  - `Custota`
  - `Magisk`
  - `MSD`
  - `OEMUnlockOnBoot`
- Dependencies:
  - `e2fsprogs`
  - `pkg-config`
  - `tomlkit` -- a `Python` dependency

## Working

In short, this repository is a server.

[Release.yml](.github/workflows/release.yml) initially checks if a build exist already. If only `rootless` flavor exist and user opted for rooted (`magisk`) flavor, it builds it and vice versa. If a specific version has got both the flavor for a specific device, then it skips the build. It is not recommended to force a new build for the same version (unsupported at present).

The `workflow` then calls the build script (can also be run locally in your machine; linux machine is preferred as it is the only platform this project is known to work and others are untested) which downloads all the [requirements](#requirements) mentioned above and patches the `OTA` by putting your signing key and installing the additional packages as mentioned in [features section](#features) and generates the output.

The patched OTA is then released and will be available in the [releases section](https://github.com/pixincreate/PixeneOS/releases).

Once the patched OTA is released, the server branch is then updated depending on the flavor selected (`rootless` is the default)

As mentioned in the beginning, OTA will have [Custota](https://github.com/chenxiaolong/Custota) package installed during the patch. The user should add the OTA URL from the [server](https://github.com/pixincreate/PixeneOS/tree/gh-pages) branch to receive the future OTA updates.

## Usage

### Getting started

Reading the [AVBRoot docs](https://github.com/chenxiaolong/AVBRoot) is a **must** before proceeding with PixeneOS.

To start with, the device must have an unpatched version of GrapheneOS installed. The version must match with the one taken from PixeneOS.

It is recommended ot start with version before the latest to make sure that OTA is working before setting other things up.

>[!IMPORTANT]
> `Factory image` and `OTA image` are 2 different things. We deal with **OTA images** here.

### Detailed instructions

1. Fastboot version must be `34` or newer. `35` or above is recommended as older versions are known to have bugs that prevent commands like `fastboot flashall` from running.

  ```shell
  fastboot --version
  ```

2. Reboot into `fastboot` mode and unlock the bootloader if not already. **This will trigger a data wipe.** It is important to make sure that the data is backed up somewhere else prior to unlocking the `bootloader`.

  ```shell
  fastboot flashing unlock
  ```

3. When setting PixeneOS up for the first time, the device must already be running the correct OS. Flash the original unpatched OTA or factory image if needed.

  ```shell
  bsdtar xvf DEVICE_NAME-factory-VERSION.zip # tar on windows and mac
  ./flash-all.sh # or .bat on windows
  ```

4. Download the [OTA from the releases](https://github.com/pixincreate/PixeneOS/releases). Make sure that the version of the downloaded OTA matches the version of the one that is installed on the device.

  Extract the partition images from the patched OTA that are different from the original.

  ```shell
  avbroot ota extract \
      --input /path/to/ota.zip.patched \
      --directory extracted \
      --fastboot
  ```

  If you prefer to extract and flash all OS partitions just to be safe, pass in `--all`.

5. Set the `ANDROID_PRODUCT_OUT` environment variable to the directory containing the extracted files.

  For sh/bash/zsh (Linux, macOS, WSL):

  ```shell
  export ANDROID_PRODUCT_OUT=extracted
  ```

  For PowerShell (Windows):

  ```powershell
  $env:ANDROID_PRODUCT_OUT = "extracted"
  ```

  For cmd (Windows):

  ```bat
  set ANDROID_PRODUCT_OUT=extracted
  ```

6. Flash the partition images that were extracted.

  ```shell
  fastboot flashall --skip-reboot
  ```

  Note that this only flashes the OS partitions. The bootloader and modem/radio partitions are left untouched due to fastboot limitations. If they are not already up to date or if unsure, after fastboot completes, follow the steps in the [updates section](#updates) to sideload the patched OTA once. Sideloading OTAs always ensures that all partitions are up to date.

  Alternatively, for Pixel devices, running `flash-base.sh` from the factory image will also update the bootloader and modem.

7. Set up the custom AVB public key in the bootloader after rebooting from fastbootd to bootloader.

  ```shell
  fastboot reboot-bootloader
  fastboot erase avb_custom_key
  fastboot flash avb_custom_key /path/to/avb_pkmd.bin
  ```

8. **[Optional]** Before locking the bootloader, reboot into Android once to confirm that everything is properly signed.

  Install the Magisk or KernelSU app and run the following command:

  ```shell
  adb shell su -c 'dmesg | grep libfs_avb'
  ```

  If AVB is working properly, the following message should be printed out:

  ```shell
  init: [libfs_avb]Returning avb_handle with status: Success
  ```

9. Reboot back into fastboot and lock the bootloader. This will trigger a data wipe again.

  ```shell
  fastboot flashing lock
  ```

  Confirm by pressing volume down and then power. Then reboot.

>[!IMPORTANT]
>**Do not uncheck `OEM unlocking`!**

10. To install future OS, Magisk, or KernelSU updates, see the [updates section](#updates).

### Using root

Rooting, from security point of view is **not** recommended. But that should not stop a power user from using it.

The version of [Magisk](https://github.com/topjohnwu/Magisk) provided by Topjohnwu does not hold good with GrapheneOS as the developers of Magisk are hostile with GrapheneOS developers and its users. See [7606](https://github.com/topjohnwu/Magisk/pull/7606).

The fork of [Magisk](https://github.com/pixincreate/Magisk) that is maintained by @pixincreate does overcome of the limitations by making root access work on GrapheneOS while allowing Zygisk to work. It of course with its own limitations set up by developers who develop root hiding solutions which [prevents](https://github.com/pixincreate/Magisk/issues/1) the fork from supporting modules like Shamiko.

In general, using [Magisk and especially the features like Zygisk with Graphene are likely to have the risk of breaking things with every new release in future.](https://github.com/chenxiaolong/avbroot/issues/213#issuecomment-1986637884).

Using the [fork of Magisk that supports Zygisk](https://github.com/pixincreate/Magisk) is recommended over official Magisk and KernelSU as the official Magisk is completely broken on GrapheneOS including `Zygisk` while getting KernelSU working on GrapheneOS is itself a tedious task as GrapheneOS enforces signature verification on Kernel and hence, building GrapheneOS with KernelSU from scratch is the only option if root is need.

KernelSU does have some parts like `ksud`'s sources closed which makes it inappropriate for a tool that has so much influence on the device.

>[!NOTE]
> For Magisk preinit, see [Magisk preinit](#magisk-preinit)

### Magisk preinit

Magisk versions 25211 and newer require a writable partition for storing custom SELinux rules that need to be accessed during early boot stages. This can only be determined on a real device, so avbroot requires the partition to be explicitly specified via `--magisk-preinit-device <name>`. To find the partition name:

1. Extract the boot image from the original/unpatched OTA:

    ```shell
    avbroot ota extract \
        --input /path/to/ota.zip \
        --directory . \
        --boot-only
    ```

2. Patch the boot image via the Magisk app. This **MUST** be done on the target device or a device of the same model! The partition name will be incorrect if patched from Magisk on a different device model.

    The Magisk app will print out a line like the following in the output:

    ```
    - Pre-init storage partition device ID: <name>
    ```

    Alternatively, avbroot can print out what Magisk detected by running:

    ```shell
    avbroot boot magisk-info \
        --image magisk_patched-*.img
    ```

    The partition name will be shown as `PREINITDEVICE=<name>`.

    Now that the partition name is known, it can be passed to avbroot when patching via `--magisk-preinit-device <name>`. The partition name should be saved somewhere for future reference since it's unlikely to change across Magisk updates.

If it's not possible to run the Magisk app on the target device (eg. device is currently unbootable), patch and flash the OTA once using `--ignore-magisk-warnings`, follow these steps, and then repatch and reflash the OTA with `--magisk-preinit-device <name>`.

### Updates

Updates can be done by patching (or re-patching) the OTA by using `adb sideload`:

1. Reboot to recovery mode. If the screen is stuck at `No command` message, press Volume up while holding Power button. It should open the recovery menu
2. Sideload the patched OTA with `adb sideload` by using volume buttons to toggle to `Apply update from ADB` which can be confirmed by pressing the power button

PixeneOS leverages Custota:

1. Hence, it is advisable to [disable the system updater app](https://github.com/chenxiaolong/avbroot#ota-updates)
2. Open Custota and set the OTA server URL to point to PixeneOS OTA server: https://pixincreate/github.io/PixeneOS/<rootless/magisk>

## Tool usage

Linux based Operating System is recommended.

To get started, clone / fork the repository and:

- Modify `env.toml` file to set the environment variables (your device model, AVBRoot architecture, GrapheneOS update channel and etc.,)
- To run the program E2E (end to end), execute the following command:

  ```shell
  . src/main.sh
  ```

  `INTERACTIVE_MODE`, by default is set to `true` that calls `check_toml_env` function to check the existence of `env.toml`. If the file exist, it will read the `env.toml` file and set the environment variables accordingly. If the `env.toml` is non-existent, ignored. If it exist, and the format is wrong, the script exits with an error.

>[!IMPORTANT]
> Make sure that `env.toml` file exist in root of the project.

>[!NOTE]
> Executing the program end to end will **only** generate the patched OTA package in local and will not be pushed to the server (server branch that contains the json file which is read by the Custota).

In order to make the patched OTA available to the device, it needs to be hosted in the server. PixeneOS uses GitHub itself as the server for pushing updates and is handled by the [release.yml](.github/workflows/release.yml).

To setup automated release, below mentioned variables needs to be added in the GitHub secrets:

- `EMAIL`: Email address that is associated to the GitHub account (example: `user@example.com`)
- Base64 encoded keys (Check [commands section](#commands) to generate keys if not done already)
  - `AVB_KEY`
  - `CERT_OTA`
  - `OTA_KEY`
- Passphrases used to generate the keys
  - `PASSPHRASE_AVB`
  - `PASSPHRASE_OTA`

It does so, by creating a GitHub [release](https://github.com/pixincreate/PixeneOS/releases) and then update the release URL in magisk / rootless `json` under `gh-pages` branch.

### Hop between root and rootless

- In order to remove root, you can change to the `rootless` flavor.
  - To do so, set the following URL in custota: https://pixincreate.github.io/PixeneOS/rootless/
- In order to add root, you can change to the `magisk` flavor.
  - To do so, set the following URL in custota: https://pixincreate.github.io/PixeneOS/magisk/

### Commands

- Execute the following command to see the list of available commands and other helpful information:

  ```shell
  . src/util_functions.sh && help
  ```

  `help` command will display the help message.

- Execute the following command to see the list of supported tools:

  ```shell
  . src/util_functions.sh && supported_tools
  ```
  `supported_tools` command will display the list of tools that are supported.

- To generate AVB keys, execute the following command:

  ```shell
  . src/util_functions.sh && generate_keys
  ```

  This command will generate the AVB keys and store them in `.keys` directory.

>[!NOTE]
> For security reasons, `.keys` directory will **not** be pushed to your github repository.
> Execute `setup_hooks.sh` to install a pre-commit hook that will stop `.keys` directory from being pushed if tried.

- To create and make the release, execute the following command:

  ```shell
  . src/util_functions.sh && create_and_make_release
  ```

- To call individual functions / commands, execute the commands in the following manner:

  ```shell
  . src/<file>.sh && <function_name>
  ```

## Reverting back to stock

To stop using PixeneOS and revert back to using stock GrapheneOS or firmware:

1. Reboot into fastboot mode and unlock the bootloader. **This will trigger a data wipe.** Make sure that the data is backed up before proceeding further in order to not lose data.

2. Erase the custom AVB public key:

  ```shell
  fastboot erase avb_custom_key
  ```

3. Flash the stock firmware

## License

This project is licensed under the `MIT`. For more information, please refer to the [LICENSE](LICENSE) file.

Dependencies that are downloaded from their respective repositories and are licensed under their respective licenses. Please refer to the respective repositories for more information.

## Credits

- [GrapheneOS](https://grapheneos.org) -- for the OS
- [Chenxiaolong](https://github.com/chenxiaolong) -- for the additional features and tools
  - [afsr](https://github.com/chenxiaolong/afsr)
  - [avbroot](https://github.com/chenxiaolong/avbroot)
  - [BCR](https://github.com/chenxiaolong/BCR)
  - [Custota](https://github.com/chenxiaolong/Custota)
  - [MSD](https://github.com/chenxiaolong/MSD)
  - [my-avbroot-setup](https://github.com/chenxiaolong/my-avbroot-setup)
  - [OEMUnlockOnBoot](https://github.com/chenxiaolong/OEMUnlockOnBoot)
- [Rooted-Graphene](https://github.com/schnatterer/rooted-graphene) -- for the motivation and inspiration to re-invent the wheel

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
