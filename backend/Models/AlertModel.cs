using System;

namespace ve_si_ao_api.Models
{
    public class AlertModel
    {
        public int Id { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string AlertType { get; set; } = "SOS"; 
        public DateTime CreatedAt { get; set; } = DateTime.Now;
        public bool IsHandled { get; set; } = false;
        public string Location { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
    }
}
