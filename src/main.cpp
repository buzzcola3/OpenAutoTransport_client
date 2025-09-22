/*
*  This file is part of openauto project.
*  Copyright (C) 2025 buzzcola3 (Samuel Betak)
*
*  openauto is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 3 of the License, or
*  (at your option) any later version.

*  openauto is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with openauto. If not, see <http://www.gnu.org/licenses/>.
*/

#include <iostream>
#include <chrono>
#include <thread>
#include <signal.h>
#include <atomic>
#include "Transport.hpp"
#include "wire.hpp"

using buzz::autoapp::Transport::Transport;

// Global flag for signal handling
static std::atomic<bool> running{true};

// Signal handler for Ctrl-C
void signalHandler(int signal) {
    std::cout << "\nReceived signal " << signal << ", shutting down..." << std::endl;
    running = false;
}

// Simple message handler for STATUS messages
void handleStatusMessage(uint64_t timestamp, const void* data, std::size_t size) {
    std::cout << "Received STATUS message at " << timestamp 
              << " with " << size << " bytes" << std::endl;
}

int main() {
    // Set up signal handlers for graceful shutdown
    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);
    
    try {
        Transport transport(1024);
        
        // Add type handler for STATUS messages
        transport.addTypeHandler(buzz::wire::MsgType::STATUS, handleStatusMessage);
        
        std::cout << "Starting as side B..." << std::endl;
        bool ok = transport.startAsB(std::chrono::milliseconds(5000), std::chrono::microseconds(1000));
        
        if (!ok) {
            std::cerr << "Failed to start transport" << std::endl;
            return 1;
        }
        
        std::cout << "Transport started successfully. Running until Ctrl-C..." << std::endl;
        
        // Run until signal received
        while (running) {
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
        }
        
        std::cout << "Shutting down transport..." << std::endl;
        transport.stop();
        std::cout << "Done." << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
}