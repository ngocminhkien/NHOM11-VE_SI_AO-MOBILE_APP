using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ve_si_ao_api.Data;
using ve_si_ao_api.Models;

namespace ve_si_ao_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AlertsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AlertsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Alerts
        [HttpGet]
        public async Task<ActionResult<IEnumerable<AlertModel>>> GetAlerts()
        {
            return await _context.Alerts.OrderByDescending(a => a.CreatedAt).ToListAsync();
        }

        // GET: api/Alerts/Unhandled
        [HttpGet("unhandled")]
        public async Task<ActionResult<IEnumerable<AlertModel>>> GetUnhandledAlerts()
        {
            return await _context.Alerts.Where(a => !a.IsHandled).OrderByDescending(a => a.CreatedAt).ToListAsync();
        }

        // GET: api/Alerts/stats
        [HttpGet("stats")]
        public async Task<ActionResult> GetAlertStats()
        {
            var now = DateTime.UtcNow;
            var thirtyDaysAgo = now.AddDays(-30);
            var todayStart = now.Date;

            var monthlyCount = await _context.Alerts.CountAsync(a => a.CreatedAt >= thirtyDaysAgo);
            var dailyCount = await _context.Alerts.CountAsync(a => a.CreatedAt >= todayStart);

            return Ok(new { MonthlyCount = monthlyCount, DailyCount = dailyCount });
        }

        // GET: api/Alerts/history
        [HttpGet("history")]
        public async Task<ActionResult<IEnumerable<AlertModel>>> GetAlertHistory()
        {
            var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);
            return await _context.Alerts
                .Where(a => a.CreatedAt >= thirtyDaysAgo)
                .OrderByDescending(a => a.CreatedAt)
                .ToListAsync();
        }

        // GET: api/Alerts/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<AlertModel>> GetAlertDetail(string id)
        {
            var alert = await _context.Alerts.FindAsync(id);
            if (alert == null) return NotFound();
            return alert;
        }

        // POST: api/Alerts
        [HttpPost]
        public async Task<ActionResult<AlertModel>> CreateAlert(AlertModel alert)
        {
            _context.Alerts.Add(alert);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetAlerts), new { id = alert.Id }, alert);
        }

        // PUT: api/Alerts/{id}/resolve
        [HttpPut("{id}/resolve")]
        public async Task<IActionResult> ResolveAlert(string id)
        {
            var alert = await _context.Alerts.FindAsync(id);
            if (alert == null)
            {
                return NotFound();
            }

            alert.IsHandled = true;
            _context.Entry(alert).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!AlertModelExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        private bool AlertModelExists(string id)
        {
            return _context.Alerts.Any(e => e.Id == id);
        }
    }
}
