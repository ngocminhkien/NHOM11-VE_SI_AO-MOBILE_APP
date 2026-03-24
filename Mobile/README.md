# Dự án Vệ Sĩ Ảo (SafeTrek Vietnam) - Mobile App

Chào mừng bạn đến với **Vệ Sĩ Ảo (SafeTrek Vietnam)**, một ứng dụng di động bảo vệ an toàn cá nhân và hỗ trợ theo dõi chuyến đi, đi kèm với hệ thống Bảng điều khiển Quản trị viên (Admin Dashboard) mạnh mẽ.

## 🛠 Công cụ và Ngôn ngữ sử dụng
Dự án được xây dựng với kiến trúc Client-Server hiện đại:
- **Ngôn ngữ Frontend:** Dart.
- **Framework Mobile & Web:** Flutter (phát triển đa nền tảng cho Mobile và Web).
- **Backend API:** C# với framework .NET 8 Web API.
- **Cơ sở dữ liệu:** MySQL (được quản lý thông qua Entity Framework Core).
- **State Management:** Provider (Quản lý trạng thái nội bộ của Flutter).

## 🚀 Trải nghiệm tính năng Quản trị viên (Admin)

Ứng dụng cho phép phân quyền người dùng. Khi bạn đăng nhập với vai trò `Admin`, hệ thống sẽ tự động điều hướng bạn tới **Trang Quản Trị (Dashboard)** thay vì trang người dùng thông thường.

## Tài khoản Admin mặc định
- **Email**: `admin@safetrek.com`
- **Mật khẩu**: `admin123`

## Chức năng Đồng bộ (Real-time Sync)
Hệ thống Admin tự động cập nhật dữ liệu từ máy chủ mỗi **5 giây**. Khi người dùng nhấn nút **SOS** trên ứng dụng, tín hiệu sẽ lập tức xuất hiện tại mục **Cảnh báo khẩn cấp** trên Dashboard của Admin.

## Cách chạy chương trình
1. **Backend**: Chạy `dotnet run` trong thư mục `backend`.
2. **Mobile**: Chạy `flutter run -d chrome` trong thư mục `Mobile`.

## 📖 Hướng dẫn khởi chạy ứng dụng (Web App)

Để biên dịch và chạy ứng dụng Flutter dưới dạng một trang Web (Web App), bạn hãy làm theo các bước sau:

### Bước 1: Khởi chạy Backend (.NET 8)
Trước khi chạy Web App, máy chủ Backend phải hoạt động để các API Đăng nhập và Thống kê có thể phản hồi.
1. Mở Terminal / PowerShell và trỏ vào thư mục `backend`.
2. Chạy lệnh:
   ```bash
   dotnet run
   ```
   Backend sẽ lắng nghe ở địa chỉ `http://localhost:xxxx` (thường hiển thị trong terminal sau khi lệnh được chạy).

### Bước 2: Khởi chạy Frontend Web (Flutter)
1. Mở một Terminal khác và trỏ vào thư mục `Mobile`.
2. Lấy các gói phụ thuộc (Dependencies):
   ```bash
   flutter pub get
   ```
3. Khởi chạy ứng dụng bằng trình duyệt Chrome tích hợp:
   ```bash
   flutter run -d chrome
   ```
   *(Hoặc để build ra file tĩnh đẩy lên host, bạn dùng lệnh `flutter build web` và lấy code trong folder `build/web/`)*.

---
**Chúc bạn có trải nghiệm tuyệt vời với hệ thống Vệ Sĩ Ảo!**
