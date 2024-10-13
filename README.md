# PixeneOS (GrapheneOS++)

## Description

PixeneOS (the name of this project) is GrapheneOS patched with additional features.

## Features

- [BCR](https://github.com/chenxiaolong/BCR) (>= version 1.65)
- [Custota](https://github.com/chenxiaolong/Custota) (>= version 4.5)
- [Magisk](https://github.com/pixincreate/Magisk) (>= version 27006) -- optional
- [MSD](https://github.com/chenxiaolong/MSD)
- [OEMUnlockOnBoot](https://github.com/chenxiaolong/OEMUnlockOnBoot) (>= version 1.1)

### Note

1. This project is in no way affiliated with GrapheneOS or any of the projects mentioned above. This is a personal project for personal use
2. At the moment, the project only supports Linux given compatibility issues with other operating systems (`libsepol` is highly Linux specific)

## Requirements

In order to use this project, you need the following (most of them will be taken care by the script itself except for `git` and `python`):

- A Linux machine. You can use WSL or a VM if other operating systems
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
  - `tomlkit` -- a python dependency

## Working

In short, this repository is a server.

[Release.yml](.github/workflows/release.yml) initially checks if a build exist already. If only rootless flavor exist and user opted for rooted flavor, it builds it and vice versa. If a version has got both the flavor for a specific device, then it skips the build.

The workflow then calls the build script (can also be run locally in your machine; linux machine is preferred as it is the only platform this project is known to work and others are untested) which downloads all the [requirements](#requirements) mentioned above and patches the OTA by putting your signing key and installing the additional packages as mentioned in [features section](#features) and generates the output.

The patched OTA is then released and will be available in the [releases section](https://github.com/pixincreate/PixeneOS/releases).

Once the patched OTA is released, the server branch is then updated depending on the flavor selected (`rootless` is the default)

As mentioned in the beginning, OTA will have [Custota](https://github.com/chenxiaolong/Custota) package installed during the patch. The user should add the OTA URL from the [server](https://github.com/pixincreate/PixeneOS/tree/gh-pages) branch to receive the OTA update.


## Usage

### Getting started

For now, below mentioned guides can be followed during initial setup:

- [chenxiaolong/avbroot](https://github.com/chenxiaolong/avbroot)
- [chenxiaolong/my-avbroot-setup](https://github.com/chenxiaolong/my-avbroot-setup)
- [schnatterer/rooted-graphene](https://github.com/schnatterer/rooted-graphene)

### Tool usage

There still exist a lot of moving parts within this tiny tool. Although most of the functionalities are stabilised, the tool usage guide will become obselete real quick. Will update this section in some time.

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
