-- Đề 1


CREATE TABLE TACGIA (
    MaTG CHAR(5) PRIMARY KEY,
    HoTen VARCHAR(20),
    DiaChi VARCHAR(50),
    NgSinh SMALLDATETIME,
    SoDT VARCHAR(15)
);

CREATE TABLE SACH (
    MaSach CHAR(5) PRIMARY KEY,
    TenSach VARCHAR(25),
    TheLoai VARCHAR(25)
);

CREATE TABLE TACGIA_SACH (
    MaTG CHAR(5),
    MaSach CHAR(5),
    PRIMARY KEY (MaTG, MaSach),
    FOREIGN KEY (MaTG) REFERENCES TACGIA(MaTG),
    FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)
);

-- Bảng PHATHANH
CREATE TABLE PHATHANH (
    MaPH CHAR(5) PRIMARY KEY,
    MaSach CHAR(5),
    NgayPH SMALLDATETIME,
    SoLuong INT,
    NhaXuatBan VARCHAR(20),
    FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)
);

CREATE TRIGGER trgCheckNgayPH
ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN TACGIA_SACH ts ON i.MaSach = ts.MaSach
        JOIN TACGIA t ON ts.MaTG = t.MaTG
        WHERE i.NgayPH <= t.NgSinh
    )
    BEGIN
        RAISERROR ('Ngay phat hanh phai lon hon ngay sinh cua tac gia.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

CREATE TRIGGER trgCheckTheLoai
ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN SACH s ON i.MaSach = s.MaSach
        WHERE s.TheLoai = 'Giáo khoa' AND i.NhaXuatBan <> 'Giáo dục'
    )
    BEGIN
        RAISERROR ('Sach thuoc the loai "Giao khoa" chi duoc phat hanh boi NXB "Giao duc".', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

SELECT DISTINCT tg.MaTG, tg.HoTen, tg.SoDT
FROM TACGIA tg
JOIN TACGIA_SACH tgs ON tg.MaTG = tgs.MaTG
JOIN SACH s ON tgs.MaSach = s.MaSach
JOIN PHATHANH ph ON s.MaSach = ph.MaSach
WHERE s.TheLoai = 'Văn học' AND ph.NhaXuatBan = 'Trẻ';

SELECT TOP 1 ph.NhaXuatBan, COUNT(DISTINCT s.TheLoai) AS SoTheLoai
FROM PHATHANH ph
JOIN SACH s ON ph.MaSach = s.MaSach
GROUP BY ph.NhaXuatBan
ORDER BY COUNT(DISTINCT s.TheLoai) DESC;

SELECT ph.NhaXuatBan, tg.MaTG, tg.HoTen
FROM PHATHANH ph
JOIN TACGIA_SACH tgs ON ph.MaSach = tgs.MaSach
JOIN TACGIA tg ON tgs.MaTG = tg.MaTG
GROUP BY ph.NhaXuatBan, tg.MaTG, tg.HoTen
HAVING COUNT(ph.MaPH) = (
    SELECT MAX(SoLanPhatHanh)
    FROM (
        SELECT COUNT(ph2.MaPH) AS SoLanPhatHanh
        FROM PHATHANH ph2
        JOIN TACGIA_SACH tgs2 ON ph2.MaSach = tgs2.MaSach
        JOIN TACGIA tg2 ON tgs2.MaTG = tg2.MaTG
        WHERE ph2.NhaXuatBan = ph.NhaXuatBan
        GROUP BY tg2.MaTG
    ) AS MaxPhatHanh
);


--Đề 2


CREATE TABLE PHONGBAN (
    MaPhong CHAR(5) PRIMARY KEY,
    TenPhong VARCHAR(25),
    TruongPhong CHAR(5)
);

CREATE TABLE NHANVIEN (
    MaNV CHAR(5) PRIMARY KEY,
    HoTen VARCHAR(20),
    NgayVL SMALLDATETIME,
    HSLuong NUMERIC(4,2),
    MaPhong CHAR(5),
    FOREIGN KEY (MaPhong) REFERENCES PHONGBAN(MaPhong)
);

ALTER TABLE PHONGBAN
ADD CONSTRAINT FK_TruongPhong FOREIGN KEY (TruongPhong) REFERENCES NHANVIEN(MaNV);

CREATE TABLE XE (
    MaXe CHAR(5) PRIMARY KEY,
    LoaiXe VARCHAR(20),
    SoChoNgoi INT,
    NamSX INT
);

CREATE TABLE PHANCONG (
    MaPC CHAR(5) PRIMARY KEY,
    MaNV CHAR(5),
    MaXe CHAR(5),
    NgayDi SMALLDATETIME,
    NgayVe SMALLDATETIME,
    NoiDen VARCHAR(25),
    FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV),
    FOREIGN KEY (MaXe) REFERENCES XE(MaXe)
);


CREATE TRIGGER trgCheckNamSX
ON XE
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LoaiXe = 'Toyota' AND NamSX < 2006
    )
    BEGIN
        RAISERROR ('Nam san xuat cua xe loai Toyota phai tu nam 2006 tro ve sau.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

CREATE TRIGGER trgCheckNgoaiThanh
ON PHANCONG
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN NHANVIEN nv ON i.MaNV = nv.MaNV
        JOIN XE x ON i.MaXe = x.MaXe
        JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
        WHERE pb.TenPhong = 'Ngoại thành' AND x.LoaiXe <> 'Toyota'
    )
    BEGIN
        RAISERROR ('Nhan vien thuoc phong lai xe "Ngoai thanh" chi duoc phan cong lai xe loai Toyota.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

SELECT DISTINCT nv.MaNV, nv.HoTen
FROM NHANVIEN nv
JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
JOIN PHANCONG pc ON nv.MaNV = pc.MaNV
JOIN XE x ON pc.MaXe = x.MaXe
WHERE pb.TenPhong = 'Nội thành' AND x.LoaiXe = 'Toyota' AND x.SoChoNgoi = 4;

SELECT nv.MaNV, nv.HoTen
FROM NHANVIEN nv
WHERE nv.MaNV IN (
    SELECT TruongPhong
    FROM PHONGBAN
) AND NOT EXISTS (
    SELECT x.LoaiXe
    FROM XE x
    WHERE NOT EXISTS (
        SELECT pc.MaXe
        FROM PHANCONG pc
        WHERE pc.MaNV = nv.MaNV AND pc.MaXe = x.MaXe
    )
);

SELECT pb.TenPhong, nv.MaNV, nv.HoTen
FROM NHANVIEN nv
JOIN PHONGBAN pb ON nv.MaPhong = pb.MaPhong
WHERE nv.MaNV IN (
    SELECT TOP 1 pc.MaNV
    FROM PHANCONG pc
    JOIN XE x ON pc.MaXe = x.MaXe
    WHERE x.LoaiXe = 'Toyota' AND pc.MaNV = nv.MaNV
    GROUP BY pc.MaNV
    ORDER BY COUNT(pc.MaXe) ASC
);


--Đề 3


CREATE TABLE DOCGIA (
    MaDG CHAR(5) PRIMARY KEY,
    HoTen VARCHAR(30),
    NgaySinh SMALLDATETIME,
    DiaChi VARCHAR(30),
    SoDT VARCHAR(15)
);

CREATE TABLE SACH (
    MaSach CHAR(5) PRIMARY KEY,
    TenSach VARCHAR(25),
    TheLoai VARCHAR(25),
    NhaXuatBan VARCHAR(30)
);

CREATE TABLE PHIEUTHUE (
    MaPM CHAR(5) PRIMARY KEY,
    MaDG CHAR(5),
    NgayThue SMALLDATETIME,
    NgayTra SMALLDATETIME,
    SoSachThue INT,
    FOREIGN KEY (MaDG) REFERENCES DOCGIA(MaDG)
);

CREATE TABLE CHITIET_PM (
    MaPM CHAR(5),
    MaSach CHAR(5),
    PRIMARY KEY (MaPM, MaSach),
    FOREIGN KEY (MaPM) REFERENCES PHIEUTHUE(MaPM),
    FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)
);

CREATE TRIGGER trgCheckThoiGianThue
ON PHIEUTHUE
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATEDIFF(day, NgayThue, NgayTra) > 10
    )
    BEGIN
        RAISERROR ('Thoi gian thue sach khong duoc vuot qua 10 ngay.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

CREATE TRIGGER trgCheckSoSachThue
ON CHITIET_PM
AFTER INSERT, DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM PHIEUTHUE pt
        JOIN (
            SELECT MaPM, COUNT(*) AS SoSachThueChiTiet
            FROM CHITIET_PM
            GROUP BY MaPM
        ) ctp ON pt.MaPM = ctp.MaPM
        WHERE pt.SoSachThue <> ctp.SoSachThueChiTiet
    )
    BEGIN
        RAISERROR ('So sach thue khong khop voi tong so lan thue trong chi tiet phieu thue.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

SELECT DISTINCT dg.MaDG, dg.HoTen
FROM DOCGIA dg
JOIN PHIEUTHUE pt ON dg.MaDG = pt.MaDG
JOIN CHITIET_PM ctp ON pt.MaPM = ctp.MaPM
JOIN SACH s ON ctp.MaSach = s.MaSach
WHERE s.TheLoai = 'Tin học' AND YEAR(pt.NgayThue) = 2007;

SELECT dg.MaDG, dg.HoTen
FROM DOCGIA dg
JOIN PHIEUTHUE pt ON dg.MaDG = pt.MaDG
JOIN CHITIET_PM ctp ON pt.MaPM = ctp.MaPM
JOIN SACH s ON ctp.MaSach = s.MaSach
GROUP BY dg.MaDG, dg.HoTen
ORDER BY COUNT(DISTINCT s.TheLoai) DESC

SELECT s.TheLoai, s.TenSach
FROM SACH s
JOIN CHITIET_PM ctp ON s.MaSach = ctp.MaSach
JOIN PHIEUTHUE pt ON ctp.MaPM = pt.MaPM
GROUP BY s.TheLoai, s.TenSach
HAVING COUNT(ctp.MaSach) = (
    SELECT MAX(SoLuongThue)
    FROM (
        SELECT COUNT(ctp2.MaSach) AS SoLuongThue
        FROM SACH s2
        JOIN CHITIET_PM ctp2 ON s2.MaSach = ctp2.MaSach
        WHERE s2.TheLoai = s.TheLoai
        GROUP BY s2.TenSach
    ) AS MaxThue
);


--Đề 4


CREATE TABLE KHACHHANG (
    MaKH CHAR(5) PRIMARY KEY,
    HoTen VARCHAR(30),
    DiaChi VARCHAR(30),
    SoDT VARCHAR(15),
    LoaiKH VARCHAR(10)
);

CREATE TABLE BANG_DIA (
    MaBD CHAR(5) PRIMARY KEY,
    TenBD VARCHAR(25),
    TheLoai VARCHAR(25),
    CONSTRAINT CHK_TheLoai CHECK (TheLoai IN ('ca nhạc', 'phim hành động', 'phim tình cảm', 'phim hoạt hình'))
);

CREATE TABLE PHIEUTHUE (
    MaPT CHAR(5) PRIMARY KEY,
    MaKH CHAR(5),
    NgayThue SMALLDATETIME,
    NgayTra SMALLDATETIME,
    Soluongthue INT,
    FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH)
);

CREATE TABLE CHITIET_PM (
    MaPT CHAR(5),
    MaBD CHAR(5),
    PRIMARY KEY (MaPT, MaBD),
    FOREIGN KEY (MaPT) REFERENCES PHIEUTHUE(MaPT),
    FOREIGN KEY (MaBD) REFERENCES BANG_DIA(MaBD)
);

CREATE TRIGGER trgCheckSoluongthue
ON PHIEUTHUE
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN KHACHHANG kh ON i.MaKH = kh.MaKH
        WHERE i.Soluongthue > 5 AND kh.LoaiKH <> 'VIP'
    )
    BEGIN
        RAISERROR ('Chi khach hang thuoc loai VIP moi duoc thue voi so luong bang dia tren 5.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;

SELECT DISTINCT kh.MaKH, kh.HoTen
FROM KHACHHANG kh
JOIN PHIEUTHUE pt ON kh.MaKH = pt.MaKH
JOIN CHITIET_PM ctp ON pt.MaPT = ctp.MaPT
JOIN BANG_DIA bd ON ctp.MaBD = bd.MaBD
WHERE bd.TheLoai = 'phim tình cảm' AND pt.Soluongthue > 3;

SELECT kh.MaKH, kh.HoTen
FROM KHACHHANG kh
JOIN PHIEUTHUE pt ON kh.MaKH = pt.MaKH
WHERE kh.LoaiKH = 'VIP'
GROUP BY kh.MaKH, kh.HoTen
ORDER BY SUM(pt.Soluongthue) DESC;

SELECT bd.TheLoai, kh.HoTen
FROM BANG_DIA bd
JOIN CHITIET_PM ctp ON bd.MaBD = ctp.MaBD
JOIN PHIEUTHUE pt ON ctp.MaPT = pt.MaPT
JOIN KHACHHANG kh ON pt.MaKH = kh.MaKH
GROUP BY bd.TheLoai, kh.HoTen
HAVING COUNT(ctp.MaBD) = (
    SELECT MAX(SoLuongThue)
    FROM (
        SELECT COUNT(ctp2.MaBD) AS SoLuongThue
        FROM BANG_DIA bd2
        JOIN CHITIET_PM ctp2 ON bd2.MaBD = ctp2.MaBD
        JOIN PHIEUTHUE pt2 ON ctp2.MaPT = pt2.MaPT
        JOIN KHACHHANG kh2 ON pt2.MaKH = kh2.MaKH
        WHERE bd2.TheLoai = bd.TheLoai
        GROUP BY kh2.HoTen
    ) AS MaxThue
);

