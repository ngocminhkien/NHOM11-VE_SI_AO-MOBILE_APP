using Microsoft.EntityFrameworkCore;
using ve_si_ao_api.Data;

var builder = WebApplication.CreateBuilder(args);

// 1. Cấu hình Services
builder.Services.AddControllers();

// Móc nối MySQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

// --- CẤU HÌNH CORS (NÊN ĐỂ ĐẦY ĐỦ NHƯ THẾ NÀY) ---
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// 2. Cấu hình Middleware (THỨ TỰ LÀ RẤT QUAN TRỌNG TẠI ĐÂY)

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// BƯỚC 1: CORS phải nằm ngay sau Build và TRƯỚC Authorization/MapControllers
app.UseCors("AllowAll");

// Nếu bạn chạy Local qua HTTP thì có thể bỏ qua dòng HttpsRedirection này 
// app.UseHttpsRedirection(); 

app.UseAuthorization();

// BƯỚC 2: Map các Controller
app.MapControllers();
app.UseCors(policy => policy.AllowAnyHeader().AllowAnyMethod().AllowAnyOrigin());

// TẠO TÀI KHOẢN ADMIN MẶC ĐỊNH
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    // Đảm bảo Database đã được tạo
    context.Database.Migrate();

    if (!context.Users.Any(u => u.Email == "admin@safetrek.com"))
    {
        context.Users.Add(new ve_si_ao_api.Models.UserModel {
            Id = Guid.NewGuid().ToString(),
            Email = "admin@safetrek.com",
            Username = "admin",
            FullName = "Administrator",
            PhoneNumber = "0123456789",
            Role = "Admin",
            PlaintextPassword = "admin123", // Cho mục đích lưu log nếu cần
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123")
        });
        context.SaveChanges();
    }
}

app.Run();