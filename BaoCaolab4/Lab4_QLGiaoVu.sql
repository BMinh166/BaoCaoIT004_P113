--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất.

SELECT TOP 1 MAKHOA, TENKHOA 
FROM KHOA 
ORDER BY NGTLAP ASC;

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.

SELECT COUNT(*) AS SoLuongGiaoVien 
FROM GIAOVIEN 
WHERE HOCHAM IN ('GS', 'PGS');

--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi 
--khoa.

SELECT MAKHOA, HOCVI, COUNT(*) AS SoLuongGiaoVien 
FROM GIAOVIEN 
WHERE HOCVI IN ('CN', 'KS', 'Ths', 'TS', 'PTS') 
GROUP BY MAKHOA, HOCVI;

--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt).

SELECT MAMH, KQUA, COUNT(*) AS SoLuongHocVien 
FROM KETQUATHI 
GROUP BY MAMH, KQUA;

--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho 
--lớp đó ít nhất một môn học.

SELECT DISTINCT gv.MAGV, gv.HOTEN 
FROM GIAOVIEN gv 
JOIN LOP l ON gv.MAGV = l.MAGVCN 
JOIN GIANGDAY gd ON gv.MAGV = gd.MAGV AND l.MALOP = gd.MALOP;

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất.

SELECT hv.HO, hv.TEN 
FROM LOP l 
JOIN HOCVIEN hv ON l.TRGLOP = hv.MAHV 
WHERE SISO = (SELECT MAX(SISO) FROM LOP);

--25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả 
--các lần thi).

SELECT hv.HO, hv.TEN 
FROM HOCVIEN hv 
JOIN LOP l ON hv.MAHV = l.TRGLOP 
WHERE hv.MAHV IN (
    SELECT MAHV 
    FROM KETQUATHI 
    WHERE KQUA = 'Không đạt' 
    GROUP BY MAHV, MAMH 
    HAVING COUNT(DISTINCT MAMH) <= 3
);

--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.

SELECT TOP 1 hv.MAHV, hv.HO, hv.TEN, COUNT(*) AS SoMon 
FROM HOCVIEN hv 
JOIN KETQUATHI kq ON hv.MAHV = kq.MAHV 
WHERE DIEM IN (9, 10) 
GROUP BY hv.MAHV, hv.HO, hv.TEN 
ORDER BY SoMon DESC;

--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất.

SELECT lop.MALOP, hv.MAHV, hv.HO, hv.TEN, COUNT(*) AS SoMon 
FROM HOCVIEN hv 
JOIN KETQUATHI kq ON hv.MAHV = kq.MAHV 
JOIN LOP lop ON hv.MALOP = lop.MALOP 
WHERE DIEM IN (9, 10) 
GROUP BY lop.MALOP, hv.MAHV, hv.HO, hv.TEN 
HAVING COUNT(*) = (
    SELECT MAX(SoMon) 
    FROM (
        SELECT COUNT(*) AS SoMon 
        FROM KETQUATHI 
        JOIN HOCVIEN ON KETQUATHI.MAHV = HOCVIEN.MAHV 
        WHERE DIEM IN (9, 10) AND HOCVIEN.MALOP = lop.MALOP 
        GROUP BY HOCVIEN.MAHV
    ) AS MonTrongLop
);

--28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao 
--nhiêu lớp.

SELECT HOCKY, NAM, MAGV, COUNT(DISTINCT MAMH) AS SoMonHoc, COUNT(DISTINCT MALOP) AS SoLop 
FROM GIANGDAY 
GROUP BY HOCKY, NAM, MAGV;

--29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất.

SELECT gd.HOCKY, gd.NAM, gv.MAGV, gv.HOTEN, COUNT(*) AS SoBuoiDay 
FROM GIANGDAY gd 
JOIN GIAOVIEN gv ON gd.MAGV = gv.MAGV 
GROUP BY gd.HOCKY, gd.NAM, gv.MAGV, gv.HOTEN 
HAVING COUNT(*) = (
    SELECT MAX(SoBuoiDay) 
    FROM (
        SELECT HOCKY, NAM, MAGV, COUNT(*) AS SoBuoiDay 
        FROM GIANGDAY 
        GROUP BY HOCKY, NAM, MAGV
    ) AS TongBuoiDay
);

--30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) 
--nhất.

SELECT TOP 1 mh.MAMH, mh.TENMH, COUNT(*) AS SoLuong 
FROM MONHOC mh 
JOIN KETQUATHI kq ON mh.MAMH = kq.MAMH 
WHERE kq.LANTHI = 1 AND kq.KQUA = 'Không đạt' 
GROUP BY mh.MAMH, mh.TENMH 
ORDER BY SoLuong DESC;

--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1).

SELECT hv.MAHV, hv.HO, hv.TEN 
FROM HOCVIEN hv 
WHERE NOT EXISTS (
    SELECT 1 
    FROM KETQUATHI kq 
    WHERE hv.MAHV = kq.MAHV AND kq.LANTHI = 1 AND kq.KQUA = 'Không đạt'
);

--32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng).

SELECT hv.MAHV, hv.HO, hv.TEN 
FROM HOCVIEN hv 
WHERE NOT EXISTS (
    SELECT 1 
    FROM KETQUATHI kq1 
    WHERE hv.MAHV = kq1.MAHV AND kq1.KQUA = 'Không đạt' 
    AND kq1.LANTHI = (
        SELECT MAX(LANTHI) 
        FROM KETQUATHI kq2 
        WHERE kq1.MAHV = kq2.MAHV AND kq1.MAMH = kq2.MAMH
    )
);

--33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1).

SELECT hv.MAHV, hv.HO, hv.TEN 
FROM HOCVIEN hv 
WHERE NOT EXISTS (
    SELECT 1 
    FROM MONHOC mh 
    WHERE NOT EXISTS (
        SELECT 1 
        FROM KETQUATHI kq 
        WHERE hv.MAHV = kq.MAHV AND kq.MAMH = mh.MAMH AND kq.LANTHI = 1 AND kq.KQUA = 'Đạt'
    )
);

--34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau 
--cùng).

SELECT hv.MAHV, hv.HO, hv.TEN 
FROM HOCVIEN hv 
WHERE NOT EXISTS (
    SELECT 1 
    FROM MONHOC mh 
    WHERE NOT EXISTS (
        SELECT 1 
        FROM KETQUATHI kq1 
        WHERE hv.MAHV = kq1.MAHV AND kq1.MAMH = mh.MAMH AND kq1.KQUA = 'Đạt' 
        AND kq1.LANTHI = (
            SELECT MAX(LANTHI) 
            FROM KETQUATHI kq2 
            WHERE kq1.MAHV = kq2.MAHV AND kq1.MAMH = kq2.MAMH
        )
    )
);

--35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần 
--thi sau cùng).

SELECT hv.MAHV, hv.HO, hv.TEN, kq1.MAMH, MAX(kq1.DIEM) AS DiemCaoNhat 
FROM HOCVIEN hv 
JOIN KETQUATHI kq1 ON hv.MAHV = kq1.MAHV 
WHERE kq1.LANTHI = (
    SELECT MAX(LANTHI) 
    FROM KETQUATHI kq2 
    WHERE kq1.MAHV = kq2.MAHV AND kq1.MAMH = kq2.MAMH
)
GROUP BY hv.MAHV, hv.HO, hv.TEN, kq1.MAMH;
