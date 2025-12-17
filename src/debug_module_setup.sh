#!/usr/bin/env bash

# This script is responsible for setting up the debug module when unauthorized ADB is enabled

function setup_debug_module() {
    local my_avbroot_setup="${WORKDIR}/tools/my-avbroot-setup"
    local dummy_zip="${WORKDIR}/modules/dummy.zip"
    local dummy_sig="${dummy_zip}.sig"
    
    echo "Setting up debug module..."
    
    # Copy debugmod.py to my-avbroot-setup modules directory
    cp src/debugmod.py "${my_avbroot_setup}/lib/modules/debugmod.py"
    
    # Create empty dummy.zip and dummy.zip.sig
    touch "${dummy_zip}" "${dummy_sig}"
    
    # Modify __init__.py to include debug module
    local init_file="${my_avbroot_setup}/lib/modules/__init__.py"
    
    # Add import with other module imports
    awk '/^def all_modules/ {
        print;
        # Find the first import line
        if (!found_imports) {
            getline;
            print "    from lib.modules.debugmod import DebugMod";
            print;
            found_imports = 1;
            next;
        }
    }
    {print}' "${init_file}" > "${init_file}.tmp"
    mv "${init_file}.tmp" "${init_file}"
    
    # Add module to the dictionary in all_modules()
    awk '/    return {/ {
        print;
        print "        '\''debug'\'': DebugMod,";
        next;
    }
    {print}' "${init_file}" > "${init_file}.tmp"
    mv "${init_file}.tmp" "${init_file}"
    
    echo "Debug module setup complete."
}
