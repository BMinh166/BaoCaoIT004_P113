﻿CREATE DATABASE QLDUOCPHAM

CREATE TABLE NHACUNGCAP(
	MANCC CHAR(5) PRIMARY KEY,
	TENNCC VARCHAR(50),
	QUOCGIA VARCHAR(30),
	LOAINCC VARCHAR(30)
);

CREATE TABLE DUOCPHAM(
	MADP CHAR(5) PRIMARY KEY,
	TENDP VARCHAR(50),
	LOAIDP VARCHAR(30),
	GIA MONEY
);

CREATE TABLE PHIEUNHAP(
	SOPN CHAR(6) PRIMARY KEY,
	NGNHAP DATETIME,
	MANCC CHAR(5),
	LOAINHAP VARCHAR(30),
	FOREIGN KEY (MANCC) REFERENCES NHACUNGCAP(MANCC)
);


CREATE TABLE CTPN(
	SOPN CHAR(6),
	MADP CHAR(5),
	SOLUONG INT,
	PRIMARY KEY(SOPN, MADP),
	FOREIGN KEY (SOPN) REFERENCES PHIEUNHAP(SOPN),
	FOREIGN KEY (MADP) REFERENCES DUOCPHAM(MADP)
);

--2. Nhập dữ liệu cho 4 table như đề bài

INSERT INTO NHACUNGCAP(MANCC, TENNCC, QUOCGIA, LOAINCC)
VALUES 
('NCC01','Phuc Hung','Viet Nam','Thuong xuyen'),
('NCC02','J. B. Pharmaceuticals','India','Vang lai'),
('NCC03','Sapharco','Singapore','Vang lai');

INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA) VALUES
('DP01', 'Thuoc ho PH', 'Siro', 120000),
('DP02', 'Zecuf Herbal CouchRemedy', 'Vien nen', 200000),
('DP03', 'Cotrim', 'Vien sui', 80000);

INSERT INTO PHIEUNHAP (SOPN, NGNHAP, MANCC, LOAINHAP) VALUES
('00001', '2017-11-22', 'NCC01', 'Noi dia'),
('00002', '2017-12-04', 'NCC03', 'Nhap khau'),
('00003', '2017-12-10', 'NCC02', 'Nhap khau');

INSERT INTO CTPN (SOPN, MADP, SOLUONG) VALUES
('00001', 'DP01', 100),
('00001', 'DP02', 200),
('00003', 'DP03', 543);


--3. Hiện thực ràng buộc toàn vẹn sau: Tất cả các dược phẩm có loại là Siro đều có giá lớn hơn 
--100.000đ

ALTER TABLE DUOCPHAM
ADD CONSTRAINT CHK_GiaSiro CHECK ((LOAIDP = 'Siro' AND GIA > 100000) OR (LOAIDP <> 'Siro'));

--4. Hiện thực ràng buộc toàn vẹn sau: Phiếu nhập của những nhà cung cấp ở những quốc gia
--khác Việt Nam đều có loại nhập là Nhập khẩu.

CREATE TRIGGER trg_CheckLoaiNhap
ON PHIEUNHAP
AFTER INSERT, UPDATE
AS
BEGIN
	IF EXISTS	(
					SELECT 1
					FROM inserted I
					JOIN NHACUNGCAP NCC ON NCC.MANCC = I.MANCC
					WHERE QUOCGIA <> 'Viet Nam' AND LOAINHAP <> 'Nhap khau'
				)
		BEGIN
			RAISERROR('Phiếu nhập của nhà cung cấp ở quốc gia khác Việt Nam phải có loại nhập là Nhập khẩu!', 16, 1)
			ROLLBACK TRANSACTION
		END
END;

--5. Tìm tất cả các phiếu nhập có ngày nhập trong tháng 12 năm 2017, sắp xếp kết quả tăng dần 
--theo ngày nhập

SELECT *
FROM PHIEUNHAP
WHERE MONTH(NGNHAP) = 12 AND YEAR(NGNHAP) =2017
ORDER BY NGNHAP ASC

--6. Tìm dược phẩm được nhập số lượng nhiều nhất trong năm 2017

SELECT TOP 1 WITH TIES DP.MADP, SUM(SOLUONG) TongSoLuong
FROM DUOCPHAM DP
JOIN CTPN ON CTPN.MADP = DP.MADP
JOIN PHIEUNHAP PN ON PN.SOPN = CTPN.SOPN
WHERE YEAR(NGNHAP) =2017
GROUP BY DP.MADP
ORDER BY SUM(SOLUONG)

--7. Tìm dược phẩm chỉ có nhà cung cấp thường xuyên (LOAINCC là Thuong xuyen) cung cấp, 
--nhà cung cấp vãng lai (LOAINCC là Vang lai) không cung cấp.

SELECT DP.MADP, TENDP
FROM DUOCPHAM DP
JOIN CTPN ON CTPN.MADP = DP.MADP
JOIN PHIEUNHAP PN ON PN.SOPN = CTPN.SOPN
JOIN NHACUNGCAP NCC ON NCC.MANCC = PN.MANCC
WHERE LOAINCC = 'Thuong xuyen'

EXCEPT

(
SELECT DP.MADP, TENDP
FROM DUOCPHAM DP
JOIN CTPN ON CTPN.MADP = DP.MADP
JOIN PHIEUNHAP PN ON PN.SOPN = CTPN.SOPN
JOIN NHACUNGCAP NCC ON NCC.MANCC = PN.MANCC
WHERE LOAINCC = 'Vang lai'
)

--8. Tìm nhà cung cấp đã từng cung cấp tất cả những dược phẩm có giá trên 100.000đ
--trong năm 2017

SELECT NCC.MANCC, TENNCC
FROM NHACUNGCAP NCC
JOIN PHIEUNHAP PN ON PN.MANCC = NCC.MANCC
JOIN CTPN ON CTPN.SOPN = PN.SOPN
JOIN DUOCPHAM DP ON DP.MADP = CTPN.MADP
WHERE NCC.MANCC IN	(
					SELECT NCC.MANCC
					FROM NHACUNGCAP NCC
					JOIN PHIEUNHAP PN ON PN.MANCC = NCC.MANCC
					JOIN CTPN ON CTPN.SOPN = PN.SOPN
					JOIN DUOCPHAM DP ON DP.MADP = CTPN.MADP
					WHERE GIA > 100000 AND YEAR(NGNHAP) =2017
				)
GROUP BY NCC.MANCC, TENNCC
HAVING COUNT(DP.MADP) =		(
								SELECT COUNT(*) 
								FROM DUOCPHAM DP
								JOIN CTPN ON CTPN.MADP = DP.MADP
								JOIN PHIEUNHAP PN ON PN.SOPN = CTPN.SOPN
								WHERE GIA >100000 AND YEAR(NGNHAP) =2017
							)
