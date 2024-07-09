if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "Building with a gcc version less than 6.1 is not supported.")
    message(WARNING "${PORT} currently requires the following libraries from the system package manager:\n    libx11-dev\n    mesa-common-dev\n    libxi-dev\n    libxext-dev\n\nThese can be installed on Ubuntu systems via apt-get install libx11-dev mesa-common-dev libxi-dev libxext-dev.")
endif()

vcpkg_get_windows_sdk(WINDOWS_SDK)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/angle
    REF 5d4df51d1d7d6a290d54111527a4798f10c7ca3c 	#chromium/6478
    SHA512 240040edee01a3c3eb94915bf4d46c7e2c52d8aed538a8a7ae71d4a84f061fda2586445ae7c6c6f299098cc2348ba76a06e27bc649a1b59c941fff23fbfa79ab
    # On update check headers against opengl-registry
#    PATCHES
#        001-fix-uwp.patch
#        002-fix-builder-error.patch
#        003-fix-mingw.patch
)

# TODO: Fetch depot_tools
# https://chromium.googlesource.com/chromium/tools/depot_tools.git

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")

# Generate gclient config
#vcpkg_execute_in_download_mode(
#    COMMAND "${PYTHON3}" "${SOURCE_PATH}/scripts/bootstrap.py"
#    WORKING_DIRECTORY "${SOURCE_PATH}"
#)

# TODO: Run gclient sync to fetch dependencies
#vcpkg_execute_in_download_mode(
#    COMMAND "${PYTHON3}" "${SOURCE_PATH}/scripts/bootstrap.py"
#    WORKING_DIRECTORY "${SOURCE_PATH}"
#)



function(v8_fetch)
  set(flagArgs FETCH_SUBMODULES)
  set(oneValueArgs DESTINATION URL REF SOURCE)
  set(multipleValuesArgs PATCHES)
  cmake_parse_arguments(V8 "${flagArgs}" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

  if(NOT DEFINED V8_DESTINATION)
    message(FATAL_ERROR "DESTINATION must be specified.")
  endif()

  if(NOT DEFINED V8_URL)
    message(FATAL_ERROR "The git url must be specified")
  endif()

  if(NOT DEFINED V8_REF)
    message(FATAL_ERROR "The git ref must be specified.")
  endif()

  if(EXISTS ${V8_SOURCE}/${V8_DESTINATION}/.git)
        vcpkg_execute_required_process(
                COMMAND ${GIT} reset --hard
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
  else()
		message(STATUS "Fetching: ${V8_DESTINATION}")
        vcpkg_execute_required_process(
                COMMAND ${GIT} clone --depth 1 ${V8_URL} ${V8_DESTINATION}
                WORKING_DIRECTORY ${V8_SOURCE}
                LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
                COMMAND ${GIT} fetch --depth 1 origin ${V8_REF}
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
                COMMAND ${GIT} checkout FETCH_HEAD
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
  endif()
  if (V8_FETCH_SUBMODULES)
        vcpkg_execute_required_process(
                COMMAND ${GIT} submodule update --init --recursive
                WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                LOGNAME build-${TARGET_TRIPLET})
  endif()
  foreach(PATCH ${V8_PATCHES})
        vcpkg_execute_required_process(
                        COMMAND ${GIT} apply ${PATCH}
                        WORKING_DIRECTORY ${V8_SOURCE}/${V8_DESTINATION}
                        LOGNAME build-${TARGET_TRIPLET})
  endforeach()
endfunction()

message(STATUS "Fetching submodules")
v8_fetch(
        DESTINATION build
        URL https://chromium.googlesource.com/chromium/src/build.git
        REF ef48ed5d9583911c48a5de44b3fd01308f1b1732
        SOURCE ${SOURCE_PATH}
        PATCHES ${CURRENT_PORT_DIR}/build.patch
)
#v8_fetch(
#        DESTINATION buildtools
#        URL https://chromium.googlesource.com/chromium/src/buildtools.git
#        REF 4e0e9c73a0f26735f034f09a9cab2a5c0178536b
#        SOURCE ${SOURCE_PATH}
#        # PATCHES ${CURRENT_PORT_DIR}/build.patch
#)

v8_fetch(
        DESTINATION testing
        URL https://chromium.googlesource.com/chromium/src/testing
        REF 066811c908ecb8f4fc8c4927ff646ce03c58e95d
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/abseil-cpp
        URL https://chromium.googlesource.com/chromium/src/third_party/abseil-cpp
        REF 8c54b7dae4c4692f32abe9b3e8113cdf0a8842b9
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/astc-encoder/src
        URL https://github.com/ARM-software/astc-encoder
        REF 573c475389bf51d16a5c3fc8348092e094e50e8f
        SOURCE ${SOURCE_PATH})
v8_fetch(
        DESTINATION third_party/catapult
        URL https://chromium.googlesource.com/catapult.git
        REF 923a565b97768d3a51047c3f384f6a0d17990192
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/dawn
        URL https://dawn.googlesource.com/dawn.git
        REF d32858a3045a89e8c5ff919107ee76c8b103afdf
        SOURCE ${SOURCE_PATH})

#third_party/EGL-Registry/src ?

v8_fetch(
        DESTINATION third_party/googletest
        URL https://chromium.googlesource.com/chromium/src/third_party/googletest
        REF 17bbed2084d3127bd7bcd27283f18d7a5861bea8
        SOURCE ${SOURCE_PATH}
        FETCH_SUBMODULES)

v8_fetch(
        DESTINATION third_party/libdrm
        URL https://chromium.googlesource.com/chromiumos/third_party/libdrm
        REF 474894ed17a037a464e5bd845a0765a50f647898
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/libpng/src
        URL https://chromium.googlesource.com/chromiumos/third_party/libdrm
        REF 474894ed17a037a464e5bd845a0765a50f647898
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/jinja2
        URL https://chromium.googlesource.com/chromium/src/third_party/jinja2.git
        REF c9c77525ea20c871a1d4658f8d312b51266d4bad
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/jsoncpp
        URL https://chromium.googlesource.com/chromium/src/third_party/jsoncpp
        REF f62d44704b4da6014aa231cfc116e7fd29617d2a
        SOURCE ${SOURCE_PATH})

# Current revision of jsoncpp.
# Note: this dep cannot be auto-rolled b/c of nesting.
set(jsoncpp_revision "42e892d96e47b1f6e29844cc705e148ec4856448")
v8_fetch(
        DESTINATION third_party/jsoncpp/source
        URL https://chromium.googlesource.com/external/github.com/open-source-parsers/jsoncpp.git
        REF ${jsoncpp_revision}
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/markupsafe
        URL https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git
        REF e582d7f0edb9d67499b0f5abd6ae5550e91da7f2
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/nasm
        URL https://chromium.googlesource.com/chromium/deps/nasm.git
        REF f477acb1049f5e043904b87b825c5915084a9a29
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/protobuf
        URL https://chromium.googlesource.com/chromium/src/third_party/protobuf
        REF 4abbe88863a7dd75dd11da0487e9b995133f7592
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/rapidjson/src
        URL https://chromium.googlesource.com/external/github.com/Tencent/rapidjson
        REF 781a4e667d84aeedbeb8184b7b62425ea66ec59f
        SOURCE ${SOURCE_PATH})

v8_fetch(
        DESTINATION third_party/SwiftShader
        URL https://swiftshader.googlesource.com/SwiftShader
        REF da334852e70510d259bfa8cbaa7c5412966b2f41
        SOURCE ${SOURCE_PATH})

#third_party/VK-GL-CTS/src

v8_fetch(
        DESTINATION third_party/vulkan-deps
        URL https://chromium.googlesource.com/vulkan-deps
        REF 7e66c5e2f87e2475f6a2033af6cf37cedc7c3422
        SOURCE ${SOURCE_PATH}
        FETCH_SUBMODULES)
v8_fetch(
        DESTINATION third_party/vulkan_memory_allocator
        URL https://chromium.googlesource.com/external/github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
        REF 56300b29fbfcc693ee6609ddad3fdd5b7a449a21
        SOURCE ${SOURCE_PATH})


#IF LINUX
#third_party/wayland

v8_fetch(
        DESTINATION third_party/zlib
        URL https://chromium.googlesource.com/chromium/src/third_party/zlib.git
        REF 7d77fb7fd66d8a5640618ad32c71fdeb7d3e02df
        SOURCE ${SOURCE_PATH})


string(JOIN " " OPTIONS
    "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\""
    angle_enable_wgpu=false
    angle_has_histograms=false
    angle_build_tests=false
    chrome_pgo_phase=0
    use_sysroot=false
    is_clang=false
    use_custom_libcxx=false
    treat_warnings_as_errors=false
)

set(OPTIONS_DBG "is_debug=true")
set(OPTIONS_REL "is_official_build=true")

set(angle_use_clang TRUE)

if(VCPKG_TARGET_IS_ANDROID)
    string(APPEND OPTIONS " target_os=\"android\"")
elseif(VCPKG_TARGET_IS_OSX)
    string(APPEND OPTIONS " target_os=\"mac\"")
elseif(VCPKG_TARGET_IS_IOS)
    string(APPEND OPTIONS " target_os=\"ios\"")
elseif(VCPKG_TARGET_IS_EMSCRIPTEN)
    string(APPEND OPTIONS " target_os=\"wasm\"")
elseif(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_TARGET_IS_UWP)
		string(APPEND OPTIONS " target_os=\"winuwp\"")
		set(angle_use_clang FALSE)
	else()
		string(APPEND OPTIONS " target_os=\"win\"")
    endif()
endif()

if(angle_use_clang)
	# Find the directory that contains "bin/clang"
	# Note: Only clang-cl is supported on Windows, see https://crbug.com/988071
	vcpkg_find_acquire_program(CLANG)
	if(CLANG MATCHES "-NOTFOUND")
		message(FATAL_ERROR "Clang is required.")
	endif()
	get_filename_component(CLANG "${CLANG}" DIRECTORY)
	get_filename_component(CLANG "${CLANG}" DIRECTORY)
	if((VCPKG_TARGET_IS_WINDOWS AND NOT EXISTS "${CLANG}/bin/clang-cl.exe") OR
	   (VCPKG_TARGET_IS_OSX AND NOT EXISTS "${CLANG}/bin/clang"))
		message(FATAL_ERROR "Clang needs to be inside a bin directory.")
	endif()
	message(STATUS "CLANG=${CLANG}")
	set(OPTIONS "${OPTIONS} clang_base_path=\"${CLANG}\"")
#	string(APPEND OPTIONS " is_clang=true")
#else()
#	string(APPEND OPTIONS " is_clang=false")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    string(APPEND OPTIONS " is_component_build=true")
    vcpkg_list(SET ANGLE_TARGETS :libEGL :libGLESv1_CM :libGLESv2)
else()
    string(APPEND OPTIONS " is_component_build=false")
    vcpkg_list(SET ANGLE_TARGETS :libEGL_static :libGLESv2_static :preprocessor :translator)
endif()

if("vulkan" IN_LIST FEATURES)
    string(APPEND OPTIONS " angle_enable_vulkan=true")
else()
	string(APPEND OPTIONS " angle_enable_vulkan=false")
endif()

file(WRITE "${SOURCE_PATH}/build/config/gclient_args.gni" "checkout_angle_internal = false\ncheckout_angle_mesa = false\ncheckout_angle_restricted_traces = false\ngenerate_location_tags = false\n")
if(VCPKG_TARGET_IS_UWP)
	string(REGEX REPLACE "\\\\+$" "" WindowsSdkDir $ENV{WindowsSdkDir})
	file(APPEND "${SOURCE_PATH}/build/config/gclient_args.gni" "windows_sdk_path = \"${WindowsSdkDir}\"\n")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "${OPTIONS}"
    OPTIONS_DEBUG "${OPTIONS_DBG}"
    OPTIONS_RELEASE "${OPTIONS_REL}"
)

message(STATUS "Building libANGLE. Please wait...")

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${ANGLE_TARGETS}
)

vcpkg_copy_pdbs()

# TODO: Generate CMake config...
