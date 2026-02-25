using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Data;
using ve_si_ao_api.Models;

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

        // 1. API Lấy danh sách toàn bộ User (Dùng cho Flutter đọc dữ liệu)
        // GET: api/Users
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserModel>>> GetUsers()
        {
            return await _context.Users.ToListAsync();
        }

        // 2. API Tạo User mới (Dùng cho màn hình Đăng ký của Flutter)
        // POST: api/Users
        [HttpPost]
        public async Task<ActionResult<UserModel>> PostUser(UserModel user)
        {
            _context.Users.Add(user);
            await _context.SaveChangesAsync(); // Lưu thẳng vào MySQL Workbench

            return Ok(user);
        }
    }
}