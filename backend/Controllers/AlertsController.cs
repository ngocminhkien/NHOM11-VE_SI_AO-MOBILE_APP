using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Data;
using ve_si_ao_api.Models;
using Microsoft.AspNetCore.SignalR;
using ve_si_ao_api.Hubs;

namespace ve_si_ao_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AlertsController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IHubContext<AlertHub> _hubContext;

        public AlertsController(AppDbContext context, IHubContext<AlertHub> hubContext)
        {
            _context = context;
            _hubContext = hubContext;
        }

        [HttpPost]
        public async Task<ActionResult<AlertModel>> PostAlert(AlertModel alert)
        {
            alert.CreatedAt = DateTime.Now;
            alert.IsHandled = false;
            _context.Alerts.Add(alert);
            await _context.SaveChangesAsync();

            // Gửi tín hiệu real-time tới các admin đang kết nối
            await _hubContext.Clients.Group("Admins").SendAsync("ReceiveAlert", alert);

            return CreatedAtAction("GetAlert", new { id = alert.Id }, alert);
        }

        [HttpGet("unhandled")]
        public async Task<ActionResult<IEnumerable<AlertModel>>> GetUnhandledAlerts()
        {
            return await _context.Alerts
                .Where(a => !a.IsHandled)
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();
        }

        [HttpPut("{id}/resolve")]
        public async Task<IActionResult> ResolveAlert(int id)
        {
            var alert = await _context.Alerts.FindAsync(id);
            if (alert == null) return NotFound();
            alert.IsHandled = true;
            await _context.SaveChangesAsync();
            return NoContent();
        }

        [HttpGet("stats")]
        public async Task<ActionResult<object>> GetAlertStats()
        {
            var today = DateTime.Today;
            var thisMonth = new DateTime(today.Year, today.Month, 1);
            var dailyCount = await _context.Alerts.CountAsync(a => a.CreatedAt >= today);
            var monthlyCount = await _context.Alerts.CountAsync(a => a.CreatedAt >= thisMonth);
            return new { dailyCount, monthlyCount };
        }

        [HttpGet("history")]
        public async Task<ActionResult<IEnumerable<AlertModel>>> GetAlertHistory()
        {
            return await _context.Alerts
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<AlertModel>> GetAlert(int id)
        {
            var alert = await _context.Alerts.FindAsync(id);
            if (alert == null) return NotFound();
            return alert;
        }
    }
}
