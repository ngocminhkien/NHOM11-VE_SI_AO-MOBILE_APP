using System.ComponentModel.DataAnnotations;

namespace ve_si_ao_api.Models
{
    public class TripModel
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();
        
        public string Title { get; set; } = string.Empty; // Tên chuyến đi (vd: Về nhà)
        public string Time { get; set; } = string.Empty;  // Thời gian
        public string Status { get; set; } = string.Empty; // Trạng thái (vd: An toàn)
        
        // Cột này để biết chuyến đi này là của User nào
        public string UserId { get; set; } = string.Empty;
    }
}