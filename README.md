# AlphaVoice

AlphaVoice uses a structured monorepo with independently buildable Web and API applications.

## Repository Structure

apps/
  web/                  Next.js + TypeScript application
  api/                  ASP.NET Core API host

backend/
  modules/              Business/feature-first backend module root

contracts/
  generated/            Generated contract artifacts

infra/                  Infrastructure and local-runtime assets

tests/                  Repository-level validation

docs/                   Project documentation

## Prerequisites

- Node.js
- npm
- .NET 10 SDK

## Web

Install dependencies:

    npm ci --prefix .\apps\web

Type-check:

    npm run typecheck --prefix .\apps\web

Lint:

    npm run lint --prefix .\apps\web

Production build:

    npm run build --prefix .\apps\web

Run locally:

    npm run dev --prefix .\apps\web

## API

Restore:

    dotnet restore .\apps\api\AlphaVoice.Api.csproj

Build:

    dotnet build .\apps\api\AlphaVoice.Api.csproj --no-restore

Run locally:

    dotnet run --project .\apps\api\AlphaVoice.Api.csproj

## E0-S1 Validation

Repository structure:

    powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\validate-repository.ps1

Web shell:

    powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\validate-web-shell.ps1

API shell:

    powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\validate-api-shell.ps1

Developer documentation:

    powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\validate-developer-docs.ps1

## Architecture Boundary

The backend is organized business/feature-first under `backend/modules`.

Do not introduce global `Controllers`, `Services`, or `Repositories` folders as the default backend organization.

E0-S1 contains repository and application shells only. It does not implement business/domain behavior, authentication, database schema, Redis, message brokers, paid services, or BrowserFetch.

## Local PostgreSQL Development

AlphaVoice uses real PostgreSQL for development and integration evidence. An in-memory database is not a substitute for PostgreSQL behavior.

### Local prerequisites

Restore repository-local .NET tools:

    dotnet tool restore

Set a local PostgreSQL password for the current PowerShell session:

    $securePassword = Read-Host "Enter local AlphaVoice PostgreSQL password" -AsSecureString
    $dbPassword = [System.Net.NetworkCredential]::new("", $securePassword).Password
    $env:ALPHAVOICE_POSTGRES_PASSWORD = $dbPassword

Store the API connection string in .NET User Secrets:

    dotnet user-secrets set "ConnectionStrings:AlphaVoice" "Host=localhost;Port=5432;Database=alphavoice;Username=alphavoice;Password=$dbPassword" --project .\apps\api\AlphaVoice.Api.csproj

The password and connection string must not be committed to Git.

### Start PostgreSQL

    docker compose -f .\infra\containers\postgres.compose.yml up -d --wait --wait-timeout 60

Check status:

    docker compose -f .\infra\containers\postgres.compose.yml ps

### Apply migrations

EF Core migrations are a controlled migration step. The API does not automatically migrate the database at application startup.

Set the development environment so local User Secrets are loaded:

    $env:ASPNETCORE_ENVIRONMENT = "Development"

Apply migrations explicitly:

    dotnet tool run dotnet-ef database update --project .\apps\api\AlphaVoice.Api.csproj --startup-project .\apps\api\AlphaVoice.Api.csproj

Remove the temporary environment override when finished:

    Remove-Item Env:ASPNETCORE_ENVIRONMENT -ErrorAction SilentlyContinue

### Start API

The local API uses .NET User Secrets in the Development environment. Complete the PostgreSQL startup and migration steps above first.

Set the ASP.NET Core environment explicitly:

    $env:ASPNETCORE_ENVIRONMENT = "Development"

Start the API:

    dotnet run --project .\apps\api\AlphaVoice.Api.csproj

When finished, remove the temporary environment override:

    Remove-Item Env:ASPNETCORE_ENVIRONMENT -ErrorAction SilentlyContinue

### Reset to a completely fresh database

WARNING: this removes the local AlphaVoice PostgreSQL development volume and all data stored in it.

    docker compose -f .\infra\containers\postgres.compose.yml down -v --remove-orphans

Start PostgreSQL again and apply the controlled migration chain from zero.

### Stop PostgreSQL without deleting data

    docker compose -f .\infra\containers\postgres.compose.yml down

### Fresh-database smoke test

Run the disposable PostgreSQL smoke test:

    powershell -NoProfile -ExecutionPolicy Bypass -File .\tests\smoke-postgres-fresh-db.ps1

The smoke test starts a temporary PostgreSQL container with a random host port and password, applies the complete migration chain from an empty database, verifies that no business tables are created, checks migration idempotency, and removes the temporary container when finished.

It does not delete or reset the normal local development PostgreSQL database.