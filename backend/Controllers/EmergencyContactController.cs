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
        // 1. API: THÊM LIÊN HỆ (BẢN NÂNG CẤP "TÌM NGƯỜI THÂN")
        // ==========================================
        [HttpPost("add")]
        public async Task<IActionResult> AddContact([FromBody] EmergencyContactModel request)
        {
            // BƯỚC 1: SỬA LẠI THÀNH request.Phone CHO KHỚP VỚI DATABASE
            var linkedUser = await _context.Users
                .FirstOrDefaultAsync(u => u.PhoneNumber == request.Phone);

            bool isAppUser = (linkedUser != null);

            // BƯỚC 2: Lưu vào Database
            _context.EmergencyContacts.Add(request);
            await _context.SaveChangesAsync();

            // BƯỚC 3: Trả về thông báo thông minh cho App Flutter
            if (isAppUser)
            {
                return Ok(new { 
                    message = $"Đã thêm thành công! Người dùng {linkedUser.FullName} đang sử dụng Vệ Sĩ Ảo. Họ sẽ nhận được báo động trực tiếp trên App.", 
                    data = request,
                    isLinked = true 
                });
            }
            else
            {
                return Ok(new { 
                    message = "Đã thêm thành công! (Lưu ý: Người này chưa cài App, hệ thống sẽ gửi tin nhắn SMS khi có sự cố).", 
                    data = request,
                    isLinked = false
                });
            }
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

        // ==========================================
        // 3. API: SỬA LIÊN HỆ 
        // ==========================================
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateContact(string id, [FromBody] EmergencyContactModel request)
        {
            var contact = await _context.EmergencyContacts.FindAsync(id);
            if (contact == null) return NotFound(new { message = "Không tìm thấy liên hệ này!" });

            contact.Name = request.Name;
            contact.Phone = request.Phone;
            contact.Email = request.Email;
            contact.Relation = request.Relation;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã cập nhật liên hệ thành công!", data = contact });
        }

        // ==========================================
        // 4. API: XOÁ LIÊN HỆ
        // ==========================================
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteContact(string id)
        {
            var contact = await _context.EmergencyContacts.FindAsync(id);
            if (contact == null) return NotFound(new { message = "Không tìm thấy liên hệ này!" });

            _context.EmergencyContacts.Remove(contact);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã xóa liên hệ thành công!" });
        }
    }
}