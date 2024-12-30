-- Câu hỏi SQL từ cơ bản đến nâng cao, bao gồm trigger

-- Cơ bản:
--1. Liệt kê tất cả chuyên gia trong cơ sở dữ liệu.

SELECT *
FROM ChuyenGia

--2. Hiển thị tên và email của các chuyên gia nữ.

SELECT HoTen, Email
FROM ChuyenGia
WHERE GioiTinh = N'Nữ'

--3. Liệt kê các công ty có trên 100 nhân viên.

SELECT *
FROM CongTy
WHERE SoNhanVien > 100

--4. Hiển thị tên và ngày bắt đầu của các dự án trong năm 2023.

SELECT TenDuAn, NgayBatDau
FROM DuAn
WHERE YEAR(NgayBatDau) = 2023

--5

-- Trung cấp:
--6. Liệt kê tên chuyên gia và số lượng dự án họ tham gia.

SELECT HoTen, COUNT(CGDA.MaDuAn) SoLuongDuAn
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaChuyenGia = CG.MaChuyenGia
GROUP BY HoTen

--7. Tìm các dự án có sự tham gia của chuyên gia có kỹ năng 'Python' cấp độ 4 trở lên.

SELECT *
FROM DuAn DA
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DA.MaDuAn
JOIN ChuyenGia_KyNang CGKN ON CGDA.MaChuyenGia = CGKN.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
WHERE TenKyNang = 'Python' AND CapDo >= 4

--8. Hiển thị tên công ty và số lượng dự án đang thực hiện.

SELECT TenCongTy, COUNT(MaDuAn) SoLuongDuAn
FROM CongTy CT
JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
GROUP BY TenCongTy

--9. Tìm chuyên gia có số năm kinh nghiệm cao nhất trong mỗi chuyên ngành.

SELECT *
FROM ChuyenGia CG
JOIN(
SELECT ChuyenNganh, MAX(NamKinhNghiem) NamKinhNghiem
FROM ChuyenGia CG
GROUP BY ChuyenNganh) MAXEXP ON MAXEXP.ChuyenNganh = CG.ChuyenNganh AND MAXEXP.NamKinhNghiem = CG.NamKinhNghiem

--10. Liệt kê các cặp chuyên gia đã từng làm việc cùng nhau trong ít nhất một dự án.

SELECT CG1.MaChuyenGia, CG1.HoTen, CG2.MaChuyenGia, CG2.HoTen
FROM ChuyenGia CG1
JOIN ChuyenGia_DuAn CGDA1 ON CGDA1.MaChuyenGia = CG1.MaChuyenGia
JOIN ChuyenGia_DuAn CGDA2 ON CGDA2.MaDuAn = CGDA1.MaDuAn AND CGDA1.MaChuyenGia<CGDA2.MaChuyenGia
JOIN ChuyenGia CG2 ON CG2.MaChuyenGia = CGDA2.MaChuyenGia

-- Nâng cao:
--11. Tính tổng thời gian (theo ngày) mà mỗi chuyên gia đã tham gia vào các dự án.

SELECT CG.MaChuyenGia, HoTen ,DATEDIFF(DAY, NgayThamGia, NgayKetThuc) TongThoiGian
FROM ChuyenGia_DuAn CGDA
JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia

--12. Tìm các công ty có tỷ lệ dự án hoàn thành cao nhất (trên 90%).

SELECT CT.MaCongTy, TenCongTy, (DuAnHoanThanh*100.0/TongDuAn) TyLeHoanThanh
FROM CongTy CT
JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
JOIN	(
			SELECT CT.MaCongTy, COUNT(MaDuAn) TongDuAn
			FROM CongTy CT
			JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
			GROUP BY CT.MaCongTy
		) TSDA ON TSDA.MaCongTy = CT.MaCongTy
JOIN	(
			SELECT CT.MaCongTy, COUNT(MaDuAn) DuAnHoanThanh
			FROM CongTy CT
			JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
			WHERE TrangThai = N'Hoàn thành'
			GROUP BY CT.MaCongTy
		) DAHT ON DAHT.MaCongTy = CT.MaCongTy


--13. Liệt kê top 3 kỹ năng được yêu cầu nhiều nhất trong các dự án.

SELECT TOP 3 KN.MaKyNang, TenKyNang, COUNT(KN.MaKyNang) SoLuongYeuCau
FROM DuAn DA
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DA.MaDuAn
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CGDA.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
GROUP BY KN.MaKyNang, TenKyNang
ORDER BY COUNT(KN.MaKyNang) DESC

--14. Tính lương trung bình của chuyên gia theo từng cấp độ kinh nghiệm (Junior: 0-2 năm, Middle: 3-5 năm, Senior: >5 năm).

SELECT 'Junior' CapDoKinhNghiem, AVG(MucLuong) MucLuongTrungBinh
FROM ChuyenGia
WHERE NamKinhNghiem IN (0, 1, 2)
UNION
(
SELECT 'Middle' CapDoKinhNghiem, AVG(MucLuong) MucLuongTrungBinh
FROM ChuyenGia
WHERE NamKinhNghiem IN (3, 4, 5)
)
UNION
(
SELECT 'Senior' CapDoKinhNghiem, AVG(MucLuong) MucLuongTrungBinh
FROM ChuyenGia
WHERE NamKinhNghiem > 5
)
--15. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.

SELECT DA.MaDuAn, TenDuAn
FROM DuAn DA
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY DA.MaDuAn, TenDuAn
HAVING COUNT(ChuyenNganh) = (SELECT COUNT(ChuyenNganh) FROM ChuyenGia)

-- Trigger:
--16. Tạo một trigger để tự động cập nhật số lượng dự án của công ty khi thêm hoặc xóa dự án.

CREATE TRIGGER trg_UpdateDuAn
ON CongTy
AFTER INSERT, DELETE
AS 
BEGIN
	IF EXISTS (SELECT 1 FROM inserted)
		UPDATE CongTy
		SET TongSoDuAn = TongSoDuAn + (SELECT COUNT(*) FROM inserted)
	IF EXISTS (SELECT 1 FROM deleted)
		UPDATE CongTy
		SET TongSoDuAn = TongSoDuAn - (SELECT COUNT(*) FROM inserted)
END;

--17. Tạo một trigger để ghi log mỗi khi có sự thay đổi trong bảng ChuyenGia.

CREATE TABLE ChuyenGia_Log(
	LogID INT PRIMARY KEY IDENTITY(1,1),
	MaChuyenGia INT,
	HoTen NVARCHAR,
	NgaySinh DATE,
	GioiTinh NVARCHAR,
	Email NVARCHAR,
	SoDienThoai NVARCHAR,
	NamKinhNghiem INT,
	LoaiThayDoi NVARCHAR,
	ThoiGianThayDoi DATETIME
);

CREATE TRIGGER trg_CGLog
ON ChuyenGia
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO ChuyenGia_Log( MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, NamKinhNghiem, LoaiThayDoi, ThoiGianThayDoi)
		SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, NamKinhNghiem, 'INSERT', GETDATE()
		FROM inserted
	END

	IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
	BEGIN
		INSERT INTO ChuyenGia_Log( MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, NamKinhNghiem, LoaiThayDoi, ThoiGianThayDoi)
		SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, NamKinhNghiem, 'DELETE', GETDATE()
		FROM deleted
	END

	IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
	BEGIN
		INSERT INTO ChuyenGia_Log( MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, NamKinhNghiem, LoaiThayDoi, ThoiGianThayDoi)
		SELECT MaChuyenGia, HoTen, NgaySinh, GioiTinh, Email, SoDienThoai, NamKinhNghiem, 'UPDATE', GETDATE()
		FROM inserted
	END

END;

--18. Tạo một trigger để đảm bảo rằng một chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc.

CREATE TRIGGER trg_CheckLimitProject
ON ChuyenGia_DuAn
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS	(
					SELECT CGDA.MaChuyenGia
					FROM ChuyenGia_DuAn CGDA
					JOIN inserted I ON I.MaChuyenGia = CGDA.MaChuyenGia
					GROUP BY CGDA.MaChuyenGia
					HAVING COUNT(CGDA.MaDuAn) > 5
				)
		BEGIN
			RAISERROR (N'Chuyên gia không thể tham gia vào quá 5 dự án cùng một lúc!',16,1)
			ROLLBACK TRANSACTION
		END
END;

--19. Tạo một trigger để tự động cập nhật trạng thái của dự án thành 'Hoàn thành' khi tất cả chuyên gia đã kết thúc công việc.

CREATE TRIGGER trg_KtrTrangThai
ON ChuyenGia_DuAn
AFTER UPDATE
AS
BEGIN
	IF EXISTS	(
					SELECT 1
					FROM ChuyenGia_DuAn CGDA
					JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
					WHERE CGDA.MaDuAn = (SELECT MaDuAn FROM inserted)
						AND CG.TrangThai = N'Kết thúc'
					HAVING COUNT(CGDA.MaChuyenGia) =	(
															SELECT COUNT(*)
															FROM ChuyenGia_DuAn CGDA
															WHERE CGDA.MaDuAn = (SELECT MaDuAn FROM inserted)
														)
				)
		BEGIN
			UPDATE DuAn
			SET TrangThai = N'Hoàn thành'
			WHERE MaDuAn = (SELECT MaDuAn FROM inserted)
		END
END;

--20. Tạo một trigger để tự động tính toán và cập nhật điểm đánh giá trung bình của công ty dựa trên điểm đánh giá của các dự án.

CREATE TRIGGER trg_UpdatePoint
ON DuAn
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted)
	BEGIN
	UPDATE CongTy
	SET DiemDanhGiaTrungBinh =	(
									SELECT AVG(DA.DiemDanhGia)
									FROM CongTy CT
									JOIN inserted I ON I.MaCongTy = CT.MaCongTy
									JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
								)
	WHERE MaCongTy = (SELECT MaCongTy FROM inserted)
	END

	IF EXISTS (SELECT 1 FROM deleted)
	BEGIN
	UPDATE CongTy
	SET DiemDanhGiaTrungBinh =	(
									SELECT AVG(DA.DiemDanhGia)
									FROM CongTy CT
									JOIN deleted I ON I.MaCongTy = CT.MaCongTy
									JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
								)
	WHERE MaCongTy = (SELECT MaCongTy FROM deleted)
	END

END;