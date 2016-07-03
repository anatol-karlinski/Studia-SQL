--- 22.2 ---
SELECT pensja, imie, nazwisko
FROM pracownik
WHERE pensja>(SELECT AVG(pensja) FROM pracownik);

--- 22.3 ---
SELECT marka, typ, data_prod
FROM samochod
WHERE data_prod<=(SELECT TOP 1 data_prod FROM samochod ORDER BY data_prod ASC)

--- 23.2 ---
SELECT klient.imie, klient.nazwisko , klient.id_klient 
FROM klient 
LEFT JOIN wypozyczenie ON klient.id_klient = wypozyczenie.id_klient
WHERE wypozyczenie.id_klient IS NULL
ORDER BY klient.imie ASC, klient.nazwisko ASC;

--- 23.3 ---
SELECT pracownik.imie, pracownik.nazwisko, pracownik.id_pracownik, wypozyczenie.id_pracow_wyp
FROM pracownik
LEFT JOIN wypozyczenie ON pracownik.id_pracownik = wypozyczenie.id_wypozyczenie
WHERE wypozyczenie.id_pracow_wyp IS NULL
ORDER BY pracownik.imie ASC

--- 24.2 ---
SELECT klient.id_klient, klient.imie, klient.nazwisko, COUNT(wypozyczenie.id_klient) AS ILOSC
FROM klient JOIN wypozyczenie ON klient.id_klient = wypozyczenie.id_klient
GROUP BY klient.id_klient, klient.imie, klient.nazwisko
HAVING COUNT(wypozyczenie.id_klient) = 
(
	SELECT TOP 1 COUNT(wypozyczenie.id_klient) AS ilosc
	FROM wypozyczenie
	GROUP BY wypozyczenie.id_klient
	ORDER BY ilosc ASC
)
ORDER BY ILOSC ASC

--- 24.3 ---
SELECT pracownik.id_pracownik, pracownik.nazwisko, pracownik.imie
FROM pracownik 
JOIN wypozyczenie ON pracownik.id_pracownik = wypozyczenie.id_pracow_wyp 
GROUP BY pracownik.id_pracownik, pracownik.nazwisko, pracownik.imie
HAVING COUNT(wypozyczenie.id_pracow_wyp) =
(
	SELECT TOP 1 COUNT(wypozyczenie.id_pracow_wyp) AS ilosc_wypozyczen
	FROM wypozyczenie
	GROUP BY wypozyczenie.id_pracow_wyp
	ORDER BY ilosc_wypozyczen DESC
)
ORDER BY pracownik.nazwisko ASC, pracownik.imie ASC;

--- 25.2 ---
UPDATE pracownik 
SET pensja=Pensja*1.10 
WHERE id_pracownik = 
(
	SELECT pracownik.id_pracownik
	FROM pracownik
	JOIN wypozyczenie ON pracownik.id_pracownik = wypozyczenie.id_pracow_wyp
	WHERE MONTH(wypozyczenie.data_wyp) = 5
	GROUP BY wypozyczenie.data_wyp, pracownik.id_pracownik
)

--- 25.3 ---
UPDATE pracownik 
SET pensja=Pensja*0.95 
WHERE id_pracownik = 
(
	SELECT pracownik.id_pracownik
	FROM pracownik
	JOIN wypozyczenie ON pracownik.id_pracownik = wypozyczenie.id_pracow_wyp
	WHERE YEAR(wypozyczenie.data_wyp) = 1999
	GROUP BY wypozyczenie.data_wyp, pracownik.id_pracownik
)