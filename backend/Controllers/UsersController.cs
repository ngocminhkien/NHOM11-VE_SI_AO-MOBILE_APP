using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Data;
using ve_si_ao_api.Models;
using BCrypt.Net;

namespace ve_si_ao_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;

        public UsersController(AppDbContext context)
        {
            _context = context;
        }

        // 1. Lấy danh sách User
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserModel>>> GetUsers()
        {
            return await _context.Users.ToListAsync();
        }

        // 2. API ĐĂNG KÝ
        [HttpPost("register")]
        public async Task<ActionResult<UserModel>> Register(UserModel user)
        {
            // KIỂM TRA: Email hoặc Username đã tồn tại chưa
            if (await _context.Users.AnyAsync(u => u.Email == user.Email))
            {
                return BadRequest(new { message = "Email này đã được sử dụng!" });
            }
            
            if (await _context.Users.AnyAsync(u => u.Username == user.Username))
            {
                return BadRequest(new { message = "Tên đăng nhập này đã tồn tại!" });
            }

            if (string.IsNullOrEmpty(user.PlaintextPassword))
            {
                return BadRequest(new { message = "Mật khẩu không được để trống!" });
            }

            // Mã hóa mật khẩu
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(user.PlaintextPassword);

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đăng ký thành công!", userId = user.Id });
        }

        // ==========================================
        // API LƯU FCM TOKEN CỦA THIẾT BỊ
        // ==========================================
        [HttpPut("{id}/fcm-token")]
        public async Task<IActionResult> UpdateFCMToken(string id, [FromBody] UpdateFCMRequest request)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null) return NotFound(new { message = "Không tìm thấy người dùng!" });

            user.FCMToken = request.Token;
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã cập nhật Token thiết bị." });
        }

        // 3. API ĐĂNG NHẬP (HỖ TRỢ EMAIL VÀ TÊN ĐĂNG NHẬP)
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            // SỬA TẠI ĐÂY: Tìm user có Email KHỚP hoặc Username KHỚP với thông tin nhập vào
            var user = await _context.Users.FirstOrDefaultAsync(u => 
                u.Email == request.Email || u.Username == request.Email);

            if (user == null)
            {
                return Unauthorized(new { message = "Tài khoản hoặc mật khẩu không đúng!" });
            }

            // Giải mã và kiểm tra mật khẩu
            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);

            if (!isPasswordValid)
            {
                return Unauthorized(new { message = "Tài khoản hoặc mật khẩu không đúng!" });
            }

            // Đăng nhập thành công
            return Ok(new 
            { 
                message = "Đăng nhập thành công!", 
                user = new { 
                    user.Id, 
                    user.Username, // Trả thêm Username về cho Flutter
                    user.Email, 
                    user.FullName, 
                    user.PhoneNumber, 
                    user.Role 
                } 
            });
        }
        
        [HttpGet("stats")]
        public async Task<ActionResult<object>> GetUserStats()
        {
            var now = DateTime.Now;
            var today = DateTime.Today;
            var thisMonth = new DateTime(today.Year, today.Month, 1);
            var last24Hours = now.AddDays(-1);
            
            var dailyCount = await _context.Users.CountAsync(u => u.CreatedAt >= last24Hours);
            var monthlyCount = await _context.Users.CountAsync(u => u.CreatedAt >= thisMonth);
            var activeCount = await _context.Users.CountAsync(u => u.IsActive);
            var blockedCount = await _context.Users.CountAsync(u => u.IsBlocked);
            var totalCount = await _context.Users.CountAsync();
            
            return new { 
                dailyCount, 
                monthlyCount, 
                activeCount, 
                blockedCount,
                totalCount
            };
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateUser(string id, UserModel user)
        {
            if (id != user.Id) return BadRequest();
            _context.Entry(user).State = EntityState.Modified;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpPost]
        public async Task<ActionResult<UserModel>> AddUser(UserModel user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
            return Ok(user);
        }
    }

    public class LoginRequest
    {
        // Field này nhận giá trị từ ô "Tên đăng nhập hoặc email" trên Flutter
        public string Email { get; set; } = string.Empty; 
        public string Password { get; set; } = string.Empty;
    }

    public class UpdateFCMRequest
    {
        public string Token { get; set; } = string.Empty;
    }
}