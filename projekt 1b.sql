--Imię i nazwisko: Anatol Karlinski
--Numer indeksu: 224652
--Temat bazy danych: Kartel

--1a) Tworzymy widok 

-- Widok pokazuje dane osobowe całego personelu (czyli pracowników laboratorium i fabryk, managerów fabryk) w jednej tablicy
DROP VIEW personel_kartelu
GO

CREATE VIEW personel_kartelu AS
-- Pracownicy Labolatorium 
SELECT imie as Imię, nazwisko as Nazwisko, coalesce(pseudonim,'-') as Pseudonim, telefon as Telefon, email as Email, ('Pracownik labolatorium: ' + miasto + ', ul.' + ulica) as MiejscePracy FROM DaneOsobowe 
FULL JOIN Pracownik ON DaneOsobowe.idDaneOsobowe = Pracownik.idDaneOsobowe_FK
FULL JOIN Labolatorium ON Pracownik.idLabolatorium_FK = Labolatorium.idLabolatorium
LEFT JOIN Adres ON Labolatorium.idAdres_FK = Adres.idAdres
WHERE idLabolatorium_FK IS NOT NULL

UNION 

-- Pracownicy Fabryki 
SELECT imie as Imię, nazwisko as Nazwisko, coalesce(pseudonim,'-') as Pseudonim, telefon as Telefon, email as Email, ('Pracownik fabryki: ' + miasto + ', ul.' + ulica) as MiejscePracy FROM DaneOsobowe 
FULL JOIN Pracownik ON DaneOsobowe.idDaneOsobowe = Pracownik.idDaneOsobowe_FK
FULL JOIN Fabryka ON Pracownik.idFabryka_FK = Fabryka.idFabryka
LEFT JOIN Adres ON Fabryka.idAdres_FK = Adres.idAdres
WHERE idFabryka_FK IS NOT NULL

UNION

-- Managerzy Fabryk
SELECT imie as Imię, nazwisko as Nazwisko, coalesce(pseudonim,'-') as Pseudonim, telefon as Telefon, email as Email, ('Manager fabryki: ' + miasto + ', ul.' + ulica) as MiejscePracy FROM DaneOsobowe 
FULL JOIN Manager ON DaneOsobowe.idDaneOsobowe = Manager.idDaneOsobowe_FK
FULL JOIN Fabryka ON Manager.idFabryka_FK = Fabryka.idFabryka
LEFT JOIN Adres ON Fabryka.idAdres_FK = Adres.idAdres
WHERE idFabryka_FK IS NOT NULL
GO

--1b) Sprawdzenie, że widok działa
SELECT * FROM personel_kartelu
GO


--2a) Tworzymy funkcję 1
-- Funkcja zwracająca wszystkich dealerów operującej na danej dzielnicy
DROP FUNCTION dbo.dealerzy_na_dzielnicy
GO

CREATE FUNCTION dbo.dealerzy_na_dzielnicy (@dzielnia varchar(255))
RETURNS @Dealrzy TABLE (imie varchar(255), nazwisko varchar(255), telefon int, email varchar(255))
AS
BEGIN
	INSERT @Dealrzy
		SELECT imie , nazwisko , telefon, email 
		FROM DaneOsobowe 
		FULL JOIN Dealer ON DaneOsobowe.idDaneOsobowe = Dealer.idDaneOsobowe_FK
		WHERE dzielnicaPracy = @dzielnia
	RETURN
END
GO

--2b) Sprawdzenie, że funkcja 1 działa
SELECT * FROM dbo.dealerzy_na_dzielnicy('Ochota');
GO
--3a) Tworzymy funkcję 2
-- Funkcja wyświetla dealerów którzy posiadają podaną substancję

DROP FUNCTION dbo.kto_ma_substancje
GO

CREATE FUNCTION dbo.kto_ma_substancje (@sub varchar(255))
RETURNS @Dealrzy TABLE (imie varchar(255), nazwisko varchar(255), telefon int, email varchar(255), dzielnicaPracy varchar(255))
AS
BEGIN
	INSERT @Dealrzy
		SELECT do.imie, do.nazwisko, do.telefon, do.email, d.dzielnicaPracy
		FROM  JunctionTableOf_Substancje_Cennik sc
		INNER JOIN Cennik c ON c.idCennik = sc.idCennik
		INNER JOIN Dealer d ON d.idCennik_FK = c.idCennik
		INNER JOIN Substancja s ON s.idSubstancja = sc.idSubstancja
		INNER JOIN DaneOsobowe do ON do.idDaneOsobowe = d.idDaneOsobowe_FK
		WHERE s.nazwa = @sub
		RETURN
END
GO

--3b) Sprawdzenie, że funkcja 2 działa
SELECT * FROM dbo.kto_ma_substancje('konopia indyjska');
GO

--4a) Tworzymy procedurę 1
-- Procedura usuwa labolatorium wraz z wszystkimi pracownikami w niej pracującej  
DROP PROCEDURE zamknij_labolatorium
GO

CREATE PROCEDURE zamknij_labolatorium (@idLabolatorium int)
AS 
	SELECT (imie + ' ' + nazwisko) as UsunieciPracownicy FROM DaneOsobowe do WHERE do.idDaneOsobowe IN (SELECT idDaneOsobowe_FK FROM Pracownik WHERE Pracownik.idLabolatorium_FK = @idLabolatorium)
	DELETE FROM Pracownik WHERE Pracownik.idLabolatorium_FK = @idLabolatorium;
	DELETE FROM DaneOsobowe WHERE DaneOsobowe.idDaneOsobowe IN (SELECT idDaneOsobowe_FK FROM Pracownik WHERE Pracownik.idLabolatorium_FK = @idLabolatorium);

GO

--4b) Sprawdzenie, że procedura 1 działa
EXEC zamknij_labolatorium 1
GO

--5a) Tworzymy procedurę 2
 -- Procedura zmeinie osobę na pozycja managera podanej fabryki na nową
DROP PROCEDURE zmein_managera
GO

CREATE PROCEDURE zmein_managera (@imie varchar(255), @nazwisko varchar(255), @pseudonim varchar(255), @telefon int, @email varchar(255), @idFabryka int)
AS
	DECLARE @staryManager varchar(255)= (SELECT imie + ' ' + nazwisko FROM DaneOsobowe RIGHT JOIN Manager ON Manager.idDaneOsobowe_FK = DaneOsobowe.idDaneOsobowe WHERE Manager.idFabryka_FK = @idFabryka);
	DECLARE @nowyManager varchar(255) = @imie + ' ' + @nazwisko;
	DELETE FROM Manager WHERE Manager.idFabryka_FK = @idFabryka;
	DELETE FROM DaneOsobowe WHERE DaneOsobowe.idDaneOsobowe IN (SELECT idDaneOsobowe_FK FROM Manager WHERE Manager.idFabryka_FK = @idFabryka);
	INSERT INTO DaneOsobowe(imie, nazwisko, pseudonim, telefon, email) VALUES (@imie, @nazwisko, @pseudonim, @telefon, @email);
	INSERT INTO Manager (idFabryka_FK, idDaneOsobowe_FK) VALUES (@idFabryka, SCOPE_IDENTITY());
	SELECT 'Manager ' + @staryManager + ' został zmieniony na ' + @nowyManager;
GO
--5b) Sprawdzenie, że procedura 2 działa
EXEC zmein_managera 'Anatol', 'Karlinski', 'Karzel', 555555555, 'ank993@gmail.com', 5;
SELECT * FROM DaneOsobowe RIGHT JOIN Manager ON Manager.idDaneOsobowe_FK = DaneOsobowe.idDaneOsobowe;
--6a) Tworzymy wyzwalacz 1
-- Wyzwalacz wyswietla informacje na temat wprowadzonych zmian w cenie substancji

DROP TRIGGER wyswietl_zaminy_w_cenie
GO

CREATE TRIGGER wyswietl_zaminy_w_cenie
ON Substancja AFTER UPDATE
AS
	IF (SELECT count(*) FROM INSERTED) != 1
	BEGIN
		SELECT ('Nie można zmienić więcej niż jednej substancji na raz');
		ROLLBACK;
	END
	ELSE
		BEGIN
			DECLARE @nazwaSubstancji varchar(255) = (SELECT TOP 1 nazwa FROM INSERTED); --
			DECLARE @staraCena smallmoney = cast((SELECT TOP 1 cena FROM DELETED) as smallmoney);
			DECLARE @nowaCena smallmoney = cast((SELECT TOP 1 cena FROM INSERTED) as smallmoney);
			IF (@staraCena > @nowaCena)
			BEGIN
				SELECT 'Cena substancji "' + @nazwaSubstancji + '" zmnieniła się z ' + REPLACE(cast(@staraCena as char), ' ', '')   +  'zł na ' + REPLACE(cast(@nowaCena as char), ' ','') + 'zł. Spadek ceny wynosi ' + REPLACE(cast(abs((100-@staraCena/@nowaCena*100)) as char), ' ', '')  + '%';
			END
			ELSE IF (@staraCena < @nowaCena)
			BEGIN
				SELECT 'Cena substancji "' + @nazwaSubstancji + '" zmnieniła się z ' + REPLACE(cast(@staraCena as char), ' ', '')  +  'zł na ' + REPLACE(cast(@nowaCena as char), ' ','') + 'zł. Wzrost ceny wynosi ' +  REPLACE(cast(abs((100-@nowaCena/@staraCena*100)) as char), ' ', '') + '%';
			END
			ELSE
			BEGIN
				SELECT 'Cena substancji "' + @nazwaSubstancji + ' nie zmieniła się.';
			END
	END
GO
--6b) Sprawdzenie, że wyzwalacz 1 działa
UPDATE Substancja SET cena=cena-0.1 WHERE nazwa='konopia indyjska'

--7a) Tworzymy wyzwalacz 2
-- Wyzwalacz usuwa klientów dealera który ma zostać usunięty
DROP TRIGGER usun_klientow_dealera
GO

CREATE TRIGGER usun_klientow_dealera
ON Dealer INSTEAD OF DELETE
AS
	SELECT (imie + ' ' + nazwisko) AS usunieciKlieni FROM Klient LEFT JOIN DaneOsobowe do ON do.idDaneOsobowe=Klient.idDaneOsobowe_FK 
	WHERE Klient.idDealer_FK IN (SELECT idDealer FROM Deleted);
	DELETE FROM Klient WHERE Klient.idDealer_FK IN (SELECT idDealer FROM Deleted);
	DELETE FROM Dealer WHERE Dealer.idDealer IN (SELECT idDealer FROM Deleted);
GO

--7b) Sprawdzenie, że wyzwalacz 2 działa
SELECT * FROM Dealer LEFT JOIN DaneOsobowe ob ON ob.idDaneOsobowe=Dealer.idDaneOsobowe_FK;
DELETE FROM Dealer WHERE idDealer=1;

--8a) Tworzymy wyzwalacz 3
-- Wyzwalacz usuwa połączenia między substancjami a posiadającymi je cennikami w momencie usunięcia substancji
DROP TRIGGER usun_substance
GO

CREATE TRIGGER usun_substance
ON Substancja INSTEAD OF DELETE
AS
	DECLARE @output varchar(255);
	SET @output = (SELECT CASE (SELECT Count(*) FROM Deleted)
		WHEN 0 THEN 'Podana substancja nie istnieje'
		WHEN 1 THEN 'Substancja została usunięta z wszystkich cenników'
		ELSE 'Substancje zostały usunięte z wszystkich cenników'
	END)
	
	SELECT @output;

	DELETE FROM JunctionTableOf_Substancje_Cennik
	WHERE idSubstancja IN ( SELECT idSubstancja FROM Deleted )

	DELETE FROM Substancja 
	WHERE idSubstancja IN ( SELECT idSubstancja FROM Deleted )
GO
--8b) Sprawdzenie, że wyzwalacz 3 działa
DELETE FROM Substancja WHERE idSubstancja = 2

--9a) Tworzymy wyzwalacz 4
-- Wyzwalacz przed dodaniem managera upewnia się, że dana placówka nie ma już kogoś na tej pozycji
DROP TRIGGER dodaj_managera
GO

CREATE TRIGGER dodaj_managera
ON Manager INSTEAD OF INSERT
AS
	DECLARE @miasto varchar(255) = (SELECT miasto FROM Adres ad 
							RIGHT JOIN Fabryka f ON f.idAdres_FK=ad.idAdres 
							FULL JOIN Manager mg ON mg.idFabryka_FK=f.idFabryka 
							WHERE idFabryka_FK = (SELECT TOP 1 idFabryka_FK FROM Inserted) AND idDaneOsobowe_FK = (SELECT TOP 1 idDaneOsobowe_FK FROM Inserted))

	DECLARE @ulica varchar(255) = (SELECT TOP 1 ulica FROM Adres ad 
							RIGHT JOIN Fabryka f ON f.idAdres_FK=ad.idAdres 
					    	FULL JOIN Manager mg ON mg.idFabryka_FK=f.idFabryka 
							WHERE idFabryka_FK = (SELECT TOP 1 idFabryka_FK FROM Inserted) AND idDaneOsobowe_FK = (SELECT TOP 1 idDaneOsobowe_FK FROM Inserted))

	DECLARE @str varchar (255);
	SET @str = ('Manager fabryki: ' + @miasto	+ ', ul.' + @ulica);
	IF (SELECT COUNT(*) FROM personel_kartelu WHERE MiejscePracy LIKE @str ) > 0
	BEGIN
		RAISERROR('Operacja nie powiodła się - podana placówka posiada już managera', 1, 1)
		ROLLBACK;
	END
	ELSE 
	BEGIN
		INSERT INTO Manager(idFabryka_FK, idDaneOsobowe_FK) SELECT idFabryka_FK, idDaneOsobowe_FK FROM Inserted;
	END
GO
	
--9b) Sprawdzenie, że wyzwalacz 4 działa
INSERT INTO Manager (idFabryka_FK, idDaneOsobowe_FK) VALUES (1,1)
--10) Tworzymy tabelę przestawną
-- Nie :(