--- ZAD 10.1 ---
 SELECT imie, nazwisko, pensja, dodatek, pensja+COALESCE(dodatek,0) AS do_zaplaty  FROM pracownik; 
 
--- ZAD 10.2 ---
 SELECT imie, nazwisko, pensja, dodatek, (pensja+COALESCE(dodatek,0))*1.5 AS nowa_pensja  FROM pracownik;   
--- ZAD 11.1 ---
SELECT TOP 1 imie, nazwisko 
FROM pracownik 
ORDER BY data_zatr ASC; 

--- ZAD 11.2 ---
SELECT TOP 4 nazwisko, imie  
FROM pracownik 
ORDER BY nazwisko ASC; 

--- ZAD 11.3 ---
SELECT TOP 1 wypozyczenie.id_samochod, samochod.id_samochod, samochod.marka, wypozyczenie.data_wyp
FROM wypozyczenie
INNER JOIN samochod
ON wypozyczenie.id_samochod=samochod.id_samochod
ORDER BY data_wyp ASC

--- ZAD 12.1 ---
SELECT imie, nazwisko, data_zatr
FROM pracownik
WHERE MONTH(data_zatr)=1
ORDER BY nazwisko ASC, imie ASC; --- ZAD 12.2 ---
SELECT imie, nazwisko, DATEDIFF(DAY, data_zatr, GETDATE ( )) AS Dni_od_zatrudnienia
FROM pracownik
ORDER BY Dni_od_zatrudnienia DESC;--- ZAD 12.3 ---
SELECT marka, typ, DATEDIFF(YEAR, data_prod, GETDATE ( )) AS Lat_od_produkcji
FROM samochod
ORDER BY Lat_od_produkcji DESC;--- ZAD 13.1 ---SELECT imie, nazwisko, LEFT(imie,1)+'. '+LEFT(nazwisko,1)+'.' AS inicjaly
FROM klient ORDER BY inicjaly, nazwisko, imie; --- ZAD 13.2 ---SELECT UPPER(SUBSTRING(imie, 1, 1)) + LOWER(SUBSTRING(imie, 2, len(imie))) as imie, UPPER(SUBSTRING(nazwisko, 1, 1)) + LOWER(SUBSTRING(nazwisko, 2, len(nazwisko))) as nazwisko
FROM klient

--- ZAD 13.3 ---SELECT imie, nazwisko, STUFF (nr_karty_kredyt, 6, 6, 'XXXXXX')
FROM klient

--- ZAD 14.1 ---
UPDATE pracownik SET dodatek=50 WHERE dodatek IS NULL;

--- ZAD 14.2 ---
UPDATE klient SET imie='Jerzy', nazwisko='Nowak' WHERE id_klient=10;

--- ZAD 14.3 ---
UPDATE pracownik SET dodatek=(dodatek+100) WHERE dodatek < 1500;

--- ZAD 15.1 ---
DELETE FROM klient WHERE id_klient=17; 
--- ZAD 15.2 ---
DELETE FROM wypozyczenie WHERE id_klient=17; 

--- ZAD 15.3 ---
DELETE FROM samochod WHERE przebieg>60000; 

--- ZAD 16.1 ---
INSERT INTO klient (id_klient,imie,nazwisko,ulica,numer,kod,miasto,telefon)
VALUES(121,'Adam','Cichy','Korzenna','12','00-950','Warszawa','123-454-321'); 