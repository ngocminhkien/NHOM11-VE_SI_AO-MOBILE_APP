using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Models;

namespace ve_si_ao_api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<UserModel> Users { get; set; }
        public DbSet<TripModel> Trips { get; set; }
        public DbSet<EmergencyContactModel> EmergencyContacts { get; set; }
        public DbSet<AlertModel> Alerts { get; set; } // RESTORED
    }
}
