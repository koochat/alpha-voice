using AlphaVoice.Api.Database;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

var connectionString =
    builder.Configuration.GetConnectionString("AlphaVoice");

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "Connection string 'AlphaVoice' is required. Configure it through local secrets or environment variables.");
}

builder.Services.AddDbContext<AlphaVoiceDbContext>(options =>
    options.UseNpgsql(connectionString));

var app = builder.Build();

app.Run();