using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Models;

namespace ve_si_ao_api.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        // Dòng này sẽ tự động đẻ ra bảng "Users" trong MySQL Workbench của bạn
        public DbSet<UserModel> Users { get; set; }
        public DbSet<TripModel> Trips { get; set; }
        public DbSet<EmergencyContactModel> EmergencyContacts { get; set; }
    }
}
