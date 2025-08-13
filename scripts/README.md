# Scripts Collection

A collection of utility scripts for system automation and development workflows.

## Directory Structure

Each script or tool is organized in its own subdirectory with documentation:

```
scripts/
├── README.md                 # This file
└── git-auto-pull/           # Automatic git repository synchronization
    ├── git-auto-pull.sh     # The script
    └── README.md            # Setup and usage instructions
```

## Available Tools

### git-auto-pull
Automatically pulls git repositories to keep them synchronized across multiple machines. Runs every 5 minutes via systemd timer.

## Installation

Each tool has its own README with specific installation instructions. Generally:

1. Navigate to the tool's directory
2. Read the README.md for that tool
3. Follow the installation steps

## Adding New Scripts

When adding a new script:

1. Create a subdirectory with the script name
2. Place the script in that directory
3. Create a README.md with:
   - Description of what the script does
   - Installation instructions
   - Usage examples
   - Configuration options
   - Troubleshooting tips

## Contributing

Feel free to add your own utility scripts following the directory structure above.