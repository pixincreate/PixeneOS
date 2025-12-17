from dataclasses import dataclass
from pathlib import Path
from typing import Any, ClassVar

from lib.filesystem import ExtFs
from lib.modules import Module, ModuleRequirements


@dataclass
class DebugMod(Module):
    zip_path: Path
    sig_path: Path
    
    # Class constants
    SELINUX_RULES: ClassVar[list[str]] = [
        # Core ADB debug rules
        'allow adbd adbd process { fork signal_perms }',
        'allow adbd self process { setcurrent getcurrent }',
        'allow adbd device_debug_prop property_service { set }',
        'allow adbd userdebug_prop property_service { set }',
        'allow adbd shell_prop property_service { set }',
        # Properties access
        'allow init { system_prop userdebug_prop shell_prop } property_service { set }',
        # USB configuration
        'allow system_server usb_device dir { search }',
        'allow system_server usb_device chr_file { open read write ioctl }',
        # Debug properties access
        'allow system_server device_debug_prop property_service { set }',
        # ADB functionality
        'allow adbd self capability { setuid setgid }',
        'allow adbd rootfs dir { read open }',
        'allow adbd port tcp_socket { name_bind }',
        'allow adbd node_type tcp_socket { node_bind }',
        'allow adbd self tcp_socket { create bind setopt accept listen read write }',
    ]

    SYSTEM_PROPS: ClassVar[dict[str, str]] = {
        'ro.debuggable': '1',
        'ro.adb.secure': '0',
        'persist.service.adb.enable': '1',
        'persist.service.debuggable': '1',
        'persist.sys.usb.config': 'mtp,adb',
    }

    def requirements(self) -> ModuleRequirements:
        return ModuleRequirements(
            boot_images=set(),
            ext_images={'system', 'vendor'},
            selinux_patching=True,
        )

    def inject(self, boot_fs: dict[str, Any], ext_fs: dict[str, ExtFs],
               selinux_policies: list[Path]) -> None:
        # Inject SELinux rules
        for policy in selinux_policies:
            with open(policy, 'ab') as f:
                for rule in self.SELINUX_RULES:
                    f.write(f'{rule}\n'.encode('utf-8'))

        # Inject system properties
        system_prop_file = ext_fs['system'].tree / 'system' / 'build.prop'
        vendor_prop_file = ext_fs['vendor'].tree / 'build.prop'

        for prop_file in [system_prop_file, vendor_prop_file]:
            if not prop_file.exists():
                continue

            current_props = prop_file.read_text()
            with open(prop_file, 'a') as f:
                f.write('\n# Added by DebugMod\n')
                for key, value in self.SYSTEM_PROPS.items():
                    f.write(f'{key}={value}\n')