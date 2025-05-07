--Usuniêcie Zlecenie_Konserwacji, usunie te¿ Konserwacja i usuniêcie Konserwacja usunie Raport_z_Konserwacji
SELECT * FROM Konserwacja WHERE przypisane_zlecenie = 2;
SELECT * FROM Raport_z_Konserwacji WHERE generuje_raport = 2;
SELECT * FROM Zlecenie_Konserwacji WHERE id = 2;

DELETE FROM Zlecenie_Konserwacji WHERE id = 2;



-- Usuniêcie z Konserwator usunie te¿ Zlecenie_Konserwacji i Konserwator_Specjalizacja
SELECT * FROM Konserwator_Specjalizacja WHERE konserwator_id = 4;
SELECT * FROM Zlecenie_Konserwacji WHERE wykonuje_konserwacje = 4;
SELECT * FROM Konserwator WHERE id = 4

DELETE FROM Konserwator WHERE id = 4;



-- Usuniêcie Firma_Konserwatorska usunie te¿ Konserwator, który usunie te¿ Zlecenie_Konserwacji
SELECT * FROM Konserwator WHERE zatrudnia = 5;
SELECT * FROM Firma_Konserwatorska WHERE id = 5;
SELECT * FROM Zlecenie_Konserwacji WHERE wykonuje_konserwacje = 5;

DELETE FROM Firma_Konserwatorska WHERE id = 5;



-- Usuniêcie Przeglad_Techniczny, nie ma wp³ywu na nic (np. nie ma wp³ywu na Zabytek)
SELECT * FROM Przeglad_Techniczny WHERE id = 7;
SELECT * FROM Zabytek WHERE id = 7;

DELETE FROM Przeglad_Techniczny WHERE id = 7;

