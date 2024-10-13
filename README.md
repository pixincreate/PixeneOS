# PixeneOS (GrapheneOS++)

## Description

PixeneOS (the name of this project) is GrapheneOS patched with additional features.

The features include:

- [BCR](https://github.com/chenxiaolong/BCR) (>= version 1.65)
- [Custota](https://github.com/chenxiaolong/Custota) (>= version 4.5)
- [Magisk](https://github.com/pixincreate/Magisk) (>= version 27006) -- optional
- [MSD](https://github.com/chenxiaolong/MSD)
- [OEMUnlockOnBoot](https://github.com/chenxiaolong/OEMUnlockOnBoot) (>= version 1.1)
- ADBRoot with `ro.adb.secure=1` for added security -- optional

### Note

1. This project is in no way affiliated with GrapheneOS or any of the projects mentioned above. This is a personal project for personal use
2. At the moment, the project only supports Linux given compatibility issues with other operating systems (`libsepol` is highly Linux specific)

## Requirements

In order to use this project, you need the following (most of them will be taken care by the script itself except `git` and `python`):

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

## Usage

TBU

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
