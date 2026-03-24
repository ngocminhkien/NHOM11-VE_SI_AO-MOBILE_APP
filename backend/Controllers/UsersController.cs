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

        // 1.1 Lấy thống kê Users (Dành cho Admin)
        [HttpGet("stats")]
        public async Task<ActionResult> GetUserStats()
        {
            var totalUsers = await _context.Users.CountAsync();
            var totalTrips = await _context.Trips.CountAsync();
            var now = DateTime.UtcNow;
            var twentyFourHoursAgo = now.AddHours(-24);
            var newUsers24h = await _context.Users.CountAsync(u => u.CreatedAt >= twentyFourHoursAgo);
            
            return Ok(new { TotalUsers = totalUsers, TotalTrips = totalTrips, NewUsersToday = newUsers24h });
        }

        // 1.2 Xóa User (Dành cho Admin)
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteUser(string id)
        {
            var user = await _context.Users.FindAsync(id);
            if (user == null)
            {
                return NotFound();
            }

            _context.Users.Remove(user);
            await _context.SaveChangesAsync();

            return NoContent();
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
    }

    public class LoginRequest
    {
        // Field này nhận giá trị từ ô "Tên đăng nhập hoặc email" trên Flutter
        public string Email { get; set; } = string.Empty; 
        public string Password { get; set; } = string.Empty;
    }
}