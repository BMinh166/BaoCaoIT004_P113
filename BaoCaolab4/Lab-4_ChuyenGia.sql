-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.

SELECT TOP 3 CG.MaChuyenGia, HoTen, COUNT(MaKyNang) SLKN
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY CG.MaChuyenGia, HoTen
ORDER BY COUNT(MaKyNang) DESC

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.

SELECT CG1.MaChuyenGia, CG1.HoTen, CG2.MaChuyenGia, CG2.HoTen
FROM ChuyenGia CG1
JOIN ChuyenGia CG2 ON  CG1.ChuyenNganh=CG2.ChuyenNganh AND CG1.MaChuyenGia<CG2.MaChuyenGia
WHERE ABS(CG1.NamKinhNghiem - CG2.NamKinhNghiem) <=2

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.

SELECT TenCongTy, TenDuAn, SUM(NamKinhNghiem) TSNKN
FROM CongTy CT
JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY TenCongTy, TenDuAn

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.

SELECT CG.MaChuyenGia, HoTen
FROM ChuyenGia CG
WHERE CG.MaChuyenGia IN	(
							SELECT CG.MaChuyenGia 
							FROM ChuyenGia CG
							JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
							JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
							WHERE CapDo = 5
							INTERSECT
							(
							SELECT CG.MaChuyenGia 
							FROM ChuyenGia CG
							JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
							JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
							WHERE CapDo > 3
							)
						)

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.

SELECT CG.MaChuyenGia, HoTen, DA.MaDuAn, TenDuAn
FROM ChuyenGia CG
LEFT OUTER JOIN ChuyenGia_DuAn CGDA ON CGDA.MaChuyenGia = CG.MaChuyenGia
LEFT OUTER JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.

SELECT CG.MaChuyenGia, HoTen, KN.MaKyNang, TenKyNang, CapDo
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
JOIN	(
			SELECT KN.MaKyNang, MAX(CapDo) CDCN
			FROM ChuyenGia_KyNang CGKN
			JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
			GROUP BY KN.MaKyNang
		) CAPDOCAONHAT ON CAPDOCAONHAT.MaKyNang = KN.MaKyNang AND CAPDOCAONHAT.CDCN = CapDo

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.

SELECT ChuyenNganh, (COUNT(MaChuyenGia)*1.0/(SELECT COUNT(*) FROM ChuyenGia))
FROM ChuyenGia CG
GROUP BY ChuyenNganh

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.

SELECT TOP 1 WITH TIES KN1.MaKyNang MAKN1, KN1.TenKyNang TENKN1, KN2.MaKyNang MAKN2, KN2.TenKyNang TENKN2, COUNT(CG.MaChuyenGia) SLXH
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN1 ON CGKN1.MaChuyenGia = CG.MaChuyenGia
JOIN KyNang KN1 ON KN1.MaKyNang = CGKN1.MaKyNang
JOIN ChuyenGia_KyNang CGKN2 ON CGKN2.MaChuyenGia =CG.MaChuyenGia
JOIN KyNang KN2 ON KN2.MaKyNang = CGKN2.MaKyNang AND KN2.MaKyNang>KN1.MaKyNang
GROUP BY KN1.MaKyNang, KN1.TenKyNang, KN2.MaKyNang, KN2.TenKyNang
ORDER BY COUNT(CG.MaChuyenGia) DESC

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.

SELECT CT.MaCongTy, TenCongTy, AVG(TSN) SoNgayTB
FROM CongTy CT
JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
JOIN	(
			SELECT MaDuAn, DATEDIFF(DAY,NgayBatDau,NgayKetThuc) TSN
			FROM DuAn
		) TONGSONGAY ON TONGSONGAY.MaDuAn = DA.MaDuAn
GROUP BY CT.MaCongTy, CT.TenCongTy

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).

 SELECT TOP 1 WITH TIES CG.MaChuyenGia, HoTen
 FROM ChuyenGia CG
 JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
 JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
 JOIN	(
			SELECT TOP 1 WITH TIES KN.MaKyNang
			FROM KyNang KN
			JOIN ChuyenGia_KyNang CGKN ON CGKN.MaKyNang = KN.MaKyNang
			JOIN ChuyenGia CG ON CG.MaChuyenGia = CGKN.MaChuyenGia
			GROUP BY KN.MaKyNang
			ORDER BY COUNT(CG.MaChuyenGia) ASC
		) KNDD ON KNDD.MaKyNang = KN.MaKyNang
GROUP BY CG.MaChuyenGia, HoTen
ORDER BY COUNT(KN.MaKyNang) DESC

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.

SELECT CG.MaChuyenGia, HoTen, COUNT(DA.MaDuAn) TongSoDuAn, SUM(CapDo) TongCapDoKyNang
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaChuyenGia = CG.MaChuyenGia
JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
GROUP BY CG.MaChuyenGia, HoTen
ORDER BY COUNT(DA.MaDuAn) DESC, COUNT(CapDo) DESC


-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.

SELECT DA.MaDuAn, TenDuAn
FROM DuAn DA
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
GROUP BY DA.MaDuAn, TenDuAn
HAVING COUNT(ChuyenNganh) = (SELECT COUNT(ChuyenNganh) FROM ChuyenGia )

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.

SELECT CT.MaCongTy, TenCongTy, (DuAnHoanThanh * 1.0 / TongDuAn) TyLeThanhCong
FROM CongTy CT
JOIN	(
			SELECT CT.MaCongTy, COUNT(MaDuAn) TongDuAn
			FROM CongTy CT
			JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
			GROUP BY CT.MaCongTy
		) TONGDA ON TONGDA.MaCongTy = CT.MaCongTy
LEFT OUTER JOIN	(
			SELECT CT.MaCongTy, COUNT(MaDuAn) DuAnHoanThanh
			FROM CongTy CT
			JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
			WHERE TrangThai = 'hoàn thành'
			GROUP BY CT.MaCongTy
		) DAHT ON DAHT.MaCongTy = CT.MaCongTy


-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT 
    cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2,
    kn1.TenKyNang AS KyNang1, cgk1.CapDo AS CapDo1_ChuyenGia1, cgk2.CapDo AS CapDo1_ChuyenGia2,
    kn2.TenKyNang AS KyNang2, cgk3.CapDo AS CapDo2_ChuyenGia1, cgk4.CapDo AS CapDo2_ChuyenGia2
FROM 
    ChuyenGia_KyNang cgk1
JOIN ChuyenGia cg1 ON cgk1.MaChuyenGia = cg1.MaChuyenGia
JOIN KyNang kn1 ON cgk1.MaKyNang = kn1.MaKyNang
JOIN ChuyenGia_KyNang cgk2 ON cgk1.MaKyNang = cgk2.MaKyNang AND cgk1.MaChuyenGia <> cgk2.MaChuyenGia
JOIN ChuyenGia cg2 ON cgk2.MaChuyenGia = cg2.MaChuyenGia
JOIN ChuyenGia_KyNang cgk3 ON cgk1.MaChuyenGia = cgk3.MaChuyenGia AND cgk3.MaKyNang = 3
JOIN ChuyenGia_KyNang cgk4 ON cgk2.MaChuyenGia = cgk4.MaChuyenGia AND cgk4.MaKyNang = 3
JOIN KyNang kn2 ON cgk3.MaKyNang = kn2.MaKyNang
WHERE 
    kn1.MaKyNang = 2
    AND ((cgk1.CapDo > cgk2.CapDo AND cgk3.CapDo < cgk4.CapDo)
    OR (cgk1.CapDo < cgk2.CapDo AND cgk3.CapDo > cgk4.CapDo));

