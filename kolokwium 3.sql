--Gr. AN-14:15a
--Data: 2016-05-04
--Imie: Anatol
--Nazwisko: Karlinski
--Semestr: 2

--1. Dana jest tabela klient(id_klient,imie, wiek, plec).
--Napisaæ funkcjê posiadaj¹c¹ jeden parametr p_wiek i zwracajac¹ iloœæ klientow
--mlodszych niz wartosc p_wiek z tabeli klient.
--(wartosc kolumny id_klient ma byc nadawana automatycznie)
--(wartosc kolumny plec ma byc niepusta)
--(imie ciag od 3 do 20 znakow)
--Etap 1: Utworz tabele klient i dodaj 7 przykladowych rekordow.
DROP TABLE klient
GO

CREATE TABLE klient (
id_klient INTEGER IDENTITY(1,1) PRIMARY KEY,
imie VARCHAR(30),
wiek INT,
plec VARCHAR(20)
);
GO

INSERT INTO klient(imie, wiek, plec) VALUES
('Aaa', 21, 'M'),
('Bbb', 22, 'K'),
('Ccc', 23, 'K'),
('Ddd', 32, 'M'),
('Eee', 12, 'K'),
('Fff', 23, 'K'),
('Ggg', 72, 'M');
GO

SELECT * FROM klient;

--Etap 2: Utworz funkcje.

DROP FUNCTION do_wieku;
GO

CREATE FUNCTION do_wieku(@p_wiek INT)
RETURNS INT
AS
	BEGIN
		DECLARE @count INT;
		SET @count = (SELECT COUNT(*) FROM klient WHERE @p_wiek>wiek);
		RETURN @count
	END
GO


--Etap 3: Udowodnij, ze utworzona funkcja dziala.

PRINT dbo.do_wieku(30);
GO

--2. Napisac procedure posiadajaca  parametry  
--:p_imie, p_wiek, p_plec.
--Procedura ma wstawiac do tabeli klient wiersz o wartosc zadanych przez parametry procedury

--Etap 1: Utworz procedure.

CREATE PROCEDURE dodaj_klij @p_imie VARCHAR(30), @p_wiek INT, @p_plec VARCHAR(20)
AS
BEGIN
	INSERT INTO klient(imie,wiek,plec) VALUES(@p_imie,@p_wiek,@p_plec);
END
GO
--Etap 2: Udowodnij, ze utworzona procedura dzia³a.


EXEC dbo.dodaj_klij 'Zzz', 40, 'M'
SELECT * FROM klient
GO
--3 Napisac wyzwalacz ktory nie pozwoli dodac klientów 
--maj¹cych wiêcej ni¿ 100 lat


--Etap 1: Utworz wyzwalacz.

DROP TRIGGER insert_klient;
GO

CREATE TRIGGER insert_klient ON klient
AFTER INSERT AS
	DECLARE @wiek INT
	SELECT @wiek=wiek FROM inserted;
	IF (SELECT COUNT(*) FROM klient WHERE @wiek>100)>1
		BEGIN
		RAISERROR('Nie mo¿na dodaæ klienta o wieku wiêkszym ni¿ 100 lat :( ',1,2)
		ROLLBACK
	END 
GO

--Etap 2: Udowodnij, ze utworzony wyzwalacz dziala.

INSERT INTO klient(imie, wiek, plec) VALUES
('Yyy', 101, 'M')

SELECT * FROM klient

