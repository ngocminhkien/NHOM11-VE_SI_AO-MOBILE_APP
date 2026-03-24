using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ve_si_ao_api.Models
{
    public class UserModel
    {
        [Key]
        public string Id { get; set; } = Guid.NewGuid().ToString();
        
        // 1. TÊN ĐĂNG NHẬP (Dùng để login, ví dụ: thanh_vsa_2026)
        [Required]
        public string Username { get; set; } = string.Empty;

        // 2. EMAIL (Dùng để login hoặc khôi phục mật khẩu)
        [Required]
        public string Email { get; set; } = string.Empty;

        public string FullName { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string Role { get; set; } = "user";

        // Mật khẩu gốc từ Flutter gửi lên (Không lưu vào DB)
        [NotMapped]
        public string? PlaintextPassword { get; set; } 

        // Mật khẩu đã mã hóa (Lưu vào DB)
        public string? PasswordHash { get; set; } 
        
        // Token thiết bị FireBase Cloud Messaging (FCM)
        public string? FCMToken { get; set; }
    }
}