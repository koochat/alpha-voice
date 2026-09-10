using Microsoft.EntityFrameworkCore;

namespace AlphaVoice.Api.Database;

public sealed class AlphaVoiceDbContext : DbContext
{
    public AlphaVoiceDbContext(
        DbContextOptions<AlphaVoiceDbContext> options)
        : base(options)
    {
    }
}