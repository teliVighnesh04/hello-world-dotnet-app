# Stage 1: build
FROM mcr.microsoft.com/dotnet/sdk:2.1 AS build
WORKDIR /src

# copy solution & project files
COPY dotnet-hello-world.sln ./
COPY hello-world-api/hello-world-api.csproj hello-world-api/
# restore (use project path)
RUN dotnet restore

# copy everything and publish
COPY . .
WORKDIR /src/hello-world-api
RUN dotnet publish -c Release -o /app/publish

# Stage 2: runtime
FROM mcr.microsoft.com/dotnet/aspnet:2.1 AS runtime
WORKDIR /app

# optional: tell ASP.NET Core to listen on port 5000
ENV ASPNETCORE_URLS=http://+:5000

COPY --from=build /app/publish .
EXPOSE 5000

ENTRYPOINT ["dotnet", "hello-world-api.dll"]

