-- TẠO DATABASE (nếu chưa có)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'QLCH')
BEGIN
    CREATE DATABASE QLCH;
END
GO

USE QLCH;
GO

-- 1. BẢNG CHỨC VỤ
CREATE TABLE ChucVu (
    MaChucVu INT PRIMARY KEY,
    TenChucVu VARCHAR(100)
);
GO

-- 2. BẢNG BỘ PHẬN
CREATE TABLE BoPhan (
    MaBoPhan INT PRIMARY KEY,
    TenBoPhan VARCHAR(100),
    ToTruong VARCHAR(100),
    SoDienThoaiBP VARCHAR(20),
    MaNhanVien INT  -- giữ nguyên kiểu, không đặt FK vì NhanVien còn tạo sau
);
GO

-- 3. BẢNG NHÀ CUNG CẤP
CREATE TABLE NhaCungCap (
    MaNhaCungCap INT PRIMARY KEY,
    TenNhaCungCap VARCHAR(150),
    DiaChi VARCHAR(255),
    SoDienThoai VARCHAR(20),
    Email VARCHAR(50),
    MST VARCHAR(20),
    STK VARCHAR(30)
);
GO

-- 4. BẢNG LOẠI HÀNG
CREATE TABLE LoaiHang (
    MaLoaiHang INT PRIMARY KEY,
    TenLoaiHang VARCHAR(100),
    MauMa VARCHAR(50),
    NoiSanXuat VARCHAR(100)
);
GO

-- 5. BẢNG KHÁCH HÀNG
CREATE TABLE KhachHang (
    MaKhachHang INT PRIMARY KEY,
    TenKhachHang VARCHAR(100),
    SDT VARCHAR(20),
    GioiTinh VARCHAR(10),
    DiaChi VARCHAR(255),
    CCCD VARCHAR(20),
    Email VARCHAR(50),
    STK VARCHAR(30)
);
GO

-- 6. BẢNG NHÂN VIÊN (tham chiếu ChucVu, BoPhan)
CREATE TABLE NhanVien (
    MaNhanVien INT PRIMARY KEY,
    MaChucVu INT NULL,
    GioiTinh VARCHAR(10),
    SoDienThoai VARCHAR(20),
    NgaySinh DATE,
    DiaChi VARCHAR(255),
    MaBoPhan INT NULL,
    HoVaTen VARCHAR(100),
    CONSTRAINT FK_NhanVien_ChucVu FOREIGN KEY (MaChucVu) REFERENCES ChucVu(MaChucVu),
    CONSTRAINT FK_NhanVien_BoPhan FOREIGN KEY (MaBoPhan) REFERENCES BoPhan(MaBoPhan)
);
GO

-- 7. NHÂN VIÊN FULLTIME
CREATE TABLE NhanVien_FullTime (
    MaNhanVien INT PRIMARY KEY,
    HopDongDaiHan VARCHAR(20),
    LuongCoBan DECIMAL(12,2),
    CONSTRAINT FK_FullTime_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);
GO

-- 8. NHÂN VIÊN PARTTIME
CREATE TABLE NhanVien_PartTime (
    MaNhanVien INT PRIMARY KEY,
    SoGioLam INT,
    LuongTheoGio DECIMAL(12,2),
    CONSTRAINT FK_PartTime_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);
GO

-- 9. BẢNG LƯƠNG
CREATE TABLE Luong (
    MaNhanVien INT PRIMARY KEY,
    ThoiGian INT,
    NghiKhongPhep INT,
    LuongThang13 DECIMAL(12,2),
    NgayBatDau DATE,
    CONSTRAINT FK_Luong_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);
GO

-- 10. BẢNG HỢP ĐỒNG (tham chiếu NhaCungCap)
CREATE TABLE HopDong (
    MaHopDong INT PRIMARY KEY,
    MaNhaCungCap INT,
    NgayKyKet DATE,
    NgayHetHan DATE,
    GiaTriHopDong DECIMAL(14,2),
    DieuKhoan VARCHAR(255),
    TrangThai VARCHAR(50),
    GhiChu VARCHAR(255),
    CONSTRAINT FK_HopDong_NhaCungCap FOREIGN KEY (MaNhaCungCap) REFERENCES NhaCungCap(MaNhaCungCap)
);
GO

-- 11. LÔ HÀNG (tham chiếu HopDong)
CREATE TABLE LoHang (
    MaLoHang INT PRIMARY KEY,
    MaHopDong INT,
    NgayNhap DATE,
    SoLuongNhap INT,
    TongGiaTri DECIMAL(14,2),
    NgaySX DATE,
    HSD DATE,
    TinhTrang VARCHAR(30),
    GhiChu VARCHAR(255),
    CONSTRAINT FK_LoHang_HopDong FOREIGN KEY (MaHopDong) REFERENCES HopDong(MaHopDong)
);
GO

-- 12. HÀNG HÓA (tham chiếu LoaiHang)
CREATE TABLE HangHoa (
    MaHH INT PRIMARY KEY,
    TenHangHoa VARCHAR(100),
    MaLoaiHang INT,
    GiaBan DECIMAL(12,2),
    SoLuong INT,
    NgaySX DATE,
    HSD DATE,
    CONSTRAINT FK_HangHoa_LoaiHang FOREIGN KEY (MaLoaiHang) REFERENCES LoaiHang(MaLoaiHang)
);
GO

-- 13. PHIẾU NHẬP (tham chiếu NhanVien, NhaCungCap)
CREATE TABLE PhieuNhap (
    MaPhieuNhap INT PRIMARY KEY,
    NgayNhap DATE,
    MaNhanVien INT,
    MaNhaCungCap INT,
    TongGiaTri DECIMAL(14,2),
    CONSTRAINT FK_PhieuNhap_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT FK_PhieuNhap_NhaCungCap FOREIGN KEY (MaNhaCungCap) REFERENCES NhaCungCap(MaNhaCungCap)
);
GO

-- 14. CHI TIẾT PHIẾU NHẬP (tham chiếu PhieuNhap, HangHoa)
CREATE TABLE ChiTietPhieuNhap (
    MaPhieuNhap INT,
    MaHH INT,
    SoLuongNhap INT,
    DonGiaNhap DECIMAL(12,2),
    PRIMARY KEY (MaPhieuNhap, MaHH),
    CONSTRAINT FK_CTPN_PhieuNhap FOREIGN KEY (MaPhieuNhap) REFERENCES PhieuNhap(MaPhieuNhap),
    CONSTRAINT FK_CTPN_HangHoa FOREIGN KEY (MaHH) REFERENCES HangHoa(MaHH)
);
GO

-- 15. PHIẾU XUẤT (tham chiếu NhanVien)
CREATE TABLE PhieuXuat (
    MaPhieuXuat INT PRIMARY KEY,
    NgayXuat DATE,
    MaNhanVien INT,
    MaKhachHang INT NULL, -- giữ cột MaKhachHang (có thể NULL nếu không ràng buộc)
    TongGiaTri DECIMAL(14,2),
    CONSTRAINT FK_PhieuXuat_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
    -- nếu muốn bắt buộc tham chiếu KhachHang, thêm FK tương ứng:
    -- , CONSTRAINT FK_PhieuXuat_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);
GO

-- 16. CHI TIẾT PHIẾU XUẤT (tham chiếu PhieuXuat, HangHoa)
CREATE TABLE ChiTietPhieuXuat (
    MaPhieuXuat INT,
    MaHH INT,
    SoLuongXuat INT,
    DonGiaXuat DECIMAL(12,2),
    PRIMARY KEY (MaPhieuXuat, MaHH),
    CONSTRAINT FK_CTPX_PhieuXuat FOREIGN KEY (MaPhieuXuat) REFERENCES PhieuXuat(MaPhieuXuat),
    CONSTRAINT FK_CTPX_HangHoa FOREIGN KEY (MaHH) REFERENCES HangHoa(MaHH)
);
GO

-- 17. KHÁCH HÀNG VIP
CREATE TABLE KhachHang_VIP (
    MaKhachHang INT PRIMARY KEY,
    MucGiamGia DECIMAL(5,2),
    CONSTRAINT FK_VIP_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);
GO

-- 18. KHÁCH HÀNG THÀNH VIÊN
CREATE TABLE KhachHang_ThanhVien (
    MaKhachHang INT PRIMARY KEY,
    NgayDangKy DATE,
    DiemTichLuy INT,
    LoaiThe VARCHAR(60),
    CONSTRAINT FK_ThanhVien_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);
GO

-- 19. PHẢN HỒI KHÁCH HÀNG
CREATE TABLE PhanHoi (
    MaPhanHoi INT PRIMARY KEY,
    MaKhachHang INT,
    DanhGiaSanPham VARCHAR(255),
    DongGop VARCHAR(255),
    CONSTRAINT FK_PhanHoi_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);
GO

-- 20. HÓA ĐƠN BÁN (tham chiếu NhanVien, KhachHang)
CREATE TABLE HoaDon (
    MaHoaDon INT PRIMARY KEY,
    NgayLapHoaDon DATE,
    NgayNhanHang DATE,
    MaNhanVien INT,
    MaKhachHang INT,
    CONSTRAINT FK_HoaDon_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien),
    CONSTRAINT FK_HoaDon_KhachHang FOREIGN KEY (MaKhachHang) REFERENCES KhachHang(MaKhachHang)
);
GO

-- 21. CHI TIẾT HÓA ĐƠN (tham chiếu HoaDon, HangHoa)
CREATE TABLE ChiTietHoaDon (
    MaHoaDon INT,
    MaHH INT,
    SoLuong INT,
    ThanhTien DECIMAL(12,2),
    PRIMARY KEY (MaHoaDon, MaHH),
    CONSTRAINT FK_CTHD_HoaDon FOREIGN KEY (MaHoaDon) REFERENCES HoaDon(MaHoaDon),
    CONSTRAINT FK_CTHD_HangHoa FOREIGN KEY (MaHH) REFERENCES HangHoa(MaHH)
);
GO

-- 22. PHIẾU CHI (tham chiếu NhanVien)
CREATE TABLE PhieuChi (
    MaPhieuChi INT PRIMARY KEY,
    NgayChi DATE,
    SoTien DECIMAL(12,2),
    LyDoChi VARCHAR(255),
    HinhThucThanhToan VARCHAR(30),
    GhiChu VARCHAR(255),
    MaNhanVien INT,
    TrangThai VARCHAR(30),
    SoToChungTu VARCHAR(50),
    CONSTRAINT FK_PhieuChi_NhanVien FOREIGN KEY (MaNhanVien) REFERENCES NhanVien(MaNhanVien)
);
GO
