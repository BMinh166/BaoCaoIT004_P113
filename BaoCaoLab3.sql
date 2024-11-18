--1. Hiển thị tên và cấp độ của tất cả các kỹ năng của chuyên gia có MaChuyenGia là 1, đồng thời lọc ra những kỹ năng có cấp độ thấp hơn 3.

SELECT TenKyNang, CapDo
FROM ChuyenGia_KyNang 
INNER JOIN KyNang ON ChuyenGia_KyNang.MaKyNang = KyNang.MaKyNang
WHERE MaChuyenGia = 1
		AND CapDo < 3

--2. Liệt kê tên các chuyên gia tham gia dự án có MaDuAn là 2 và có ít nhất 2 kỹ năng khác nhau.

SELECT HoTen
FROM ChuyenGia_DuAn
INNER JOIN ChuyenGia ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
WHERE MaDuAn = 2
GROUP BY HoTen
HAVING COUNT(MaKyNang) >=2

--3. Hiển thị tên công ty và tên dự án của tất cả các dự án, sắp xếp theo tên công ty và số lượng chuyên gia tham gia dự án.

SELECT TenCongTy, TenDuAn
FROM DuAn
INNER JOIN CongTy ON DuAn.MaCongTy = CongTy.MaCongTy
INNER JOIN ChuyenGia_DuAn ON DuAn.MaDuAn = ChuyenGia_DuAn.MaDuAn
GROUP BY TenCongTy,TenDuAn
ORDER BY TenCongTy ASC, COUNT(MaChuyenGia)

--4. Đếm số lượng chuyên gia trong mỗi chuyên ngành và hiển thị chỉ những chuyên ngành có hơn 5 chuyên gia.

SELECT ChuyenNganh, COUNT(MaChuyenGia) SCG
FROM ChuyenGia
GROUP BY ChuyenNganh
HAVING COUNT(MaChuyenGia) >5

--5. Tìm chuyên gia có số năm kinh nghiệm cao nhất và hiển thị cả danh sách kỹ năng của họ.

SELECT TOP 1 WITH TIES TenKyNang
FROM ChuyenGia
INNER JOIN ChuyenGia_KyNang ON ChuyenGia.MaChuyenGia = ChuyenGia_KyNang.MaChuyenGia
INNER JOIN KyNang ON KyNang.MaKyNang = ChuyenGia_KyNang.MaKyNang
ORDER BY NamKinhNghiem DESC

--6. Liệt kê tên các chuyên gia và số lượng dự án họ tham gia, đồng thời tính toán tỷ lệ phần trăm so với tổng số dự án trong hệ thống.

SELECT ChuyenGia.HoTen, 
       COUNT(ChuyenGia_DuAn.MaDuAn) AS SoLuongDuAn, 
       (COUNT(ChuyenGia_DuAn.MaDuAn) * 100.0 / (SELECT COUNT(*) FROM DuAn)) AS TiLePhanTram
FROM ChuyenGia
LEFT JOIN ChuyenGia_DuAn ON ChuyenGia.MaChuyenGia = ChuyenGia_DuAn.MaChuyenGia
GROUP BY ChuyenGia.HoTen
ORDER BY SoLuongDuAn DESC;


--7. Hiển thị tên công ty và số lượng dự án của mỗi công ty, bao gồm cả những công ty không có dự án nào.

SELECT TenCongTy, COUNT(MaDuAn) SLDA
FROM CongTy CT
LEFT OUTER JOIN DuAn DA ON CT.MaCongTy=DA.MaCongTy
GROUP BY TenCongTy

--8. Tìm kỹ năng được sở hữu bởi nhiều chuyên gia nhất, đồng thời hiển thị số lượng chuyên gia sở hữu kỹ năng đó.

SELECT TenKyNang, COUNT(CG.MaChuyenGia) SLCG
FROM KyNang KN
JOIN ChuyenGia_KyNang CGKN ON KN.MaKyNang=CGKN.MaKyNang
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGKN.MaChuyenGia
GROUP BY TenKyNang

--9. Liệt kê tên các chuyên gia có kỹ năng 'Python' với cấp độ từ 4 trở lên, đồng thời tìm kiếm những người cũng có kỹ năng 'Java'.

SELECT HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN KyNang KN ON CGKN.MaKyNang = KN.MaKyNang
WHERE TenKyNang = 'Python' AND CapDo >=4 
UNION
(SELECT HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN KyNang KN ON CGKN.MaKyNang = KN.MaKyNang
WHERE TenKyNang = 'Java')
--10. Tìm dự án có nhiều chuyên gia tham gia nhất và hiển thị danh sách tên các chuyên gia tham gia vào dự án đó.

SELECT TenDuAn,HoTen
FROM DuAn DA
JOIN ChuyenGia_DuAn CGDA ON DA.MaDuAn=CGDA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
WHERE DA.MaDuAn = (
					SELECT TOP 1 DuAn.MaDuAn
					FROM DuAn
					JOIN ChuyenGia_DuAn ON DuAn.MaDuAn=ChuyenGia_DuAn.MaDuAn
					GROUP BY DuAn.MaDuAn
					ORDER BY COUNT(ChuyenGia_DuAn.MaChuyenGia) DESC
					)

--11. Hiển thị tên và số lượng kỹ năng của mỗi chuyên gia, đồng thời lọc ra những người có ít nhất 5 kỹ năng.

SELECT HoTen, COUNT(CGKN.MaKyNang) SLKN
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
GROUP BY HoTen
HAVING COUNT(CGKN.MaKyNang)>=5

--12. Tìm các cặp chuyên gia làm việc cùng dự án và hiển thị thông tin về số năm kinh nghiệm của từng cặp.

SELECT CG1.HoTen, CG1.NamKinhNghiem, CG2.HoTen, CG2.NamKinhNghiem, CGDA_1.MaDuAn
FROM ChuyenGia_DuAn CGDA_1
JOIN ChuyenGia_DuAn CGDA_2 ON CGDA_1.MaDuAn = CGDA_2.MaDuAn AND CGDA_1.MaChuyenGia < CGDA_2.MaChuyenGia
JOIN ChuyenGia CG1 ON CG1.MaChuyenGia = CGDA_1.MaChuyenGia
JOIN ChuyenGia CG2 ON CG2.MaChuyenGia = CGDA_2.MaChuyenGia

--13. Liệt kê tên các chuyên gia và số lượng kỹ năng cấp độ 5 của họ, đồng thời tính toán tỷ lệ phần trăm so với tổng số kỹ năng mà họ sở hữu.

SELECT CG.HoTen, KNC5, (KNC5*100.0 / TSKN) TL
FROM ChuyenGia CG
JOIN	(
			SELECT CG.MaChuyenGia, COUNT(MaKyNang) KNC5
			FROM ChuyenGia CG
			JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
			GROUP BY CG.MaChuyenGia
			HAVING COUNT(MaKyNang)=5
		) KN5 ON KN5.MaChuyenGia = CG.MaChuyenGia
JOIN	(
			SELECT CG.MaChuyenGia, COUNT(*) TSKN
			FROM ChuyenGia CG
			JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
			GROUP BY CG.MaChuyenGia
		) TKN ON TKN.MaChuyenGia = CG.MaChuyenGia


--14. Tìm các công ty không có dự án nào và hiển thị cả thông tin về số lượng nhân viên trong mỗi công ty đó.

SELECT TenCongTy, SoNhanVien
FROM CongTy CT
LEFT OUTER JOIN DuAn DA ON CT.MaCongTy=DA.MaCongTy
WHERE MaDuAn=NULL

--15. Hiển thị tên chuyên gia và tên dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào, sắp xếp theo tên chuyên gia.

SELECT HoTen, TenDuAn
FROM ChuyenGia CG
LEFT OUTER JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia=CGDA.MaChuyenGia
LEFT OUTER JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn

--16. Tìm các chuyên gia có ít nhất 3 kỹ năng, đồng thời lọc ra những người không có bất kỳ kỹ năng nào ở cấp độ cao hơn 3.

SELECT HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
GROUP BY HoTen
HAVING COUNT(CGKN.MaKyNang) >= 3
EXCEPT
(SELECT HoTen
FROM ChuyenGia CG
JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia = CGKN.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
WHERE CapDo>3
)

--17. Hiển thị tên công ty và tổng số năm kinh nghiệm của tất cả chuyên gia trong các dự án của công ty đó, chỉ hiển thị những công ty có tổng số năm kinh nghiệm lớn hơn 10 năm.

SELECT TenCongTy, SUM(NamKinhNghiem) TNKN
FROM CongTy CT
JOIN DuAn DA ON CT.MaCongTy=DA.MaCongTy
JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DA.MaDuAn
JOIN ChuyenGia CG ON CG.MaChuyenGia =CGDA.MaChuyenGia
GROUP BY TenCongTy
HAVING SUM(NamKinhNghiem)>10

--18. Tìm các chuyên gia có kỹ năng 'Java' nhưng không có kỹ năng 'Python', đồng thời hiển thị danh sách các dự án mà họ đã tham gia.

SELECT HoTen, TenDuAn
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
WHERE TenKyNang = 'Java'
EXCEPT
(SELECT HoTen, TenDuAn
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON CG.MaChuyenGia = CGDA.MaChuyenGia
JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = CG.MaChuyenGia
JOIN KyNang KN ON KN.MaKyNang = CGKN.MaKyNang
WHERE TenKyNang = 'Python')

--19. Tìm chuyên gia có số lượng kỹ năng nhiều nhất và hiển thị cả danh sách các dự án mà họ đã tham gia.

SELECT TenDuAn
FROM ChuyenGia CG
JOIN ChuyenGia_DuAn CGDA ON  CG.MaChuyenGia=CGDA.MaChuyenGia
JOIN DuAn DA ON DA.MaDuAn = CGDA.MaDuAn
WHERE CG.MaChuyenGia = (
							SELECT TOP 1 CG.MaChuyenGia
							FROM ChuyenGia CG
							JOIN ChuyenGia_KyNang CGKN ON CG.MaChuyenGia=CGKN.MaChuyenGia
							GROUP BY CG.MaChuyenGia
							ORDER BY COUNT(MaKyNang) DESC
							)


--20. Liệt kê các cặp chuyên gia có cùng chuyên ngành và hiển thị thông tin về số năm kinh nghiệm của từng người trong cặp đó.

SELECT CG1.HoTen, CG1.NamKinhNghiem, CG2.HoTen, CG2.NamKinhNghiem
FROM ChuyenGia CG1
JOIN ChuyenGia CG2 ON CG1.ChuyenNganh=CG2.ChuyenNganh AND CG1.MaChuyenGia<CG2.MaChuyenGia

--21. Tìm công ty có tổng số năm kinh nghiệm của các chuyên gia trong dự án cao nhất và hiển thị danh sách tất cả các dự án mà công ty đó đã thực hiện.

SELECT TenCongTy,TenDuAn
FROM CongTy CT
JOIN DuAn DA ON DA.MaCongTy=CT.MaCongTy
WHERE CT.MaCongTy = (
						SELECT TOP 1 CT.MaCongTy
						FROM CongTy CT
						JOIN DuAn DA ON DA.MaCongTy = CT.MaCongTy
						JOIN ChuyenGia_DuAn CGDA ON CGDA.MaDuAn = DA.MaDuAn
						JOIN ChuyenGia CG ON CG.MaChuyenGia = CGDA.MaChuyenGia
						GROUP BY CT.MaCongTy
						ORDER BY SUM(NamKinhNghiem) DESC
					)

--22. Tìm kỹ năng được sở hữu bởi tất cả các chuyên gia và hiển thị danh sách chi tiết về từng chuyên gia sở hữu kỹ năng đó cùng với cấp độ của họ.

SELECT HoTen, CapDo
FROM KyNang KN
JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = KN.MaKyNang
JOIN ChuyenGia CG ON CG.MaChuyenGia = CGKN.MaChuyenGia
WHERE KN.MaKyNang IN	(
							SELECT KN.MaKyNang
							FROM KyNang KN
							JOIN ChuyenGia_KyNang CGKN ON CGKN.MaChuyenGia = KN.MaKyNang
							JOIN ChuyenGia CG ON CG.MaChuyenGia = CGKN.MaChuyenGia
							GROUP BY KN.MaKyNang
							HAVING COUNT(CG.MaChuyenGia) = (SELECT COUNT(*) FROM ChuyenGia)
						)
--1. Tìm các số hóa đơn đã mua sản phẩm có mã số “BB01” hoặc “BB02”, mỗi sản phẩm mua với số 
--lượng từ 10 đến 20, và tổng trị giá hóa đơn lớn hơn 500.000.

SELECT HD.SOHD
FROM CTHD
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
WHERE MASP = 'BB01' OR MASP = 'BB02'
		AND SL >=10 AND SL <=20 AND TRIGIA > 500000

--2.Tìm các số hóa đơn mua cùng lúc 3 sản phẩm có mã số “BB01”, “BB02” và “BB03”, mỗi sản 
--phẩm mua với số lượng từ 10 đến 20, và ngày mua hàng trong năm 2023

SELECT HD.SOHD
FROM CTHD 
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
WHERE MASP = 'BB01' 
		AND SL >=10 AND SL <=20
		AND YEAR(NGHD) = '2023'
INTERSECT
(
SELECT HD.SOHD
FROM CTHD 
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
WHERE MASP = 'BB02' 
		AND SL >=10 AND SL <=20
		AND YEAR(NGHD) = '2023'
)
INTERSECT
(
SELECT HD.SOHD
FROM CTHD 
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
WHERE MASP = 'BB03' 
		AND SL >=10 AND SL <=20
		AND YEAR(NGHD) = '2023'
)

--3. Tìm các khách hàng đã mua ít nhất một sản phẩm có mã số “BB01” với số lượng từ 10 đến 20, và 
--tổng trị giá tất cả các hóa đơn của họ lớn hơn hoặc bằng 1 triệu đồng

SELECT HOTEN
FROM CTHD
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
JOIN KHACHHANG KH ON KH.MAKH = HD.MAKH
WHERE MASP = 'BB01'
		AND SL >=10 AND SL <=20 AND TRIGIA >= 1000000

--4. Tìm các nhân viên bán hàng đã thực hiện giao dịch bán ít nhất một sản phẩm có mã số “BB01” 
--hoặc “BB02”, mỗi sản phẩm bán với số lượng từ 15 trở lên, và tổng trị giá của tất cả các hóa đơn mà 
--nhân viên đó xử lý lớn hơn hoặc bằng 2 triệu đồng.

SELECT DISTINCT HOTEN
FROM CTHD
JOIN HOADON HD ON HD.SOHD = CTHD.SOHD
JOIN NHANVIEN NV ON NV.MANV = HD.MANV
WHERE MASP = 'BB01' OR MASP = 'BB02'
		AND SL >=15 AND TRIGIA > 2000000

--5. Tìm các khách hàng đã mua ít nhất hai loại sản phẩm khác nhau với tổng số lượng từ tất cả các hóa 
--đơn của họ lớn hơn hoặc bằng 50 và tổng trị giá của họ lớn hơn hoặc bằng 5 triệu đồng.
SELECT HOTEN
FROM KHACHHANG KH
JOIN HOADON HD ON HD.MAKH = KH.MAKH
JOIN CTHD ON CTHD.SOHD = HD.SOHD
GROUP BY HOTEN
HAVING COUNT(DISTINCT MASP) >=2
		AND SUM(SL) >=50
		AND SUM(TRIGIA) >= 5000000

--6. Tìm những khách hàng đã mua cùng lúc ít nhất ba sản phẩm khác nhau trong cùng một hóa đơn và 
--mỗi sản phẩm đều có số lượng từ 5 trở lên.

SELECT DISTINCT HOTEN
FROM KHACHHANG KH
JOIN HOADON HD ON HD.MAKH = KH.MAKH
JOIN CTHD ON CTHD.SOHD = HD.SOHD
WHERE HD.SOHD IN (
					SELECT HD.SOHD
					FROM HOADON HD
					JOIN CTHD ON HD.SOHD = CTHD.SOHD
					GROUP BY HD.SOHD
					HAVING COUNT(DISTINCT MASP) >=3
					EXCEPT
					(
					SELECT SOHD
					FROM CTHD
					WHERE SL<5
					)
				)

--7. Tìm các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất và đã được bán ra ít nhất 5 lần 
--trong năm 2007

SELECT  SP.MASP, TENSP
FROM SANPHAM SP
JOIN CTHD ON CTHD.MASP = SP.MASP
WHERE NUOCSX = 'Trung Quoc'
GROUP BY SP.MASP, TENSP
HAVING COUNT(DISTINCT SOHD) >=5

--8. Tìm các khách hàng đã mua ít nhất một sản phẩm do “Singapore” sản xuất trong năm 2006 và tổng 
--trị giá hóa đơn của họ trong năm đó lớn hơn 1 triệu đồng.

SELECT HOTEN
FROM KHACHHANG KH
JOIN HOADON HD ON HD.MAKH = KH.MAKH
JOIN CTHD ON CTHD.SOHD = HD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
WHERE KH.MAKH IN	(
						SELECT KH.MAKH
						FROM KHACHHANG KH
						JOIN HOADON HD ON HD.MAKH = KH.MAKH
						JOIN CTHD ON CTHD.SOHD = HD.SOHD
						JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
						WHERE NUOCSX = 'Singapore'
							AND YEAR(NGHD) = '2006'
					)
		AND YEAR(NGHD) = '2006'
GROUP BY HOTEN
HAVING SUM(TRIGIA) > 1000000

--9. Tìm những nhân viên bán hàng đã thực hiện giao dịch bán nhiều nhất các sản phẩm do “Trung 
--Quoc” sản xuất trong năm 2006.

SELECT TOP 1 WITH TIES HOTEN
FROM NHANVIEN NV
JOIN HOADON HD ON HD.MANV = NV.MANV
JOIN CTHD ON CTHD.SOHD = HD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
WHERE NUOCSX = 'Trung Quoc' AND YEAR(NGHD) = '2006'
GROUP BY HOTEN
ORDER BY COUNT(HD.SOHD) DESC

--10. Tìm những khách hàng chưa từng mua bất kỳ sản phẩm nào do “Singapore” sản xuất nhưng đã 
--mua ít nhất một sản phẩm do “Trung Quoc” sản xuất.

SELECT HOTEN
FROM KHACHHANG KH
JOIN HOADON HD ON HD.MAKH = KH.MAKH
JOIN CTHD ON CTHD.SOHD = HD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
WHERE NUOCSX = 'Trung Quoc'
EXCEPT
(
SELECT HOTEN
FROM KHACHHANG KH
JOIN HOADON HD ON HD.MAKH = KH.MAKH
JOIN CTHD ON CTHD.SOHD = HD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
WHERE NUOCSX = 'Singapore'
)

--11. Tìm những hóa đơn có chứa tất cả các sản phẩm do “Singapore” sản xuất và trị giá hóa đơn lớn 
--hơn tổng trị giá trung bình của tất cả các hóa đơn trong hệ thống.

SELECT	HD.SOHD
FROM HOADON HD
JOIN CTHD ON HD.SOHD = CTHD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
GROUP BY HD.SOHD
HAVING (SELECT SUM(TRIGIA)*1.0/COUNT(*) FROM HOADON) < SUM(TRIGIA)

--12. Tìm danh sách các nhân viên có tổng số lượng bán ra của tất cả các loại sản phẩm vượt quá số 
--lượng trung bình của tất cả các nhân viên khác.
SELECT HOTEN
FROM NHANVIEN NV
JOIN HOADON HD ON HD.MANV = NV.MANV
JOIN CTHD ON CTHD.SOHD = HD.SOHD
JOIN	(
			SELECT NV.MANV ,SUM(SL) TONGSL
			FROM NHANVIEN NV
			JOIN HOADON HD ON HD.MANV = NV.MANV
			JOIN CTHD ON CTHD.SOHD = HD.SOHD
			GROUP BY NV.MANV
		) TONG ON TONG.MANV = NV.MANV
GROUP BY HOTEN
HAVING SUM(TONGSL) > AVG(TONGSL)

--13. Tìm danh sách các hóa đơn có chứa ít nhất một sản phẩm từ mỗi nước sản xuất khác nhau có 
--trong hệ thống.

SELECT HD.SOHD
FROM HOADON HD
JOIN CTHD ON CTHD.SOHD = HD.SOHD
JOIN SANPHAM SP ON SP.MASP = CTHD.MASP
GROUP BY HD.SOHD
HAVING COUNT(DISTINCT NUOCSX) = (SELECT COUNT(DISTINCT NUOCSX) FROM SANPHAM)
--1. Tìm danh sách các giáo viên có mức lương cao nhất trong mỗi khoa, kèm theo tên khoa và hệ 
--số lương.

SELECT HOTEN, KH.TENKHOA, MUCLUONG
FROM GIAOVIEN GV
JOIN KHOA KH ON KH.MAKHOA = GV.MAKHOA
JOIN 
(SELECT TENKHOA, MAX(MUCLUONG) LUONG
FROM GIAOVIEN GV
JOIN KHOA KH ON KH.MAKHOA = GV.MAKHOA
GROUP BY TENKHOA) GVLUONGCAONHAT ON MUCLUONG = LUONG AND GVLUONGCAONHAT.TENKHOA = KH.TENKHOA

--2. Liệt kê danh sách các học viên có điểm trung bình cao nhất trong mỗi lớp, kèm theo tên lớp và 
--mã lớp.

SELECT HO, TEN, DSDTB.DTB,TENLOP, LOP.MALOP
FROM HOCVIEN HV
JOIN LOP ON HV.MALOP = LOP.MALOP
JOIN	(
			SELECT LOP.MALOP, MAX(DTB) DTB
			FROM HOCVIEN HV
			JOIN LOP ON HV.MALOP = LOP.MALOP
			JOIN	(
						SELECT HV.MAHV, AVG(DIEM) DTB
						FROM HOCVIEN HV
						JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
						GROUP BY HV.MAHV
					) DSDTB ON DSDTB.MAHV = HV.MAHV
			GROUP BY LOP.MALOP
		) MAXDTB ON MAXDTB.MALOP = LOP.MALOP
JOIN	(
			SELECT HV.MAHV, AVG(DIEM) DTB
			FROM HOCVIEN HV
			JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
			GROUP BY HV.MAHV
		) DSDTB ON DSDTB.MAHV = HV.MAHV AND DSDTB.DTB = MAXDTB.DTB

--3. Tính tổng số tiết lý thuyết (TCLT) và thực hành (TCTH) mà mỗi giáo viên đã giảng dạy trong 
--năm học 2023, sắp xếp theo tổng số tiết từ cao xuống thấp.

SELECT HOTEN, (SUM(TCLT) + SUM(TCTH)) TONGTC
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
JOIN MONHOC MH ON MH.MAMH = GD.MAMH
WHERE YEAR(TUNGAY) = '2023' AND YEAR(DENNGAY)='2023'
GROUP BY HOTEN

--4. Tìm những học viên thi cùng một môn học nhiều hơn 2 lần nhưng chưa bao giờ đạt điểm trên 
--7, kèm theo mã học viên và mã môn học.

SELECT HO, TEN ,HV.MAHV, MAMH
FROM HOCVIEN HV
JOIN KETQUATHI KQT ON KQT.MAHV = HV.MAHV
WHERE LANTHI>2
EXCEPT
(
	SELECT HO, TEN ,HV.MAHV, MAMH
	FROM HOCVIEN HV
	JOIN KETQUATHI KQT ON KQT.MAHV = HV.MAHV
	WHERE LANTHI>2 AND DIEM >7
)

--5. Xác định những giáo viên đã giảng dạy ít nhất 3 môn học khác nhau trong cùng một năm học,
--kèm theo năm học và số lượng môn giảng dạy.

SELECT HOTEN, YEAR(TUNGAY) NAM, COUNT(MAMH) SOMH
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
WHERE YEAR(TUNGAY)=YEAR(DENNGAY)
GROUP BY YEAR(TUNGAY), HOTEN
HAVING COUNT(MAMH)>=3

--6. Tìm những học viên có sinh nhật trùng với ngày thành lập của khoa mà họ đang theo học, kèm
--theo tên khoa và ngày sinh của học viên.

SELECT HO, TEN, TENKHOA, NGSINH
FROM HOCVIEN HV
JOIN LOP L ON L.MALOP = HV.MALOP
JOIN GIANGDAY GD ON GD.MALOP = L.MALOP
JOIN MONHOC MH ON MH.MAMH = GD.MAMH
JOIN KHOA K ON K.MAKHOA = MH.MAKHOA
WHERE NGSINH = NGTLAP

--7. Liệt kê các môn học không có điều kiện tiên quyết (không yêu cầu môn học trước), kèm theo
--mã môn và tên môn học.

SELECT MH.MAMH, TENMH
FROM MONHOC MH
LEFT OUTER JOIN DIEUKIEN DK ON DK.MAMH = MH.MAMH
WHERE MAMH_TRUOC IS NULL

--8. Tìm danh sách các giáo viên dạy nhiều môn học nhất trong học kỳ 1 năm 2006, kèm theo số
--lượng môn học mà họ đã dạy

SELECT TOP 1 HOTEN, COUNT(MAMH) SLMH
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
WHERE NAM = 2006 AND HOCKY = 1
GROUP BY HOTEN
ORDER BY COUNT(MAMH) DESC

--9. Tìm những giáo viên đã dạy cả môn “Co So Du Lieu” và “Cau Truc Roi Rac” trong cùng một
--học kỳ, kèm theo học kỳ và năm học.

SELECT HOTEN, HOCKY, NAM
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
JOIN MONHOC MH ON MH.MAMH = GD.MAMH
WHERE MH.TENMH = 'Co So Du Lieu'
INTERSECT
(
SELECT HOTEN, HOCKY, NAM
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
JOIN MONHOC MH ON MH.MAMH = GD.MAMH
WHERE MH.TENMH = 'Cau Truc Roi Rac'
)

--10. Liệt kê danh sách các môn học mà tất cả các giáo viên trong khoa “CNTT” đều đã giảng dạy ít
--nhất một lần trong năm 2006.

SELECT TENMH
FROM MONHOC MH
JOIN GIANGDAY GD ON GD.MAMH = MH.MAMH
WHERE NAM = 2006
GROUP BY TENMH
HAVING COUNT(MAGV) = (SELECT COUNT(*) FROM GIAOVIEN)

--11. Tìm những giáo viên có hệ số lương cao hơn mức lương trung bình của tất cả giáo viên trong
--khoa của họ, kèm theo tên khoa và hệ số lương của giáo viên đó

SELECT HOTEN, TENKHOA, HESO
FROM GIAOVIEN GV
JOIN KHOA K ON K.MAKHOA = GV.MAKHOA
WHERE MAGV IN	(
					SELECT MAGV
					FROM GIAOVIEN GV
					JOIN KHOA K ON K.MAKHOA = GV.MAKHOA
					JOIN	(
								SELECT K.MAKHOA, AVG(MUCLUONG) LTB
								FROM GIAOVIEN GV
								JOIN KHOA K ON K.MAKHOA = GV.MAKHOA
								GROUP BY K.MAKHOA
							) LUONGTBK ON LUONGTBK.MAKHOA = K.MAKHOA
					WHERE MUCLUONG > LTB
				)

--12. Xác định những lớp có sĩ số lớn hơn 40 nhưng không có giáo viên nào dạy quá 2 môn trong
--học kỳ 1 năm 2006, kèm theo tên lớp và sĩ số.

SELECT L.MALOP, TENLOP, SISO
FROM LOP L
JOIN GIANGDAY GD ON GD.MALOP = L.MALOP
WHERE MAGV IN	(
					SELECT MAGV
					FROM GIANGDAY GD
					WHERE HOCKY = 1 AND NAM =2006
					GROUP BY MAGV
					HAVING COUNT(MAMH)<=2
				)
		AND SISO>40

--13. Tìm những môn học mà tất cả các học viên của lớp “K11” đều đạt điểm trên 7 trong lần thi
--cuối cùng của họ, kèm theo mã môn và tên môn học.

SELECT MH.MAMH, TENMH
FROM HOCVIEN HV
JOIN LOP L ON L.MALOP = HV.MALOP
JOIN KETQUATHI KQT ON KQT.MAHV = HV.MAHV
JOIN MONHOC MH ON MH.MAMH = KQT.MAMH
WHERE SISO =	(
					SELECT COUNT(DISTINCT MAHV)
					FROM KETQUATHI 
					WHERE DIEM>7
				)
		AND TENLOP = 'K11'

--14. Liệt kê danh sách các giáo viên đã dạy ít nhất một môn học trong mỗi học kỳ của năm 2006,
--kèm theo mã giáo viên và số lượng học kỳ mà họ đã giảng dạy

SELECT GV.MAGV, HOTEN, COUNT(DISTINCT HOCKY) SLHK
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
WHERE NAM = 2006 AND GV.MAGV IN (
									SELECT GV.MAGV
									FROM GIAOVIEN GV
									JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
									GROUP BY GV.MAGV
									HAVING COUNT(DISTINCT HOCKY) = (SELECT MAX(HOCKY) FROM GIANGDAY)
								)
GROUP BY GV.MAGV, HOTEN

--15. Tìm những giáo viên vừa là trưởng khoa vừa giảng dạy ít nhất 2 môn khác nhau trong năm
--2006, kèm theo tên khoa và mã giáo viên.

SELECT MAGV, HOTEN, TENKHOA
FROM GIAOVIEN GV
JOIN KHOA K ON K.MAKHOA = GV.MAKHOA
WHERE MAGV = TRGKHOA AND MAGV IN	(
										SELECT GV.MAGV
										FROM GIAOVIEN GV
										JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
										WHERE NAM = 2006
										GROUP BY GV.MAGV
										HAVING COUNT(DISTINCT MAMH) >=2
									)

--16. Xác định những môn học mà tất cả các lớp do giáo viên chủ nhiệm “Nguyen To Lan” đều phải
--học trong năm 2006, kèm theo mã lớp và tên lớp

SELECT DISTINCT MH.MAMH, TENMH, L.MALOP, TENLOP
FROM LOP L
JOIN GIANGDAY GD ON GD.MALOP = L.MALOP
JOIN GIAOVIEN GV ON GV.MAGV = L.MAGVCN
JOIN MONHOC MH ON MH.MAMH = GD.MAMH
WHERE HOTEN = 'Nguyen To Lan' AND NAM =2006

--17. Liệt kê danh sách các môn học mà không có điều kiện tiên quyết (không cần phải học trước
--bất kỳ môn nào), nhưng lại là điều kiện tiên quyết cho ít nhất 2 môn khác nhau, kèm theo mã môn và
--tên môn học.

SELECT MH.MAMH, TENMH
FROM MONHOC MH
LEFT OUTER JOIN DIEUKIEN DK ON MH.MAMH = DK.MAMH
WHERE MAMH_TRUOC IS NULL AND MH.MAMH IN (
											SELECT MH.MAMH
											FROM MONHOC MH
											JOIN DIEUKIEN DK ON MH.MAMH = DK.MAMH_TRUOC
											GROUP BY MH.MAMH
											HAVING COUNT(DK.MAMH) >=2
										)

--18. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng
--chưa thi lại môn này và cũng chưa thi bất kỳ môn nào khác sau lần đó.

SELECT HV.MAHV, HO, TEN
FROM HOCVIEN HV
JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
WHERE LANTHI =1 AND MAMH = 'CSDL' AND KQUA = 'Khong Dat'
		AND HV.MAHV IN	(
							SELECT HV.MAHV
							FROM HOCVIEN HV
							JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
							JOIN	(
										SELECT MAHV, NGTHI NTCSDL
										FROM KETQUATHI
										WHERE MAMH = 'CSDL'
									) NGTHISCDL ON NGTHISCDL.MAHV = HV.MAHV
							GROUP BY HV.MAHV
							HAVING MAX(NGTHI) = MAX(NGTHISCDL.NTCSDL)
						)

--19. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào
--trong năm 2006, nhưng đã từng giảng dạy trước đó.

SELECT GV.MAGV, HOTEN
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
WHERE NAM = 2006 
		AND GV.MAGV IN (
							SELECT GV.MAGV
							FROM GIAOVIEN GV
							JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
							WHERE NAM < 2006
							GROUP BY GV.MAGV
							HAVING COUNT(MAMH) > 0
						)
GROUP BY GV.MAGV, HOTEN
HAVING COUNT(MAMH) = 0

--20. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào
--thuộc khoa giáo viên đó phụ trách trong năm 2006, nhưng đã từng giảng dạy các môn khác của khoa
--khác

SELECT GV.MAGV, HOTEN
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GV.MAGV = GD.MAGV
WHERE GV.MAGV NOT IN	(
							SELECT GV.MAGV
							FROM GIAOVIEN GV
							JOIN KHOA K ON K.MAKHOA = GV.MAKHOA
							JOIN MONHOC MH ON MH.MAKHOA = K.MAKHOA
							LEFT OUTER JOIN GIANGDAY GD ON GD.MAMH = MH.MAMH AND GD.MAGV = GV.MAGV
							WHERE NAM = 2006 
						)
GROUP BY GV.MAGV, HOTEN
HAVING COUNT(MAMH)>0

--21. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn "Khong dat",
--nhưng có điểm trung bình tất cả các môn khác trên 7.

SELECT HV.MAHV, HO, TEN, AVG(DIEM) DIEMTB
FROM HOCVIEN HV
JOIN LOP L ON L.MALOP = HV.MALOP
JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
JOIN	(
			SELECT HV.MAHV, MAMH MKD
			FROM HOCVIEN HV
			JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
			WHERE LANTHI>3 AND KQUA = 'Khong Dat'
		) MONKD ON MONKD.MAHV = HV.MAHV
WHERE TENLOP = 'K11'
		AND KQT.MAMH != MONKD.MKD
GROUP BY HV.MAHV, HO, TEN
HAVING AVG(DIEM) > 7

--22. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn "Khong dat" và thi
--lần thứ 2 của môn CTRR đạt đúng 5 điểm, nhưng điểm trung bình của tất cả các môn khác đều dưới
--6.

SELECT HV.MAHV, HO, TEN, AVG(DIEM) DIEMTB
FROM HOCVIEN HV
JOIN LOP L ON L.MALOP = HV.MALOP
JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
JOIN	(
			SELECT HV.MAHV, MAMH MKD
			FROM HOCVIEN HV
			JOIN KETQUATHI KQT ON HV.MAHV = KQT.MAHV
			WHERE LANTHI>3 AND KQUA = 'Khong Dat'
		) MONKD ON MONKD.MAHV = HV.MAHV
WHERE TENLOP = 'K11'
		AND KQT.MAMH != MONKD.MKD AND KQT.MAMH != 'CTRR'
		AND HV.MAHV IN	(
							SELECT MAHV
							FROM KETQUATHI
							WHERE MAMH = 'CTRR' AND DIEM =5
						)
GROUP BY HV.MAHV, HO, TEN
HAVING AVG(DIEM) < 6

--23. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm
--học và có tổng số tiết giảng dạy (TCLT + TCTH) lớn hơn 30 tiết.

SELECT HOTEN, (TCLT + TCTH) TONGTC
FROM GIAOVIEN GV
JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
JOIN MONHOC MH ON MH.MAMH = GD.MAMH
JOIN	(
			SELECT GV.MAGV, MALOP, HOCKY, NAM
			FROM GIAOVIEN GV
			JOIN GIANGDAY GD ON GD.MAGV = GV.MAGV
			JOIN MONHOC MH ON MH.MAMH = GD.MAMH
			WHERE MH.MAMH = 'CTRR'
		) A ON A.MAGV = GV.MAGV AND A.MALOP != GD.MALOP AND A.HOCKY = GD.HOCKY AND A.NAM = GD.NAM
WHERE (TCLT + TCTH) > 30

--24. Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng), kèm theo số
--lần thi của mỗi học viên cho môn này.

SELECT MAHV, DIEM, MAX(LANTHI) LANTHI
FROM KETQUATHI
WHERE MAMH = 'CSDL'
GROUP BY MAHV, DIEM

--25. Danh sách học viên và điểm trung bình tất cả các môn (chỉ lấy điểm của lần thi sau cùng), kèm
--theo số lần thi trung bình cho tất cả các môn mà mỗi học viên đã tham gia.

SELECT KQT.MAHV, MAMH, MAX(LANTHI) LANTHI, AVG(LANTHI) LTTB, AVG(DIEM) DTB
FROM KETQUATHI KQT
JOIN (SELECT MAHV, MAX(LANTHI) LTCUOI FROM KETQUATHI GROUP BY MAHV) LTSC ON LTSC.MAHV = KQT.MAHV AND LTSC.LTCUOI = KQT.LANTHI
GROUP BY KQT.MAHV, MAMH
