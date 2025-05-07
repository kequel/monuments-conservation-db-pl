-- Zmiana ID miasta - zmieni ID w jego Zabytek
SELECT * FROM Miasto WHERE id = 1;
SELECT * FROM Zabytek WHERE znajduje_sie_w = 1;

UPDATE Miasto
SET id = 111
WHERE id = 1;

SELECT * FROM Miasto WHERE id = 111;
SELECT * FROM Zabytek WHERE znajduje_sie_w = 111;



--Zmiana ID opiekuna zmieni ID w jego Zabytek
SELECT * FROM Opiekun WHERE id = 1;
SELECT * FROM Zabytek WHERE opiekuje_sie = 1;

UPDATE Opiekun
SET id = 100
WHERE id = 1;

SELECT * FROM Opiekun WHERE id = 100;
SELECT * FROM Zabytek WHERE opiekuje_sie = 100;



-- Zmiana ID konserwatora zmieni ID w jego Zlecenie_Konserwacji
SELECT * FROM Konserwator WHERE id = 2;
SELECT * FROM Zlecenie_Konserwacji WHERE wykonuje_konserwacje = 2;

UPDATE Konserwator
SET id = 200
WHERE id = 2;

SELECT * FROM Konserwator WHERE id = 200;
SELECT * FROM Zlecenie_Konserwacji WHERE wykonuje_konserwacje = 200;



-- Zmiana ID Konserwacja zmieni ID w jego Zlecenie_Konserwacji
SELECT * FROM Zlecenie_Konserwacji WHERE id = 3;
SELECT * FROM Konserwacja WHERE przypisane_zlecenie = 3;

UPDATE Zlecenie_Konserwacji
SET id = 300
WHERE id = 3;

SELECT * FROM Zlecenie_Konserwacji WHERE id = 300;
SELECT * FROM Konserwacja WHERE przypisane_zlecenie = 300;

