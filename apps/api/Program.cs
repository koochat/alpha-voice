using System.Reflection;
using AlphaVoice.Api.Database;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenApi(options =>
{
    options.OpenApiVersion = Microsoft.OpenApi.OpenApiSpecVersion.OpenApi3_0;
});

var isOpenApiDocumentGeneration = Assembly.GetEntryAssembly()?.GetName().Name == "GetDocument.Insider";

if (!isOpenApiDocumentGeneration)
{
    var connectionString = builder.Configuration.GetConnectionString("AlphaVoice");

    if (string.IsNullOrWhiteSpace(connectionString))
    {
        throw new InvalidOperationException(
            "Connection string 'AlphaVoice' is required. Configure it through local secrets or environment variables.");
    }

    builder.Services.AddDbContext<AlphaVoiceDbContext>(options =>
        options.UseNpgsql(connectionString));
}

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();

    app.MapGet("/api/dev-probe", () =>
        Results.Ok(new
        {
            message = "AlphaVoice API reachable through same-origin development routing"
        }))
        .ExcludeFromDescription();
}

app.Run();
