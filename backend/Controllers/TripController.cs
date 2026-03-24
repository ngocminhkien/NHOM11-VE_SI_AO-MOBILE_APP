using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Data;
using ve_si_ao_api.Models;

namespace ve_si_ao_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class TripController : ControllerBase
    {
        private readonly AppDbContext _context;

        // Bơm Database vào Controller
        public TripController(AppDbContext context)
        {
            _context = context;
        }

        // ==========================================
        // 1. API: BẮT ĐẦU CHUYẾN ĐI (Tạo mới)
        // ==========================================
        [HttpPost("start")]
        public async Task<IActionResult> StartTrip([FromBody] TripModel request)
        {
            request.Status = "Đang di chuyển";
            _context.Trips.Add(request);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Đã tạo chuyến đi thành công!", data = request });
        }

        // ==========================================
        // 2. API: GỬI TÍN HIỆU SOS HOẶC BÁO AN TOÀN
        // ==========================================
        [HttpPut("{id}/status")]
        public async Task<IActionResult> UpdateTripStatus(string id, [FromBody] UpdateStatusDto request)
        {
            var trip = await _context.Trips.FindAsync(id);
            if (trip == null) 
            {
                return NotFound(new { message = "Không tìm thấy chuyến đi này!" });
            }

            trip.Status = request.Status;
            await _context.SaveChangesAsync();
            return Ok(new { message = $"Đã cập nhật trạng thái thành: {trip.Status}", data = trip });
        }

        // ==========================================
        // 3. API: LẤY LỊCH SỬ CHUYẾN ĐI CỦA 1 NGƯỜI DÙNG
        // ==========================================
        [HttpGet("user/{userId}")]
        public async Task<IActionResult> GetUserTrips(string userId)
        {
            var trips = await _context.Trips
                .Where(t => t.UserId == userId)
                .ToListAsync();

            if (trips.Count == 0)
            {
                return Ok(new { message = "Chưa có chuyến đi nào.", data = trips });
            }

            return Ok(new { message = "Lấy lịch sử thành công!", data = trips });
        }
    } 
    public class UpdateStatusDto
    {
        public string Status { get; set; } = string.Empty;
    }
}