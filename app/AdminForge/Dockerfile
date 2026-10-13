
# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:10.0-alpine AS build
WORKDIR /src

# Copy project files first to improve build caching
COPY global.json Directory.Build.props AdminForge.sln ./
COPY src/AdminForge.Core/AdminForge.Core.csproj src/AdminForge.Core/
COPY src/AdminForge.Tools/AdminForge.Tools.csproj src/AdminForge.Tools/
COPY src/AdminForge.Web/AdminForge.Web.csproj src/AdminForge.Web/
COPY tests/AdminForge.Tests/AdminForge.Tests.csproj tests/AdminForge.Tests/

# Restore NuGet dependencies
RUN dotnet restore AdminForge.sln

# Copy the remaining application source code
COPY . .

# Compile and publish the application
RUN dotnet publish src/AdminForge.Web/AdminForge.Web.csproj \
    --configuration Release \
    --no-restore \
    --output /out

# Stage 2: Run the application
FROM mcr.microsoft.com/dotnet/aspnet:10.0-alpine AS runtime
WORKDIR /app

# Create a non-root user
RUN addgroup -S adminforge && \
    adduser -S -G adminforge adminforge

# Copy only the published application from the build stage
COPY --from=build --chown=root:root /out/ ./

# Configure the application
ENV ASPNETCORE_HTTP_PORTS=8080 \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_EnableDiagnostics=0

# Document the application port
EXPOSE 8080

# Run as the non-root user
USER adminforge

# Check whether the application is healthy
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --quiet --spider http://127.0.0.1:8080/healthz || exit 1

# Start the application
ENTRYPOINT ["dotnet", "AdminForge.Web.dll"]

