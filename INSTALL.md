# Installation Guide for Crit

This guide explains how to set up and run Crit, a lightweight Git repository hosting server.

## Prerequisites

- Docker (recommended)
- Or Crystal (>= 1.0.0) and Git for local build

## Using Docker (Recommended)

### Quick Start

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/crit.git
   cd crit
   ```

2. Copy the example environment file:
   ```
   cp .env.example .env
   ```

3. Edit the `.env` file to customize your settings

4. Build and run with Docker:
   ```
   docker build -t crit .
   docker run -d -p 3000:3000 --env-file .env --name crit crit
   ```

5. Access Crit at http://localhost:3000 in your browser

### Docker Run Options

```
docker run -d \
  -p 3000:3000 \
  --env-file .env \
  -v /your/host/dir:/data/git \
  --name crit \
  crit
```

- `-p 3000:3000`: Maps container port 3000 to host port 3000
- `--env-file .env`: Uses variables from your .env file
- `-v /your/host/dir:/data/git`: Mounts a volume for persistent repository storage

## Environment Variables

| Variable        | Description                  | Default Value   |
|-----------------|------------------------------|-----------------|
| CRIT_USER       | Admin username               | admin           |
| CRIT_PASS       | Admin password               | yourpassword    |
| CRIT_REPO_ROOT  | Repository storage directory | /data/git       |
| PORT            | Server port                  | 3000            |
| LOG_LEVEL       | Logging level                | INFO            |
| KEMAL_ENV       | Kemal environment            | development     |

## Local Installation (Alternative)

If you prefer not to use Docker:

1. Install Crystal (>= 1.0.0) and Git

2. Clone the repository:
   ```
   git clone https://github.com/yourusername/crit.git
   cd crit
   ```

3. Copy the example environment file:
   ```
   cp .env.example .env
   ```

4. Install dependencies:
   ```
   shards install
   ```

5. Build the application:
   ```
   crystal build src/crit.cr
   ```

6. Run the server:
   ```
   ./crit
   ```

7. Access Crit at http://localhost:3000 in your browser

## Troubleshooting

### Common Issues

- **Port already in use**: Change the port in your .env file and Docker run command
- **Permission denied**: Ensure proper permissions for the repository directory
- **Authentication fails**: Check your CRIT_USER and CRIT_PASS environment variables

For more help, please open an issue on GitHub.
