IF OBJECT_ID('Konserwator_Specjalizacja', 'U') IS NOT NULL DROP TABLE Konserwator_Specjalizacja;
IF OBJECT_ID('Raport_z_Konserwacji', 'U') IS NOT NULL DROP TABLE Raport_z_Konserwacji;
IF OBJECT_ID('Konserwacja', 'U') IS NOT NULL DROP TABLE Konserwacja;
IF OBJECT_ID('Zlecenie_Konserwacji', 'U') IS NOT NULL DROP TABLE Zlecenie_Konserwacji;
IF OBJECT_ID('Przeglad_Techniczny', 'U') IS NOT NULL DROP TABLE Przeglad_Techniczny;
IF OBJECT_ID('Zabytek', 'U') IS NOT NULL DROP TABLE Zabytek;
IF OBJECT_ID('Opiekun', 'U') IS NOT NULL DROP TABLE Opiekun;
IF OBJECT_ID('Konserwator', 'U') IS NOT NULL DROP TABLE Konserwator;
IF OBJECT_ID('Firma_Konserwatorska', 'U') IS NOT NULL DROP TABLE Firma_Konserwatorska;
IF OBJECT_ID('Specjalizacja', 'U') IS NOT NULL DROP TABLE Specjalizacja;
IF OBJECT_ID('Miasto', 'U') IS NOT NULL DROP TABLE Miasto;

CREATE TABLE Miasto (
    id INT PRIMARY KEY,
    nazwa NVARCHAR(30) NOT NULL CHECK (LEN(nazwa) >= 3),
    wojewodztwo NVARCHAR(19) NOT NULL CHECK (LEN(wojewodztwo) >= 7),
    UNIQUE (nazwa, wojewodztwo)
);

CREATE TABLE Opiekun (
    id INT PRIMARY KEY,
    imie NVARCHAR(30) NOT NULL CHECK (LEN(imie) >= 3),
    nazwisko NVARCHAR(30) NOT NULL CHECK (LEN(nazwisko) >= 3),
    numer_telefonu CHAR(11) NOT NULL CHECK (ISNUMERIC(numer_telefonu) = 1),
    adres_email NVARCHAR(40) NOT NULL CHECK (adres_email LIKE '%@%.com'),
    UNIQUE (numer_telefonu),
    UNIQUE (adres_email)
);

CREATE TABLE Zabytek (
    id INT PRIMARY KEY,
    nazwa NVARCHAR(30) NOT NULL CHECK (LEN(nazwa) >= 3),
    znajduje_sie_w INT NOT NULL,
    opiekuje_sie INT NOT NULL,
    FOREIGN KEY (znajduje_sie_w) REFERENCES Miasto(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    FOREIGN KEY (opiekuje_sie) REFERENCES Opiekun(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    UNIQUE (nazwa)
);

CREATE TABLE Firma_Konserwatorska (
    id INT PRIMARY KEY,
    nazwa NVARCHAR(30) NOT NULL CHECK (LEN(nazwa) >= 1),
    numer_telefonu CHAR(11) NOT NULL CHECK (ISNUMERIC(numer_telefonu) = 1),
    adres_email NVARCHAR(40) NOT NULL CHECK (adres_email LIKE '%@%.com'),
    UNIQUE (numer_telefonu),
    UNIQUE (adres_email)
);

CREATE TABLE Konserwator (
    id INT PRIMARY KEY,
    imie NVARCHAR(30) NOT NULL CHECK (LEN(imie) >= 3),
    nazwisko NVARCHAR(30) NOT NULL CHECK (LEN(nazwisko) >= 3),
    zatrudnia INT NOT NULL,
    FOREIGN KEY (zatrudnia) REFERENCES Firma_Konserwatorska(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

CREATE TABLE Specjalizacja (
    id INT PRIMARY KEY,
    nazwa NVARCHAR(30) NOT NULL CHECK (LEN(nazwa) >= 3),
    UNIQUE (nazwa)
);

CREATE TABLE Zlecenie_Konserwacji (
    id INT PRIMARY KEY,
    data_wystawienia DATE NOT NULL,
    planowana_data_rozpoczecia DATE NOT NULL,
    planowana_data_zakonczenia DATE NOT NULL,
    zlecono INT NOT NULL,
    wykonuje_konserwacje INT NOT NULL,
    FOREIGN KEY (zlecono) REFERENCES Zabytek(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    FOREIGN KEY (wykonuje_konserwacje) REFERENCES Konserwator(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

CREATE TABLE Konserwacja (
    id INT PRIMARY KEY,
    data_rozpoczecia DATE NOT NULL,
    data_zakonczenia DATE NULL,
    koszt DECIMAL(10, 2) NOT NULL CHECK (koszt > 0),
    przypisane_zlecenie INT NOT NULL,
    FOREIGN KEY (przypisane_zlecenie) REFERENCES Zlecenie_Konserwacji(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

CREATE TABLE Raport_z_Konserwacji (
    id INT PRIMARY KEY,
    data_wystawienia DATE NOT NULL,
    opis_wykonywanej_pracy NVARCHAR(300) NULL,
    zalecenia NVARCHAR(300) NULL,
    generuje_raport INT NOT NULL,
    FOREIGN KEY (generuje_raport) REFERENCES Konserwacja(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

CREATE TABLE Konserwator_Specjalizacja (
    konserwator_id INT NOT NULL,
    specjalizacja_id INT NOT NULL,
    PRIMARY KEY (konserwator_id, specjalizacja_id),
    FOREIGN KEY (konserwator_id) REFERENCES Konserwator(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE,
    FOREIGN KEY (specjalizacja_id) REFERENCES Specjalizacja(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);

CREATE TABLE Przeglad_Techniczny (
    id INT PRIMARY KEY,
    data_przeprowadzenia DATE NOT NULL,
    stan_zabytku INT NOT NULL CHECK (stan_zabytku BETWEEN 1 AND 10),
    dotyczy INT NOT NULL,
    FOREIGN KEY (dotyczy) REFERENCES Zabytek(id) 
		ON UPDATE CASCADE 
		ON DELETE CASCADE
);
