# Network Toolkit

A small, menu-driven collection of network diagnostics for **Termux (Android)** and **Debian/Ubuntu-based Linux**.

> Use these tools only on devices and networks you own or are explicitly authorized to test. Port scans and Wi-Fi scans can affect other systems and may be restricted by local policies.

![Network Toolkit main menu](Network%20Toolkit/image.png)

## Features

| Tool | What it does | Termux | Linux |
| --- | --- | :---: | :---: |
| **Ping** | Sends four packets to check reachability | ✅ | ✅ |
| **Port scanner** | Scans common ports, all TCP ports, or a port range with Nmap | ✅ | ✅ |
| **Speed test** | Downloads a test file with `curl` or runs `speedtest-cli` | ✅ | ✅ |
| **Traceroute** | Displays the route to a host | ✅ | ✅ |
| **Wi-Fi analyzer** | Lists nearby networks or shows connection details | — | ✅ |
| **Internet check** | Checks connectivity by pinging a public DNS address | ✅ | ✅ |
| **Network information** | Shows interface addresses, gateway, DNS, and routes | ✅ | ✅ |

The Wi-Fi analyzer is unavailable in Termux. On Linux, Wi-Fi scanning depends on your wireless adapter, driver, and system permissions.

## Requirements

- Bash and Git
- An internet connection for installation and speed tests
- **Termux:** packages are managed with `pkg`
- **Linux:** Debian or Ubuntu, `sudo`, and `apt-get` (the startup script uses `apt-get`)
- **Linux Wi-Fi details:** a supported wireless adapter; some features may also need `wireless-tools`

On startup, the script checks for and attempts to install its dependencies. You can also install them manually using the commands below.

## Installation

### Termux (Android)

Install Termux from a trusted source, then run:

```bash
pkg update
pkg install git
git clone https://github.com/renegadothedev/Network-Toolkit.git
cd "Network-Toolkit/Network Toolkit"
chmod +x toolkit.sh
./toolkit.sh
```

### Debian or Ubuntu Linux

```bash
sudo apt update
sudo apt install git curl nmap iproute2 traceroute speedtest-cli iw wireless-tools
git clone https://github.com/renegadothedev/Network-Toolkit.git
cd "Network-Toolkit/Network Toolkit"
chmod +x toolkit.sh
./toolkit.sh
```

The script may request your password through `sudo` when installing missing packages. Review installation prompts before accepting them. Other Linux distributions are not configured by the current installer; install equivalent dependencies with your distribution's package manager.

## Using the tools

Start `toolkit.sh` and choose an option from the menu. The tools prompt for a hostname, IP address, or port range when needed. For example, use the port scanner only with a target you are authorized to assess. Press **Ctrl+C** to stop a running command.

## Project structure

```text
Network-Toolkit/
├── LICENSE
├── README.md
└── Network Toolkit/
    ├── image.png
    ├── toolkit.sh
    └── tools/
        ├── ping_tool.sh
        ├── port_scanner.sh
        ├── speed_test.sh
        ├── traceroute_tool.sh
        └── wifi_analyzer.sh
```

## Contributing

1. Fork the repository.
2. Create a branch: `git checkout -b feature/new-tool`
3. Make your changes and commit them: `git commit -m "Add new feature"`
4. Push your branch: `git push origin feature/new-tool`
5. Open a pull request.

## License

This project is distributed under the MIT License. See [LICENSE](LICENSE).

## Contact

**Renegade The Dev** — [@renegadethedev](https://github.com/renegadethedev) · [joaovitorbds752@gmail.com](mailto:joaovitorbds752@gmail.com)
