using System.ComponentModel.DataAnnotations;

namespace ve_si_ao_api.Models
{
    public class EmergencyContactModel
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();
        
        public string Name { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string Relation { get; set; } = string.Empty;
        public bool IsVerified { get; set; } = false; // Nút gạt bật/tắt
        
        // Cột này để biết danh bạ này thuộc về User nào
        public string UserId { get; set; } = string.Empty;
    }
}