using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Data;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();

// Móc nối MySQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// --- THÊM ĐOẠN NÀY ĐỂ MỞ KHÓA CORS CHO FLUTTER WEB ---
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});
// -----------------------------------------------------

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// --- THÊM DÒNG NÀY ĐỂ KÍCH HOẠT CORS ---
app.UseCors("AllowAll");
// ---------------------------------------

app.UseAuthorization();
app.MapControllers();

app.Run();