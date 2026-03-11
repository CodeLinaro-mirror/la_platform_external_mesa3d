# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: BSD-3-Clause-Clear

# android.sh {ARCH} {OUT} [libs...]
#  * {ARCH}       Architecture as set by AOSP.
#  * {OUT}        Output directory as set by AOSP.
#  * [libs...]    Dependencies shared libraries listed in "srcs" of "mesa_meson".
#
# This script is associated with the module "mesa_meson" in the Android.bp
# It compiles the libraries listed in "out" of "mesa_meson".
# The script flow is as follows:
#  * Parse non-variadic arguments and setup general environment.
#  * Generate ".pc" files for the dependencies (variadic argument).
#  * Generate Meson configuration based on the architecture.
#  * Build the Mesa3D libraries and copy to the output directory.
# Gallium and Vulkan drivers are added as necessary. Check the Meson setup call
# for the list of currently built drivers.
#
# Prerequisites:
#  * Non-standard repositories, must be added:
#     * NDK prebuilts version 23 or later, must be cloned to "prebuilts/ndk-mesa3d".
#     * Meson 23 version 1.9.1 or later, must be cloned to "external/python/meson".
#  * Standard repositories:
#     * Directory "prebuilts/build-tools/linux-x86/bin" contains:
#        * ninja
#        * bison
#        * flex
#        * m4
#     * Directory "external/python" contains:
#        * mako
#        * pyyaml
#        * markupsafe
#  * External environment:
#     * pkg-config is installed as "/usr/bin/pkg-config".

set -e

###############################################################################
# Parse non-variadic arguments and setup general environment.
###############################################################################

# Current directory is a temporary sandbox directory created by AOSP.
declare THIS_DIR="$PWD"
# Path to this very script, for error reporting.
declare THIS_EXE="$(realpath "$0")"
# Output directory that contains all outputs, a.k.a. $(genDir) in Android.bp.
declare THIS_OUT="$(realpath "$2")"
# Determine the AOSP directory, cannot be the root or the sandbox.
# The criterion is that it must contain "external/mesa3d".
# It is safe to skip two levels immediately: this directory and general out.
declare AOSP_DIR="$(realpath "$THIS_DIR/../..")"
while [[ "$AOSP_DIR" != "/" ]]; do
    if [[ -d "$AOSP_DIR/external/mesa3d" ]]; then
        break
    else
        AOSP_DIR="$(dirname "$AOSP_DIR")"
    fi
done
if [[ "$AOSP_DIR" == "/" ]]; then
    echo "$THIS_EXE: Cannot determine AOSP_DIR." 1>&2
    exit 1
fi
# Path to the directory with NDK prebuilts.
declare AOSP_NDK="$AOSP_DIR/prebuilts/ndk-mesa3d"
# Architecture, supported values: "arm", "arm64".
declare AOSP_ARCH="$1"
# Shift the processed parameters.
shift
shift

###############################################################################
# Generate ".pc" files for the dependencies (variadic argument).
###############################################################################

# PKG_CONFIG_PATH is exported because Meson also relies on it.
export PKG_CONFIG_PATH="$THIS_OUT/pc"
mkdir -p "$PKG_CONFIG_PATH"
# "Name" property, also the name of the ".pc" file.
declare -A PKG_CONFIG_NAME=(
    [libz.so]="zlib"
    [libdrm.so]="libdrm"
)
# "Version" property, it is not accurate and significantly greater than required.
# There is no adequate way to retrieve versions, unfortunately.
declare -A PKG_CONFIG_VERSION=(
    [libz.so]="2.0.0"
    [libdrm.so]="3.0.0"
)
# "Libs" property. The link directory (-L) is determined automatically.
declare -A PKG_CONFIG_LIBS=(
    [libz.so]="-lz"
    [libdrm.so]="-ldrm"
)
# "Cflags" property.
declare -A PKG_CONFIG_CFLAGS=(
    [libz.so]="-I'$AOSP_DIR/external/zlib'"
    [libdrm.so]="-I'$AOSP_DIR/external/libdrm' -I'$AOSP_DIR/external/libdrm/include' -I'$AOSP_DIR/external/libdrm/include/drm'"
)

# Go through the remaining arguments, each is a path to a dependency.
# These are the modules listed in "srcs" of "mesa_meson".
for _arg in "$@"; do
    # Retrieve information required for ".pc" generation.
    _lib="$(basename "$_arg")"
    _dir="$(realpath "$(dirname "$_arg")")"
    _name="${PKG_CONFIG_NAME[$_lib]}"
    _version="${PKG_CONFIG_VERSION[$_lib]}"
    _libs="${PKG_CONFIG_LIBS[$_lib]}"
    _cflags="${PKG_CONFIG_CFLAGS[$_lib]}"
    # Generate ".pc" file.
    printf '%s\n' \
        "Name: $_name" \
        "Description: $_name library" \
        "Version: $_version" \
        "" \
        "Requires:" \
        "Libs: -L'$_dir' $_libs" \
        "Cflags: $_cflags" \
        > "$PKG_CONFIG_PATH/$_name.pc"
done

###############################################################################
# Generate Meson configuration based on the architecture.
###############################################################################

# The Meson build directory.
declare MESON_DIR="$THIS_OUT/build"
mkdir -p "$MESON_DIR"
# The Meson configuration file.
declare MESON_INI="$MESON_DIR/meson.ini"
# SDK version. There is no specific reason to use exactly this value, it is just
# the latest available for the oldest supported NDK (see the prerequisites).
declare MESON_INI_SDK="31"
# "c" and "cpp" properties: prefix for the clang binaries.
declare -A MESON_INI_COMPILER=(
    ["arm"]="armv7a-linux-androideabi$MESON_INI_SDK"
    ["arm64"]="aarch64-linux-android$MESON_INI_SDK"
)
# "cpu_family" property.
declare -A MESON_INI_CPU_FAMILY=(
    ["arm"]="arm"
    ["arm64"]="aarch64"
)
# "cpu" property.
declare -A MESON_INI_CPU=(
    ["arm"]="armv7a"
    ["arm64"]="armv8"
)

# If this fails, it means either unsupported architecture or Google renamed an existing one.
if [ -z "${MESON_INI_COMPILER[$AOSP_ARCH]}" ]; then
    echo "$THIS_EXE: Unsupported architecture \"$AOSP_ARCH\"." 1>&2
    exit 1
fi

# Generate the configuration file MESON_INI.
printf '%s\n' \
    "[binaries]" \
    "ar = '$AOSP_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-ar'" \
    "c = ['$AOSP_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${MESON_INI_COMPILER[$AOSP_ARCH]}-clang']" \
    "cpp = ['$AOSP_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${MESON_INI_COMPILER[$AOSP_ARCH]}-clang++', '-fno-exceptions', '-fno-unwind-tables', '-fno-asynchronous-unwind-tables']" \
    "c_ld = 'lld'" \
    "cpp_ld = 'lld'" \
    "strip = '$AOSP_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip'" \
    "pkgconfig = ['env', 'PKG_CONFIG_LIBDIR=' + '$(call relative-to-absolute,$(MESON_DIR))', '/usr/bin/pkg-config']" \
    "" \
    "[built-in options]" \
    "cpp_link_args = ['-static-libstdc++']" \
    "" \
    "[host_machine]" \
    "system = 'android'" \
    "cpu_family = '${MESON_INI_CPU_FAMILY[$AOSP_ARCH]}'" \
    "cpu = '${MESON_INI_CPU[$AOSP_ARCH]}'" \
    "endian = 'little'" \
    > "$MESON_INI"

###############################################################################
# Build the Mesa3D libraries and copy to the output directory.
###############################################################################

# Add directory that contains required executables to PATH.
export PATH="$AOSP_DIR/prebuilts/build-tools/linux-x86/bin:$PATH"
# Extend PYTHONPATH, Mesa3D uses these modules for source generation.
export PYTHONPATH="$AOSP_DIR/external/python/mako:$PYTHONPATH"
export PYTHONPATH="$AOSP_DIR/external/python/pyyaml/lib:$PYTHONPATH"
export PYTHONPATH="$AOSP_DIR/external/python/markupsafe/src:$PYTHONPATH"

# Meson setup step, see meson_options.txt for available arguments.
#  * android-stub is enabled because otherwise we would need ".pc" files for ~10 libs.
#  * android-libbacktrace is disabled because it is not always available.
#  * vulkan-drivers and gallium-drivers reflect the current needs.
#  * egl, gles1, gles2 generate the corresponding libEGL and libGLES libraries.
#  * egl-lib-suffix, gles-lib-suffix are set to "_mesa" to indicate the implementation provider.
#  * opengl is disabled because it is not supported and not needed.
#  * video-codecs are disabled because we do not need them in Android.
python3 "$AOSP_DIR/external/python/meson/meson.py" setup \
    "$MESON_DIR" \
    "$AOSP_DIR/external/mesa3d" \
    --cross-file "$MESON_INI" \
    -Dplatforms=android \
    -Dplatform-sdk-version="$MESON_INI_SDK" \
    -Dandroid-stub=true \
    -Dandroid-libbacktrace=disabled \
    -Dgallium-drivers=virgl \
    -Dvulkan-drivers= \
    -Degl=enabled \
    -Dgles1=enabled \
    -Dgles2=enabled \
    -Degl-lib-suffix=_mesa \
    -Dgles-lib-suffix=_mesa \
    -Dopengl=false \
    -Dvideo-codecs= \
    -Dzstd=disabled \
    ;

# Meson build step.
python3 "$AOSP_DIR/external/python/meson/meson.py" install \
    -C "$MESON_DIR" \
    --destdir "$THIS_OUT" \
    ;

# Copy the libraries to their destination paths.
cp -ra "$THIS_OUT/usr/local/lib/." "$THIS_OUT"
