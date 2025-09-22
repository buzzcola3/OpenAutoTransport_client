# OpenAutoTransport Client

A minimal client implementation for OpenAutoCore's transport layer communication.

## Overview

This project demonstrates how to integrate and use the OpenAutoTransport library to create a simple client application that connects to OpenAutoCore's shared memory transport system. The client runs as "side B" and listens for incoming messages from the OpenAutoCore system.

## Features

- **Minimal Implementation**: Bare-bones client with no command-line parameters
- **Side B Transport**: Connects to existing OpenAutoCore transport (side A)

## Prerequisites

- Linux system (Ubuntu 24.04+ recommended)
- CMake 3.16+
- Clang++ compiler with libc++ support
- Internet connection (for downloading dependencies)

## Build Dependencies

The build system automatically downloads:
- **Cap'n Proto v1.1.0**: Built from source via CMake FetchContent
- **OpenAutoTransport Library**: Prebuilt amd64_gnu variant from GitHub releases
- **Required Headers**: Transport.hpp, wire.hpp, wire.capnp.h

## Building

```bash
# Clone or navigate to the project directory
cd OpenAutoTransport_client

# Create build directory
mkdir build && cd build

# Configure with clang++ and build
export CXX=/usr/bin/clang++
export CC=/usr/bin/clang
cmake .. && make
```

## Usage

```bash
# Run the client (requires OpenAutoCore to be running as side A)
./bin/OpenAutoTransport_client
```

The client will:
1. Start as transport side B
2. Wait up to 5 seconds to connect to existing transport
3. Listen for STATUS messages
4. Run continuously until Ctrl-C
5. Shutdown gracefully

## Expected Output

```
Starting as side B...
[Transport] Started as Side B name=openauto_core wait(ms)=5000 poll(us)=1000
Transport started successfully. Running until Ctrl-C...
[Transport] RX side=B type=0 ts=... bytes=...
Received STATUS message at ... with ... bytes
...
^C
Received signal 2, shutting down...
Shutting down transport...
[Transport] Stopped
Done.
```

## Project Structure

```
OpenAutoTransport_client/
├── README.md                 # This file
├── CMakeLists.txt           # Build configuration
├── cmake/
│   └── OpenAutoTransport.cmake  # Library fetcher module
├── src/
│   └── main.cpp             # Minimal client implementation
├── build/                   # Build directory (created during build)
├── third_party/            # Downloaded dependencies
│   └── OpenAutoTransport/  # Library and headers
└── bin/                    # Built executable (in build/)
```

### Build Issues
- Ensure clang++ and libc++-dev packages are installed
- Check internet connection for dependency downloads
- Clear build directory if switching compilers

### Runtime Issues
- **"Failed to start transport"**: OpenAutoCore (side A) must be running first
- **No messages received**: Verify OpenAutoCore is actively sending data
- **Permission errors**: Check shared memory permissions

## Integration with OpenAutoCore

This client is designed to work with the OpenAutoCore Android Auto implementation. It connects to the transport layer that OpenAutoCore uses for internal communication and message passing.

To use with OpenAutoCore:
1. Start OpenAutoCore system (creates side A transport)
2. Run this client (connects as side B)
3. Monitor STATUS messages and transport activity

## License

This project is part of the openauto project and is licensed under the GNU General Public License v3.0.

Copyright (C) 2025 buzzcola3 (Samuel Betak)