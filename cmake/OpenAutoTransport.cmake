# OpenAutoTransport prebuilt fetcher (Linux only)
# Variables you can override before including this file:
#   OAT_VERSION       - tag (e.g. v0.1.2) or "latest" (default)
#   OAT_REPO          - GitHub repo "owner/name" (default "buzzcola3/OpenAutoTransport")
#   OAT_DOWNLOAD_DIR  - destination folder for downloads (default ${CMAKE_BINARY_DIR}/_deps/open_auto_transport)
#   OAT_VARIANT       - REQUIRED: amd64_gnu | amd64_musl | arm64_gnu | arm64_musl
#   OAT_LINKAGE       - STATIC (default) or SHARED; controls which artifact is fetched (.a vs .so)

if(NOT CMAKE_SYSTEM_NAME STREQUAL "Linux")
  message(FATAL_ERROR "OpenAutoTransport prebuilts are Linux-only.")
endif()

set(OAT_VERSION "${OAT_VERSION}" CACHE STRING "OpenAutoTransport release tag or 'latest'")
if(NOT OAT_VERSION)
  set(OAT_VERSION "latest")
endif()
set(OAT_REPO "${OAT_REPO}" CACHE STRING "GitHub repo owner/name for OpenAutoTransport")
if(NOT OAT_REPO)
  set(OAT_REPO "buzzcola3/OpenAutoTransport")
endif()
set(OAT_DOWNLOAD_DIR "${OAT_DOWNLOAD_DIR}" CACHE PATH "Download dir for OpenAutoTransport prebuilts")
if(NOT OAT_DOWNLOAD_DIR)
  # Default to source tree: <repo>/third_party/OpenAutoTransport
  set(OAT_DOWNLOAD_DIR "${CMAKE_CURRENT_LIST_DIR}/../third_party/OpenAutoTransport")
endif()

# Require variant up-front; no auto-detection.
set(OAT_VARIANT "${OAT_VARIANT}" CACHE STRING "Required OpenAutoTransport variant (amd64_gnu|amd64_musl|arm64_gnu|arm64_musl)")
if(NOT OAT_VARIANT)
  message(FATAL_ERROR "OAT_VARIANT is required. Set it to one of: amd64_gnu, amd64_musl, arm64_gnu, arm64_musl")
endif()
string(TOLOWER "${OAT_VARIANT}" _oat_variant_lc)
if(NOT _oat_variant_lc MATCHES "^(amd64|arm64)_(gnu|musl)$")
  message(FATAL_ERROR "Invalid OAT_VARIANT='${OAT_VARIANT}'. Expected one of: amd64_gnu, amd64_musl, arm64_gnu, arm64_musl")
endif()
set(OAT_VARIANT "${_oat_variant_lc}")

if(OAT_VERSION STREQUAL "latest")
  set(_dl_base "https://github.com/${OAT_REPO}/releases/latest/download")
else()
  set(_dl_base "https://github.com/${OAT_REPO}/releases/download/${OAT_VERSION}")
endif()

file(MAKE_DIRECTORY "${OAT_DOWNLOAD_DIR}")

# Choose linkage and corresponding artifact extension
set(OAT_LINKAGE "${OAT_LINKAGE}" CACHE STRING "Linkage for OpenAutoTransport (STATIC or SHARED)")
if(NOT OAT_LINKAGE)
  set(OAT_LINKAGE "STATIC")
endif()
string(TOUPPER "${OAT_LINKAGE}" _oat_linkage_uc)
if(NOT _oat_linkage_uc MATCHES "^(STATIC|SHARED)$")
  message(FATAL_ERROR "Invalid OAT_LINKAGE='${OAT_LINKAGE}'. Expected STATIC or SHARED")
endif()
if(_oat_linkage_uc STREQUAL "STATIC")
  set(_oat_ext "a")
else()
  set(_oat_ext "so")
endif()

set(OAT_LIB_NAME "libopen_auto_transport-${OAT_VARIANT}.${_oat_ext}")
set(OAT_LIB_PATH "${OAT_DOWNLOAD_DIR}/${OAT_LIB_NAME}")
set(OAT_HDRS
  "Transport.hpp"
  "wire.capnp.h"
  "wire.hpp"
)

# Download library archive/shared object
if(NOT EXISTS "${OAT_LIB_PATH}")
  message(STATUS "Downloading ${OAT_LIB_NAME} from ${_dl_base}")
  file(DOWNLOAD "${_dl_base}/${OAT_LIB_NAME}" "${OAT_LIB_PATH}" SHOW_PROGRESS)
endif()

# Download headers
foreach(hdr IN LISTS OAT_HDRS)
  set(dst "${OAT_DOWNLOAD_DIR}/${hdr}")
  if(NOT EXISTS "${dst}")
    message(STATUS "Downloading ${hdr} from ${_dl_base}")
    file(DOWNLOAD "${_dl_base}/${hdr}" "${dst}" SHOW_PROGRESS)
  endif()
endforeach()

# Create imported target
if(NOT TARGET open_auto_transport::open_auto_transport)
  if(_oat_linkage_uc STREQUAL "STATIC")
    add_library(open_auto_transport::open_auto_transport STATIC IMPORTED GLOBAL)
  else()
    add_library(open_auto_transport::open_auto_transport SHARED IMPORTED GLOBAL)
  endif()
  set_target_properties(open_auto_transport::open_auto_transport PROPERTIES
    IMPORTED_LOCATION "${OAT_LIB_PATH}"
    INTERFACE_INCLUDE_DIRECTORIES "${OAT_DOWNLOAD_DIR}"
  )
endif()

# Expose a small helper for RPATH if you want to keep the .so next to your exe
function(oat_apply_origin_rpath tgt)
  if(NOT TARGET "${tgt}")
    message(FATAL_ERROR "Target '${tgt}' not found for oat_apply_origin_rpath()")
  endif()
  set_property(TARGET "${tgt}" PROPERTY BUILD_RPATH "$ORIGIN")
  set_property(TARGET "${tgt}" PROPERTY INSTALL_RPATH "$ORIGIN")
endfunction()

# Export detected info
set(OAT_VARIANT "${OAT_VARIANT}" PARENT_SCOPE)
set(OAT_LIB_PATH "${OAT_LIB_PATH}" PARENT_SCOPE)
set(OAT_SO_PATH "${OAT_LIB_PATH}" PARENT_SCOPE) # backward-compat alias
set(OAT_INCLUDE_DIR "${OAT_DOWNLOAD_DIR}" PARENT_SCOPE)
