# Multi-Maven Project with Jenkins Multi-Branch Pipeline

This repository contains 3 Maven projects that are built automatically by Jenkins using a Multi-Branch Pipeline on K3s.

## Projects

- **project-a**: First Maven project
- **project-b**: Second Maven project
- **project-c**: Third Maven project

## Branch Strategy

| Branch | Environment | Purpose |
|--------|-------------|---------|
| `main` | prod | Production releases |
| `develop` | dev | Development |
| `release/*` | qa | QA/Staging |

## Jenkins Pipeline

The pipeline automatically:
- Detects which projects changed
- Builds only changed projects
- Uses environment-specific configuration
- Creates JAR files with Maven Assembly

## Local Build

```bash
# Build all projects
mvn clean package -Dbuild.env=dev

# Build specific project
mvn -f project-a/pom.xml clean package -Dbuild.env=dev
```

## Artifacts

Built artifacts are named: `{project}-{version}-{environment}.jar`

Example: `project-a-1.0.0-prod.jar`
