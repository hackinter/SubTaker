# Domain Reconnaissance Script

This script automates the reconnaissance process for a given domain. It creates necessary directories and files, finds subdomains, checks for alive domains, scans for open ports, and collects wayback data.

## Features

- **Directory and File Creation**: Automatically creates a structured directory and necessary files for storing results.
- **Subdomain Discovery**: Uses `assetfinder` to find subdomains.
- **Alive Domain Checking**: Uses `httprobe` to check which discovered domains are alive.
- **Subdomain Takeover Detection**: Uses `subjack` to check for potential subdomain takeovers.
- **Port Scanning**: Scans alive domains for open ports using `nmap`.
- **Wayback Data Scraping**: Collects data from the Wayback Machine for the discovered subdomains.
- **Parameter Extraction**: Extracts parameters from the Wayback data for further analysis.
- **File Compilation**: Compiles discovered URLs based on file extensions.

## Prerequisites

Ensure the following tools are installed on your system:

- `assetfinder`
- `httprobe`
- `subjack`
- `nmap`
- `waybackurls`

## Usage

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
