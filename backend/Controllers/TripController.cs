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

            // Nếu trạng thái là SOS, tiến hành gửi Đa Kênh
            if (request.Status == "SOS")
            {
                // Lấy thông tin user
                var user = await _context.Users.FindAsync(trip.UserId);
                
                // Lấy danh bạ khẩn cấp
                var contacts = await _context.EmergencyContacts.Where(c => c.UserId == trip.UserId).ToListAsync();
                
                // 1. Kênh Push Notification (FCM)
                // (Chỉ gửi Push Notification tới những Contact có cài App - tức là SĐT hoặc Email của Contact trùng với bảng User)
                var contactEmails = contacts.Where(c => !string.IsNullOrEmpty(c.Email)).Select(c => c.Email).ToList();
                var contactPhones = contacts.Where(c => !string.IsNullOrEmpty(c.Phone)).Select(c => c.Phone).ToList();
                
                var relativeUsers = await _context.Users
                    .Where(u => contactEmails.Contains(u.Email) || contactPhones.Contains(u.PhoneNumber))
                    .ToListAsync();
                
                foreach (var relative in relativeUsers)
                {
                    if (!string.IsNullOrEmpty(relative.FCMToken))
                    {
                        try 
                        {
                            var message = new FirebaseAdmin.Messaging.Message()
                            {
                                Token = relative.FCMToken,
                                Notification = new FirebaseAdmin.Messaging.Notification()
                                {
                                    Title = "SOS KHẨN CẤP!",
                                    Body = $"{user?.FullName ?? "Người thân"} vừa kích hoạt SOS. Xin hãy kiểm tra ngay lập tức!"
                                },
                                Data = new Dictionary<string, string>()
                                {
                                    { "tripId", id },
                                    { "lat", request.Latitude?.ToString() ?? "" },
                                    { "lng", request.Longitude?.ToString() ?? "" }
                                }
                            };

                            if (FirebaseAdmin.FirebaseApp.DefaultInstance != null) 
                            {
                                await FirebaseAdmin.Messaging.FirebaseMessaging.DefaultInstance.SendAsync(message);
                            }
                        }
                        catch (Exception ex) 
                        {
                            Console.WriteLine($"Lỗi gửi FCM: {ex.Message}");
                        }
                    }
                }

                // 2. Kênh Email (MailKit)
                foreach(var contact in contacts)
                {
                    if(!string.IsNullOrEmpty(contact.Email))
                    {
                        try 
                        {
                            var email = new MimeKit.MimeMessage();
                            email.From.Add(new MimeKit.MailboxAddress("SafeTrek Vietnam", "noreply@safetrek.vn"));
                            email.To.Add(new MimeKit.MailboxAddress(contact.Name, contact.Email));
                            email.Subject = "SOS KHẨN CẤP TỪ " + (user?.FullName ?? "Người thân");

                            var builder = new MimeKit.BodyBuilder();
                            string mapLink = request.Latitude != null && request.Longitude != null 
                                ? $"https://www.google.com/maps/search/?api=1&query={request.Latitude},{request.Longitude}" 
                                : "Không xác định được vị trí.";
                            
                            builder.HtmlBody = $@"
                                <h2>CẢNH BÁO SOS KHẨN CẤP!</h2>
                                <p>Người thân của bạn vừa kích hoạt cảnh báo SOS trên hệ thống Vệ Sĩ Ảo.</p>
                                <p><strong>Vị trí hiện tại:</strong> <a href='{mapLink}'>Bấm vào đây để xem trên Bản đồ Google</a></p>
                                <p>Xin hãy liên hệ và kiểm tra ngay lập tức!</p>";

                            email.Body = builder.ToMessageBody();

                            using var smtp = new MailKit.Net.Smtp.SmtpClient();
                            // Lưu ý: Đây là placeholder. Chủ hệ thống cần điền Credentials thật.
                            // await smtp.ConnectAsync("smtp.gmail.com", 587, MailKit.Security.SecureSocketOptions.StartTls);
                            // await smtp.AuthenticateAsync("YOUR_GMAIL_HERE", "YOUR_APP_PASSWORD");
                            // await smtp.SendAsync(email);
                            // await smtp.DisconnectAsync(true);
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"Lỗi gửi Email: {ex.Message}");
                        }
                    }
                }
            }

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
        // ==========================================
        // 4. API: LẤY TẤT CẢ CHUYẾN ĐI (Dành cho Admin)
        // ==========================================
        [HttpGet]
        public async Task<IActionResult> GetAllTrips()
        {
            var trips = await _context.Trips.ToListAsync();
            return Ok(new { message = "Lấy danh sách chuyến đi thành công!", data = trips });
        }

        // ==========================================
        // 5. API: SỐ CHUYẾN ĐI HÔM NAY (Dùng cho Dashboard Admin)
        // ==========================================
        [HttpGet("stats/today")]
        public async Task<IActionResult> GetTodayStats()
        {
            var today = DateTime.Today;
            var todayCount = await _context.Trips.CountAsync(t => t.CreatedAt >= today);
            var totalCount = await _context.Trips.CountAsync();
            return Ok(new { todayCount, totalCount });
        }
    } 
    public class UpdateStatusDto
    {
        public string Status { get; set; } = string.Empty;
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
    }
}