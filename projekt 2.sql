-- Usuwanie starej bazy --
DROP TABLE JunctionTableOf_Substancje_Cennik 
DROP TABLE Pracownik
DROP TABLE Labolatorium
DROP TABLE Klient
DROP TABLE Dealer
DROP TABLE Cennik
DROP TABLE Manager 
DROP TABLE Substancja
DROP TABLE Fabryka
DROP TABLE DaneOsobowe
DROP TABLE Adres

-- Tworzenie Bazy --
CREATE SEQUENCE Adres_seq;

CREATE TABLE Adres
(
	idAdres INT NOT NULL DEFAULT NEXTVAL ('Adres_seq') PRIMARY KEY,
	miasto varchar(255) NOT NULL,
	ulica varchar(255) NOT NULL,
	kodpocztowy INT NOT NULL,
);
CREATE SEQUENCE Labolatorium_seq;

CREATE TABLE Labolatorium
(
	idLabolatorium INT NOT NULL DEFAULT NEXTVAL ('Labolatorium_seq') PRIMARY KEY,
	nazwa varchar(255),
	idAdres_FK INT UNIQUE FOREIGN KEY REFERENCES Adres(idAdres),
);
CREATE SEQUENCE Fabryka_seq;

CREATE TABLE Fabryka
(
	idFabryka INT NOT NULL DEFAULT NEXTVAL ('Fabryka_seq') PRIMARY KEY,
	nazwa varchar(255),
	idAdres_FK INT UNIQUE FOREIGN KEY REFERENCES Adres(idAdres),
);
CREATE SEQUENCE DaneOsobowe_seq;

CREATE TABLE DaneOsobowe
(
	idDaneOsobowe INT NOT NULL DEFAULT NEXTVAL ('DaneOsobowe_seq') PRIMARY KEY,
	imie varchar(255) NOT NULL,
	nazwisko varchar(255) NOT NULL,
	pseudonim varchar(255),
	telefon INT,
	email varchar(255),
);
CREATE SEQUENCE Pracownik_seq;

CREATE TABLE Pracownik
(
	idPracownik INT NOT NULL DEFAULT NEXTVAL ('Pracownik_seq') PRIMARY KEY,
	idFabryka_FK INT FOREIGN KEY REFERENCES Fabryka(idFabryka),
	idLabolatorium_FK INT FOREIGN KEY REFERENCES Labolatorium(idLabolatorium),
	idDaneOsobowe_FK INT UNIQUE FOREIGN KEY REFERENCES DaneOsobowe(idDaneOsobowe),
);
CREATE SEQUENCE Manager_seq;

CREATE TABLE Manager
(
	idManager INT NOT NULL DEFAULT NEXTVAL ('Manager_seq') PRIMARY KEY,
	idFabryka_FK INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Fabryka(idFabryka),
	idDaneOsobowe_FK INT UNIQUE FOREIGN KEY REFERENCES DaneOsobowe(idDaneOsobowe),
);
CREATE SEQUENCE Substancja_seq;

CREATE TABLE Substancja
(
	idSubstancja INT NOT NULL DEFAULT NEXTVAL ('Substancja_seq') PRIMARY KEY,
	nazwa varchar(255) NOT NULL,
	cena money NOT NULL,
	idFabryka_FK INT FOREIGN KEY REFERENCES Fabryka(idFabryka),
);
CREATE SEQUENCE Cennik_seq;

CREATE TABLE Cennik
(
	idCennik INT NOT NULL DEFAULT NEXTVAL ('Cennik_seq') PRIMARY KEY,
	dataWaznosciCennika date NOT NULL,
)
CREATE TABLE JunctionTableOf_Substancje_Cennik
(
	idCennik int,
	idSubstancja int,
	CONSTRAINT jt_s_c PRIMARY KEY (idCennik, idSubstancja),
	CONSTRAINT idCennik_FK FOREIGN KEY (idCennik) REFERENCES Cennik (idCennik),
	CONSTRAINT idSubstancja_FK FOREIGN KEY (idSubstancja) REFERENCES Substancja (idSubstancja)
)
CREATE SEQUENCE Dealer_seq;

CREATE TABLE Dealer
(
	idDealer INT NOT NULL DEFAULT NEXTVAL ('Dealer_seq') PRIMARY KEY,
	dzielnicaPracy varchar(255) NOT NULL,
	idDaneOsobowe_FK INT UNIQUE FOREIGN KEY REFERENCES DaneOsobowe(idDaneOsobowe),
	idCennik_FK INT FOREIGN KEY REFERENCES Cennik(idCennik),
);
CREATE SEQUENCE Klient_seq;

CREATE TABLE Klient
(
	idKlient INT NOT NULL DEFAULT NEXTVAL ('Klient_seq') PRIMARY KEY,
	idDealer_FK INT FOREIGN KEY REFERENCES Dealer(idDealer),
	idDaneOsobowe_FK INT UNIQUE FOREIGN KEY REFERENCES DaneOsobowe(idDaneOsobowe),
);

-- Dodawanie rekordów --

-- Labolatorium
INSERT INTO Adres (miasto, ulica, kodpocztowy) VALUES
('Warszawa', 'Kaniowska', 01529),
('Warszawa', 'Prusa', 05075),
('Warszawa', 'Katowicka', 03032),
('Warszawa', 'Algierska', 03977),
('Warszawa', 'Borecka', 03034);

INSERT INTO Labolatorium (nazwa, idAdres_FK) VALUES
('CodeRed', 1),
('Odessa', 2),
('Karuzela', 3),
('Pokuj 13', 4),
('Opera', 5);

-- Fabryka
INSERT INTO Adres (miasto, ulica, kodpocztowy) VALUES
('Warszawa', 'Kulczycka', 01843),
('Warszawa', 'Boguckiego', 01508),
('Warszawa', 'Lisi Jar', 02798),
('Warszawa', 'Cichy Potok', 02717),
('Warszawa', 'Suzina', 01586);

INSERT INTO Fabryka (nazwa, idAdres_FK) VALUES
('Bunkier', 6),
('Spiżarnia', 7),
('Katowice', 8),
('Magazyn 24', 9),
('Rudera', 10);

-- Manager
INSERT INTO DaneOsobowe (imie, nazwisko, pseudonim, telefon, email) VALUES
('Jan', 'Kowalski', 'Kowal', 509344035, 'kowal@o2.pl'),
('Piotr', 'Ziółkowski', 'Zioło', 458744521, 'ziolo@o2.pl'),
('Sonia', 'Kamińska', 'Sona', 759466587, 'sona@o2.pl'),
('Filip', 'Rutkowski', 'Detektyw', 978577412, 'fili@o2.pl'),
('Maksymilian', 'Domański', 'Max', 784366457, 'max@o2.pl');

INSERT INTO Manager (idFabryka_FK, idDaneOsobowe_FK) VALUES
(1,1), (2,2), (3,3), (4,4), (5,5);

-- Pracownik fabryki
INSERT INTO DaneOsobowe ( imie, nazwisko, telefon, email) VALUES
('Janusz', 'Kot', 745877124, 'kot@me.pl'),
('Ewa','Solidna', 698577425, 'Solidna@me.pl'),
('Marian','Zadziorny', 354788451, 'Zadzior@me.pl'),
('Kinga','Cnotliwa', 757144532, 'Cnota@me.pl'),
('Piotr','Nudny', 989599657, 'Pit@me.pl');

INSERT INTO Pracownik (idFabryka_FK, idLabolatorium_FK, idDaneOsobowe_FK) VALUES
(1, NULL, 6), (2, NULL, 7), (3, NULL, 8), (4, NULL, 9), (5, NULL, 10);

-- Pracownik laboaltorium
INSERT INTO DaneOsobowe ( imie, nazwisko, telefon, email) VALUES
('Zofia', 'Grzybowska', 785477592, 'zgrzyb@me.pl'),
('Mikołaj', 'Krawczyk', 398744587, 'mkraw@me.pl'),
('Michał', 'Nowak', 698744582, 'mnowak@me.pl'),
('Szymon', 'Wasilewski', 147588965, 'swas@me.pl'),
('Jan', 'Jastrzębski', 475988475, 'Pit@me.pl');

INSERT INTO Pracownik (idFabryka_FK, idLabolatorium_FK, idDaneOsobowe_FK) VALUES
(NULL, 1, 11), (NULL, 2, 12), (NULL, 3, 13), (NULL, 4, 14), (NULL, 5, 15);

-- Substancje
INSERT INTO Substancja (nazwa, cena, idFabryka_FK) VALUES
('konopia indyjska', 30, 1), ('datura', 20, 2), ('dietyloamid kwasu lizerginowego', 20, 3), ('Ecstasy',10,  4), ('benzodiazepina',15, 5);

-- Cennik
INSERT INTO Cennik (dataWaznosciCennika) VALUES
('2016-12-30'), ('2016-12-30'),('2016-12-30'),('2016-12-30'),('2016-12-30');

INSERT INTO JunctionTableOf_Substancje_Cennik VALUES
(1,1),(2,2),(3,3),(4,4),(5,5);

-- Dealer
INSERT INTO DaneOsobowe (imie, nazwisko, pseudonim, telefon, email) VALUES
('Kajetan', 'Jarosz', 'Jar', 787477854, 'jar@me.pl'),
('Barbara', 'Żukowska', 'Żuku', 986988574, 'zuku@me.pl'),
('Zofia', 'Kaczmarek', 'Kaczer', 123466874, 'kaczer@me.pl'),
('Martyna', 'Marczak', 'Marq', 787844759, 'marq@me.pl'),
('Piotr', 'Olejniczak', 'Olej', 369877452, 'olej@me.pl');

INSERT INTO Dealer (dzielnicaPracy, idCennik_FK, idDaneOsobowe_FK) VALUES
('Ochota', 1, 16), ('Żoliborz', 2, 17), ('Wawer',3, 18), ('Bemowo',4, 19), ('Mokotów',5, 20);

-- Klient
INSERT INTO DaneOsobowe ( imie, nazwisko, pseudonim, telefon, email) VALUES
('Nina', 'Dąbrowska', 'Ninja', 784755847, 'ninja@me.pl'),
('Tymon', 'Wójcik', 'Tymek', 365266987, 'tymek@me.pl'),
('Norbert', 'Wiśniewski', 'Wiśnia', 124155478, 'wisnia@me.pl'),
('Julia', 'Nowak', 'Nowy', 787488515, 'nowy@me.pl'),
('Jakub', 'Jankowski', 'Janq', 363211478, 'janq@me.pl');

-- Połączenie Klient i Dealer
INSERT INTO Klient (idDealer_FK, idDaneOsobowe_FK) VALUES
(1, 21), (2, 22), (3, 23), (4, 24), (5,25);
