 DROP PROCEDURE wypisz_samochody;
CREATE PROCEDURE wypisz_samochody @marka VARCHAR(20)
AS
SELECT * FROM samochod WHERE marka=@marka;
GO
EXECUTE wypisz_samochody 'opel'; 


-- 33.3 --
DROP FUNCTION dbo.roznica_pensji;
CREATE FUNCTION dbo.roznica_pensji () RETURNS DECIMAL(8,2)
BEGIN
DECLARE @max DECIMAL(8,2), @min DECIMAL(8,2);
SET @max = (SELECT MAX(pensja) FROM pracownik);
SET @min = (SELECT MIN(pensja) FROM pracownik);
RETURN @max-@min
END;
GO
SELECT dbo.roznica_pensji() AS roznica_pensji;
GO

-- 32.2 --

CREATE PROCEDURE zwieksz_pensje @id_pracownik INT, @pensja DECIMAL(8,2)
AS
UPDATE Pracownik SET pensja=pensja+@pensja WHERE id_pracownik=@id_pracownik
GO
EXECUTE zwieksz_pensje 1, 1000; 

SELECT TOP 1 * FROM pracownik
GO
-- 32.3 --
DROP PROCEDURE dodaj_pracownika;
GO

CREATE PROCEDURE dodaj_pracownika @imie VARCHAR(15), @nazwisko VARCHAR(20), @data_zatr DATETIME, @dzial VARCHAR(20), @stanowisko VARCHAR(20), @pensja DECIMAL(8,2), @dodatek DECIMAL(8,2), @id_miejsce INT, @telefon VARCHAR(16)
AS
DECLARE @id_pracownik INT
SELECT @id_pracownik = MAX(id_pracownik) FROM Pracownik
SELECT @id_pracownik += 1
INSERT INTO Pracownik VALUES
(@id_pracownik, @imie, @nazwisko, @data_zatr, @dzial, @stanowisko, @pensja, @dodatek, @id_miejsce, @telefon)
GO

EXECUTE dodaj_pracownika 'AAAAAA!', 'YYYYYY!!!', '1997-05-01', 'ksiêgowoœæ', 'kasjer', 1400, 105, 1, '987-231-141'

SELECT * FROM Pracownik

-- 