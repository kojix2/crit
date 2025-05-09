# Crit - Git Repository Hosting Server

Crit is a lightweight Git repository hosting server built with Crystal. It provides a simple, fast, and modern web interface for managing Git repositories.

## Features

- **Repository Management**: Create, browse, and manage Git repositories
- **Web Interface**: Modern, responsive UI for repository browsing
- **File Viewer**: View repository files with syntax highlighting
- **Branch Support**: Browse different branches of repositories
- **Lightweight**: Minimal dependencies, fast performance

## Architecture

Crit follows a clean, modular architecture:

```
src/
├── models/       # Data models
├── services/     # Business logic
├── routes/       # HTTP routing
├── helpers/      # Utility functions
└── crit.cr      # Application entry point

views/            # ECR templates
├── layout.ecr    # Main layout template
├── index.ecr     # Repository list
└── ...           # Other view templates

spec/             # Test files
```

## Technical Highlights

### Clean Architecture

The application follows a clean architecture pattern with clear separation of concerns:

- **Models**: Handle data representation and basic operations
- **Services**: Implement business logic and interact with Git
- **Routes**: Define HTTP endpoints and handle requests
- **Views**: Present data to users with ECR templates

### Security

- Input validation to prevent command injection
- Path traversal protection
- Error handling with detailed logging

### Testing

Comprehensive test suite with:

- Unit tests for models and services
- Integration tests for routes
- Test coverage for both normal and edge cases

### UI/UX

- Modern, responsive design
- Intuitive navigation with breadcrumbs
- Consistent styling across all pages
- Mobile-friendly layout

## Development Decisions

### Why Crystal?

Crystal was chosen for this project because:

1. **Performance**: Near C-like performance with Ruby-like syntax
2. **Type Safety**: Static type checking prevents many runtime errors
3. **Concurrency**: Fiber-based concurrency model for handling multiple requests
4. **Syntax**: Clean, expressive syntax that enhances readability

### Git Integration

Rather than using a Git library, Crit interacts directly with Git commands for:

1. **Simplicity**: Direct Git command execution is straightforward
2. **Compatibility**: Works with any Git version installed on the system
3. **Flexibility**: Easy to extend with additional Git features

## Getting Started

### Prerequisites

- Crystal (>= 1.0.0)
- Git

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/crit.git
   cd crit
   ```

2. Install dependencies:

   ```
   shards install
   ```

3. Build the application:

   ```
   crystal build src/crit.cr
   ```

4. Run the server:

   ```
   ./crit
   ```

5. Visit `http://localhost:3000` in your browser

### Configuration

Configuration options are available in `config/config.cr`:

- `REPO_ROOT`: Directory where repositories are stored
- `PORT`: HTTP server port (default: 3000)

## Future Improvements

- User authentication and authorization
- Repository access control
- Webhook support for repository events
- Pull/merge request functionality
- Syntax highlighting improvements
- Search functionality

## Design Principles

Crit is built with these principles in mind:

- Separation of concerns with a modular architecture
- Comprehensive testing for reliability
- Security-focused development practices
- Simple and intuitive user interface

## Contributing

Contributions to Crit are welcome through issues and pull requests on GitHub.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
