using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Data;
using ve_si_ao_api.Models;

namespace ve_si_ao_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class EmergencyContactController : ControllerBase
    {
        private readonly AppDbContext _context;

        public EmergencyContactController(AppDbContext context)
        {
            _context = context;
        }

        // ==========================================
        // 1. API: THÊM MỚI LIÊN HỆ KHẨN CẤP
        // ==========================================
        [HttpPost("add")]
        public async Task<IActionResult> AddContact([FromBody] EmergencyContactModel request)
        {
            _context.EmergencyContacts.Add(request);
            await _context.SaveChangesAsync();

            return Ok(new { message = "Đã thêm số điện thoại khẩn cấp thành công!", data = request });
        }

        // ==========================================
        // 2. API: LẤY DANH BẠ KHẨN CẤP CỦA USER
        // ==========================================
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserContacts(string userId)
        {
            var contacts = await _context.EmergencyContacts
                .Where(c => c.UserId == userId)
                .ToListAsync();

            return Ok(new { message = "Lấy danh bạ thành công!", data = contacts });
        }
    }
}