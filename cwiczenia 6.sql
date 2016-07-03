-- 36.2 --
DROP TRIGGER dodaj_prac
GO

CREATE TRIGGER dodaj_prac ON pracownik
INSTEAD OF INSERT
AS
BEGIN
	DECLARE kursor_prac CURSOR
	FOR SELECT * FROM INSERTED;
	DECLARE @id_pracownik INT, @imie VARCHAR(15), @nazwisko VARCHAR(20), @data_zatr DATETIME, @dzial VARCHAR(20), @stanowisko VARCHAR(20), @prensja DECIMAL(8,2), @dodatek DECIMAL(8,2), @id_miejsce INT, @telefon VARCHAR(16);
	IF (SELECT pensja FROM INSERTED) IS NULL OR (SELECT dodatek FROM INSERTED) IS NULL OR (SELECT dodatek FROM INSERTED) = 0 OR (SELECT pensja FROM INSERTED) = 0
	BEGIN
		SELECT 'Pensja i dodatek nie mog¹ byæ NULL ani 0'
		SELECT * FROM INSERTED
		END
	ELSE
	BEGIN
		OPEN kursor_prac
		FETCH NEXT FROM kursor_prac INTO @id_pracownik, @imie, @nazwisko, @data_zatr, @dzial, @stanowisko, @prensja, @dodatek, @id_miejsce, @telefon; 	
		WHILE @@FETCH_STATUS=0
			BEGIN
			INSERT INTO pracownik VALUES (@id_pracownik, @imie, @nazwisko, @data_zatr, @dzial, @stanowisko, @prensja, @dodatek, @id_miejsce, @telefon);
			FETCH NEXT FROM kursor_prac INTO @id_pracownik, @imie, @nazwisko, @data_zatr, @dzial, @stanowisko, @prensja, @dodatek, @id_miejsce, @telefon; 
			END
		CLOSE kursor_prac
		DEALLOCATE kursor_prac
	END
END
GO

INSERT INTO pracownik VALUES (213, 'aaa', 'bbb', '01-01-1991', 'uuuuu', 'eeeeeee', 0, NULL, 3, '5151515151');
SELECT * FROM pracownik
GO


-- 36.3 --
DROP TRIGGER duplikat_miejsce
GO

CREATE TRIGGER duplikat_miejsce ON miejsce
INSTEAD OF INSERT
AS
BEGIN
	DECLARE kursor_miejsce CURSOR
	FOR SELECT * FROM miejsce;
	DECLARE @ulica VARCHAR(24), @numer VARCHAR(8), @miasto VARCHAR(24), @kod CHAR(6);
	DECLARE @flag INT = 1;
	SELECT * FROM INSERTED
	IF (@@ROWCOUNT != 1)
	BEGIN
		SELECT 'Nie mo¿na dodaæ wiêcej ni¿ jednego miejsca na raz';
	END
	ELSE
	BEGIN
		OPEN kursor_miejsce;
		FETCH NEXT FROM kursor_miejsce INTO @ulica, @numer, @miasto, @kod;
		WHILE @@FETCH_STATUS=0
		BEGIN
			FETCH NEXT FROM kursor_miejsce INTO @ulica, @numer, @miasto, @kod;
			IF (@ulica IN (SELECT ulica FROM INSERTED)) AND (@numer IN (SELECT numer FROM INSERTED)) AND (@miasto IN (SELECT miasto FROM INSERTED))AND (@kod IN (SELECT kod FROM INSERTED))
			BEGIN
				SET @flag = 0;
			END
		END
		IF (@flag = 0)
		BEGIN
			SELECT 'Duplikat miejsca!';
		END	
		ELSE
		BEGIN
			SELECT '';--INSERT INTO miejsce VALUES ((SELECT id_miejsce FROM inserted), (SELECT ulica FROM inserted), (SELECT numer FROM inserted), (SELECT miasto FROM inserted), (SELECT kod FROM inserted), (SELECT telefon FROM inserted), (SELECT uwagi FROM inserted));
		END
		CLOSE kursor_miejsce
		DEALLOCATE kursor_miejsce
	END
END
SELECT * FROM miejsce
INSERT INTO miejsce(id_miejsce, ulica, numer, miasto, kod, telefon, uwagi) VALUES (99, 'Widmo', '11', 'Malbork', '83-200', '111-222-345', NULL), (99, 'Widmo', '11', 'Malbork', '83-200', '111-222-345', NULL);