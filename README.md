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