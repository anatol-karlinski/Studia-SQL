-- zad 17.2 --
SELECT wypozyczenie.data_odd, wypozyczenie.id_klient, klient.id_klient, klient.imie, klient.nazwisko, wypozyczenie.id_samochod
FROM wypozyczenie
INNER JOIN klient
	ON wypozyczenie.id_klient=klient.id_klient
WHERE wypozyczenie.data_odd IS NULL;

-- zad 17.3 --
SELECT klient.imie, klient.nazwisko, wypozyczenie.data_wyp, wypozyczenie.kaucja, wypozyczenie.id_klient, klient.id_klient
FROM wypozyczenie
INNER JOIN klient
	ON wypozyczenie.id_klient=klient.id_klient
WHERE wypozyczenie.kaucja IS NOT NULL;

-- zad 18.2 --
SELECT DISTINCT miejsce.ulica, miejsce.numer, samochod.typ, samochod.marka, samochod.id_samochod, miejsce.id_miejsce, wypozyczenie.id_samochod, wypozyczenie.id_miejsca_wyp
FROM wypozyczenie
INNER JOIN miejsce
	ON wypozyczenie.id_miejsca_wyp=miejsce.id_miejsce
INNER JOIN samochod
	ON wypozyczenie.id_samochod=samochod.id_samochod
ORDER BY miejsce.ulica ASC, samochod.marka ASC, samochod.typ ASC;

-- zad 18.3 --
SELECT Samochod.id_samochod, Samochod.marka, Samochod.typ, Klient.imie, Klient.nazwisko 
FROM Samochod, Klient 
ORDER BY Id_samochod, Nazwisko, Imie;

-- zad 19.2 --
SELECT avg(Pensja) AS Srednia_pensja, Imie, Nazwisko 
FROM pracownik 
GROUP BY Nazwisko, imie;

-- zad 19.3 --
SELECT TOP 1 data_prod, marka, typ
FROM samochod
ORDER BY data_prod ASC

-- zad 20.2 --
SELECT samochod.id_samochod, samochod.marka, samochod.typ, COUNT(wypozyczenie.id_samochod) AS ilosc_wypozyczen 
FROM wypozyczenie 
LEFT JOIN samochod 
	ON wypozyczenie.id_samochod = samochod.id_samochod
WHERE samochod.id_samochod IS NOT NULL
GROUP BY samochod.id_samochod, samochod.marka, samochod.typ
ORDER BY COUNT(wypozyczenie.id_samochod)ASC

-- zad 20.3 --
SELECT pracownik.imie, pracownik.nazwisko, COUNT(pracownik.id_pracownik) AS ilosc_wypozyczen 
FROM pracownik 
LEFT JOIN wypozyczenie 
	ON pracownik.id_pracownik = wypozyczenie.id_pracow_wyp
GROUP BY pracownik.imie, pracownik.nazwisko
ORDER BY COUNT(pracownik.id_pracownik)DESC;

-- zad 21.2 --
SELECT samochod.id_samochod, samochod.marka, samochod.typ, COUNT(wypozyczenie.id_samochod) AS ilosc_wypozyczen 
FROM wypozyczenie 
LEFT JOIN samochod 
	ON wypozyczenie.id_samochod = samochod.id_samochod
GROUP BY samochod.id_samochod, samochod.marka, samochod.typ
HAVING COUNT(samochod.id_samochod) >= 2
ORDER BY samochod.marka ASC, samochod.typ ASC;

-- zad 21.3 --
SELECT pracownik.imie, pracownik.nazwisko, 
COUNT(pracownik.id_pracownik) AS ilosc_wypozyczen 
FROM pracownik 
LEFT JOIN wypozyczenie 
	ON pracownik.id_pracownik = wypozyczenie.id_pracow_wyp
GROUP BY pracownik.imie, pracownik.nazwisko
HAVING COUNT(pracownik.imie) <= 20
ORDER BY COUNT(pracownik.id_pracownik)ASC, pracownik.imie ASC, pracownik.nazwisko ASC;