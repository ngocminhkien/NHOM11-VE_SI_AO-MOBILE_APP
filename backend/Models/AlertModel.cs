using System;
using System.ComponentModel.DataAnnotations;

namespace ve_si_ao_api.Models
{
    public class AlertModel
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();

        public string UserId { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string AlertType { get; set; } = string.Empty; // SOS, Bất thường...
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsHandled { get; set; } = false;
        public string Location { get; set; } = string.Empty; // Vĩ độ, Kinh độ
        public string Message { get; set; } = string.Empty;  // Lời nhắn thêm (nếu có)
    }
}
