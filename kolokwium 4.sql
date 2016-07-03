--Kolokwium 3
--Imi� i nazwisko: Karol Tymi�ski		
--Data i godzina: 30-05-2014 12;30
--Grupa laboratoryjna: B
--Czas: 60 min
--Liczba punkt�w do zdobycia: 20 pkt
--Napisz instrukcje SQL (dla MS SQL Server) realizuj�ce poni�sze zadania.

--B1 [7 pkt]
--1) Utw�rz tabel� o nazwie Autor zawieraj�c� kolumny:
--a) id, jest unikatowym numerem nadawanym automatycznie, jest to klucz g��wny [0.5 pkt],
--b) nazwisko, jest unikatowym nazwiskiem dziennikarza, niepustym [0.5 pkt],
--c) pseudonim, jest opcjonalny [0.5 pkt]
CREATE TABLE Autor (
id_autor INTEGER IDENTITY(1,1) PRIMARY KEY,
nazwisko VARCHAR(30) NOT NULL UNIQUE,
pseudonim VARCHAR(20)
);
GO

--2) Utw�rz tabel� o nazwie Ksi��ka zawieraj�c� kolumny:
--a) id, jest unikatowym numerem nadawanym automatycznie, jest to klucz g��wny [0.5 pkt],
--b) tytu�, jest niepustym �a�cuchem znak�w zmiennej d�ugo�ci od 3 do 30 znak�w [0.5 pkt],
--c) rok, jest liczb� ca�kowit� wi�ksz� od 1900 [0.5 pkt]
--d) stron, jest liczb� ca�kowit� z zakresu (0,1200), by� mo�e nieokre�lon� [1 pkt]
--f) id_au, jest to klucz obcy powi�zany z kolumn� id tabeli Autor, 
--   kt�ry w przypadku instrukcji UPDATE wprowadza zmiany kaskadowo, a w przypadku 
--   instrukcji DELETE � wstawia warto�� nieokre�lon� [2 pkt].

CREATE TABLE ksiazka( 
id_ksiazka INTEGER PRIMARY KEY IDENTITY(1,1), 
tytul VARCHAR(30) NOT NULL CHECK(tytul>='3'), 
rok INTEGER CHECK(rok>'1900'), 
strony INTEGER CHECK(strony>=0 AND strony<=1200), 
id_au INTEGER REFERENCES Autor(id_autor) ON UPDATE CASCADE ON DELETE SET NULL );
GO


--3) Do ka�dej z tabel dodaj po 2 rekordy [1 pkt]
--Rozwi�zanie:
SET IDENTITY_INSERT [dbo].[autor] ON
insert into Autor(id_autor,nazwisko, pseudonim) values(1,'Sapkowski', 'Grim'); 
insert into Autor(id_autor,nazwisko, pseudonim) values(2,'Gal', 'Anonim');
SET IDENTITY_INSERT [dbo].[autor] OFF 
SET IDENTITY_INSERT [dbo].[ksiazka] ON
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(1,'Pan Tadeusz','1901', '186',2); 
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(2,'Potop','2003', '540',1);
SET IDENTITY_INSERT [dbo].[ksiazka] OFF
--B2 [6 pkt]
--1) Napisz wyzwalacz o nazwie "insert_ksi��ka", kt�ry uniemo�liwi dodanie drugiej 
--   ksi��ki o takim samym tytule i roku wydania [2 pkt],
--2) Napisz wyzwalacz o nazwie "update_ksi��ka", kt�ry uniemo�liwi zmian� tytu�u 
--   i roku wydania ksi��ki na takie, kt�re ju� wyst�puje w bazie danych [2 pkt].
--   (Tak, �e w bazie nie b�dzie dw�ch ksi��ek o tym samym tytule i roku wydania)
--1///////////////////////////////////////////////////
CREATE TRIGGER insert_ksiazka ON ksiazka
AFTER INSERT AS
 DECLARE @tytul VARCHAR(30)
 DECLARE @rok INTEGER
 DECLARE @strony INTEGER
 SELECT @tytul=tytul, @rok=rok FROM inserted;
 IF (SELECT COUNT(*) FROM ksiazka WHERE @tytul=tytul AND @rok=rok)>1
 BEGIN
 RAISERROR('NIE WOLNO DODAC 2 RAZ TEJ SAMEJ KSIAZKI',1,2)
 ROLLBACK
 END 
--2//////////////////////////////////////////////////// 
CREATE TRIGGER update_ksiazka ON ksiazka 
AFTER UPDATE AS
 DECLARE @tytul VARCHAR(30)
 DECLARE @rok INTEGER
 DECLARE @strony INTEGER
 SELECT @tytul=tytul, @rok=rok FROM inserted;
 IF (SELECT COUNT(*) FROM ksiazka WHERE @tytul=tytul AND @rok=rok)>1
 BEGIN
 RAISERROR('NIE WOLNO DODAC 2 RAZ TEJ SAMEJ KSIAZKI',1,2)
 ROLLBACK
 END 
 
--3) Napisz instrukcje, kt�re przetestuj� dzia�anie obu wyzwalaczy, uwzgl�dnij testy, 
--   kt�re generuj� duplikat tytu�u i numeru oraz te, kt�re nie generuj� takiego 
--   duplikatu (razem 4 testy) [2 pkt]:
--Rozwi�zanie:
--SPRAWDZANIE DO 1 TRIGGERA/////////////////////////////
SET IDENTITY_INSERT [dbo].[ksiazka] ON
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(4,'Pan Tadeusz','1901', '186',2); 
insert into ksiazka(id_ksiazka,tytul,rok,strony,id_au) values(5,'Ogniem i Mieczem','2007', '540',1);
SET IDENTITY_INSERT [dbo].[ksiazka] OFF
--SPRAWDZENIE DO 2 TRIGGERA////////////////////////////
UPDATE ksiazka SET tytul='Pan Tadeusz', rok='1901' WHERE id_ksiazka=2
UPDATE ksiazka SET tytul='Bitwa Warszawska', rok='2004' WHERE id_ksiazka=1
--//////////////////////////////////////////////////////////
--B3 [6 pkt]
--1) Napisz procedur� o nazwie "usun_funkcje", kt�ra usunie wszystkie funkcje, kt�re
--   zosta�y utworzone przez u�ytkownik�w w bie��cej bazie danych [4 pkt].
--   Wskaz�wka: skorzystaj z dynamicznego SQLa.
CREATE PROCEDURE usun_funkcje  
AS BEGIN DECLARE @sql 
NVARCHAR(50); 
WHILE EXISTS(SELECT * FROM sys.objects where type = 'fn') 
BEGIN SELECT @sql='DROP FUNCTION ' + name FROM sys.objects 
WHERE TYPE = 'fn' 
EXEC sp_executesql @sql 
END 
END 
GO 
EXEC usun_funkcje 
select name from sys.objects where type = 'fn'

drop procedure usun_funkcje
--2) Utw�rz dowoln� funkcj� o nazwie "fun_testowa" (nie ma znaczenia co ona robi).
--   Napisz instrukcj� uruchamiaj�c� procedur� "usun_funkcje" i udowodnij, �e
--   zosta�a ona usuni�ta (napisz odpowiedni SELECT) [2 pkt].
--Rozwi�zanie:

--Sebastian Matyjas, 224599, grupa A
--Utw�rz tabele klient(id_klient, nazwisko, kod), gdzie:
--id_klient - automatycznie nadawany, niepusty numer klienta, klucz g��wny,
--nazwisko - niepusty �a�cuch znak�w zmiennej d�ugo�ci od 3 do 20 znak�w,
--kod - kod pocztowy, dok�adnie 6 znak�w

drop table klient;

CREATE TABLE klient (
id_klient INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
nazwisko VARCHAR(20) NOT NULL check(len(nazwisko)>=3),
kod VARCHAR(6) check(len(kod)=6),
);

insert into klient(nazwisko,kod)
values('Kowalski','80-100');







--oraz tabel� zakup(id_zakup, id_klient,nazwa_towaru,ilosc,cena), gdzie:
--id_zakup - niepusty klucz g��wny, warto�ci nadawane automatycznie,
--id_klient - niepusty klucz obcy powi�zany z kolumn� id_klient tabeli klient,
--nazwa_towaru - unikatowy �a�cuch znak�w o zmiennej d�ugo�ci od 5 do 60 znak�w
--ilosc - liczba nieujemna, warto�� domy�lna 0,
--cena - kwota nie ni�sza ni� 5 z�
--Rozwi�zanie [3pkt]:

drop table zakup;

CREATE TABLE zakup (
id_zakup INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
id_klient INT REFERENCES klient(id_klient),
nazwa_towaru VARCHAR(60) UNIQUE check(len(nazwa_towaru)>=5),
ilosc INT check(ilosc>=0),
cena MONEY check(cena>=5),
);

insert into zakup(id_klient,nazwa_towaru,ilosc,cena)
values(1,'czajnik',2,100);









--Utw�rz widok raport(id_klient,nazwisko,kod,suma_wydanych_pieniedzy), gdzie
--id_klient, nazwisko, kod to kolumny z tabeli klient
--suma_wydanych_pieniedzy - ��czna suma wydanych pieni�dzy przed danego klienta (suma po ilosci*cena)
--Rozwi�zanie [1 pkt]
drop view raport;

CREATE VIEW RAPORT AS
SELECT k.id_klient, k.nazwisko, k.kod, SUM( z.ilosc*z.cena ) AS suma_pieniedzy FROM klient k
INNER JOIN zakup z ON k.id_klient=z.id_klient
GROUP BY k.id_klient, k.nazwisko, k.kod;
go

select * from raport;







--Utw�rz wyzwalacz, kt�ry po wykonaniu zapytania:
--INSERT INTO raport(nazwisko,kod) VALUES ('Gondek','80-287');
--doda nowego klienta do tabeli klient,
--Rozwi�zanie [3 pkt]

create trigger dodaj_klienta on klient
instead of insert
as





--Do tabeli klient dodaj kolumn� usuni�ty, z domy�ln� warto�ci� 0,
--Napisa� wyzwalacz, kt�ry zamiast usun�� fizycznie klienta zmieni
--warto�� kolumny usuni�ty z 0 na 1,
--Rozwi�zanie [3 pkt]:

drop trigger klient_del;

ALTER TABLE klient ADD usuniety BIT DEFAULT 0;
IF EXISTS (SELECT name FROM sysobjects WHERE name = 'klient_del' AND type = 'TR')
DROP TRIGGER klient_del;
GO
CREATE TRIGGER klient_del on klient
INSTEAD OF DELETE AS
BEGIN
UPDATE klient
SET usuniety=1
WHERE id_klient IN (SELECT id_klient FROM deleted)
END

DELETE from klient where id_klient=1;
SELECT * from klient;

--Napisa� wyzwalacz, kt�ry po dodaniu klienta poprawi jego nazwisko, tak
--aby zaczyna�o si� z wielkiej litery, a pozosta�e litery zmieni na ma�e,
--Uwzgl�dnij nazwiska dwucz�onowe, np: Janicka-Nowak,
--Rozwi�zanie [2 pkt]
drop trigger nazwisko_duze;

CREATE TRIGGER nazwisko_duze ON klient
AFTER INSERT AS
BEGIN
DECLARE kursor_duzy CURSOR
FOR SELECT id_klient, nazwisko from inserted
DECLARE @id int, @nazwisko varchar(20)
OPEN kursor_duzy
FETCH NEXT FROM kursor_duzy INTO @id, @nazwisko
WHILE @@FETCH_STATUS = 0
BEGIN

IF (ascii(SUBSTRING(@nazwisko, 1, 1)) > 96)
BEGIN
UPDATE klient SET nazwisko = UPPER(left(@nazwisko, 1)) + LOWER(SUBSTRING(@nazwisko,2,len(@nazwisko))) where id_klient = @id;
PRINT 'Poprawiono: '+ @nazwisko
END

FETCH NEXT FROM kursor_duzy INTO @id, @nazwisko
END
CLOSE kursor_duzy
DEALLOCATE kursor_duzy
END

INSERT into klient(kod,nazwisko)
VALUES ('80-250','malanowski');

select * from klient;

--Napisa� funkcj� pomocnicz� sprawdz_kod(sprawdzany_kod) zwracaj�c�
--warto�� true, gdy kod jest napisany w prawid�owym formacie
--(dwie cyfry, my�lnik, trzy cyfry) lub false a w przeciwnym przypadku,
--Napisz wyzwalacz, kt�ry uniemo�liwi modyfikacj� kodu pocztowego
--w tabeli klient na niepoprawny format, wykorzystaj funkcj� sprawdz_kod
--Rozwi�zanie [3 pkt]

DROP FUNCTION sprawdz_kod;

CREATE FUNCTION sprawdz_kod(@kod VARCHAR(6))
RETURNS BIT
AS
BEGIN
IF (LEN(@kod)=6 AND ISNUMERIC(CONVERT(INT,LEFT(@kod,2)))=1 AND ISNUMERIC(CONVERT(INT,RIGHT(@kod,3)))=1 AND SUBSTRING(@kod,3,1)='-') RETURN 1
RETURN 0
END
GO

PRINT dbo.sprawdz_kod('123-45');
PRINT dbo.sprawdz_kod('12-345');