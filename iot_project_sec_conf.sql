-- Tworzenie usera dla aplikacji/device'ow
DROP USER IF EXISTS 'iot2023_user'@'%';
CREATE USER IF NOT EXISTS 'iot2023_user'@'%' IDENTIFIED BY 'iot2023_user' REQUIRE SSL WITH MAX_QUERIES_PER_HOUR 200000 MAX_UPDATES_PER_HOUR 100000 MAX_CONNECTIONS_PER_HOUR 500000 MAX_USER_CONNECTIONS 10;

-- Tworzenie usera dla device'ow
DROP USER IF EXISTS 'iot2023_device'@'%';
CREATE USER IF NOT EXISTS 'iot2023_device'@'%' IDENTIFIED WITH mysql_native_password BY 'iot2023_device' REQUIRE NONE WITH MAX_QUERIES_PER_HOUR 200000 MAX_UPDATES_PER_HOUR 100000 MAX_CONNECTIONS_PER_HOUR 500000 MAX_USER_CONNECTIONS 20;

-- Tworzenie usera admina
DROP USER IF EXISTS 'iot2023_admin'@'%';
CREATE USER IF NOT EXISTS 'iot2023_admin'@'%' IDENTIFIED BY 'iot2023_admin' REQUIRE SSL WITH MAX_QUERIES_PER_HOUR 100 MAX_UPDATES_PER_HOUR 100 MAX_CONNECTIONS_PER_HOUR 1000 MAX_USER_CONNECTIONS 1;

-- Ustawienie ważności (daty ekspiracji hasła) hasła
ALTER USER 'iot2023_user'@'%' PASSWORD EXPIRE INTERVAL 90 DAY;
ALTER USER 'iot2023_device'@'%' PASSWORD EXPIRE INTERVAL 90 DAY;
ALTER USER 'iot2023_admin'@'%' PASSWORD EXPIRE INTERVAL 60 DAY;

-- Ustawienie liczby zmian hasel w przypadku checi ustawienia tego samego hasła
ALTER USER 'iot2023_user'@'%' PASSWORD HISTORY 5;
ALTER USER 'iot2023_device'@'%' PASSWORD HISTORY 5;
ALTER USER 'iot2023_admin'@'%' PASSWORD HISTORY 10;

-- Ustawienie liczby nieprawidlowych prob logowania oraz liczby dni blokady 
ALTER USER 'iot2023_user'@'%' FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1;
ALTER USER 'iot2023_device'@'%' FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 1;
ALTER USER 'iot2023_admin'@'%' FAILED_LOGIN_ATTEMPTS 2 PASSWORD_LOCK_TIME UNBOUNDED;

-- Ustawienie podania starego hasła przy ustawieniu nowego 
ALTER USER 'iot2023_user'@'%' PASSWORD REQUIRE CURRENT;
ALTER USER 'iot2023_device'@'%' PASSWORD REQUIRE CURRENT;
ALTER USER 'iot2023_admin'@'%' PASSWORD REQUIRE CURRENT;

-- Ustawienie zakresu uprawnien do wykonania przez uzytkownikow na bazie 
GRANT SELECT, INSERT, UPDATE, DELETE ON iot_project.* TO 'iot2023_user'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE ON iot_project.* TO 'iot2023_device'@'%';
GRANT ALL ON iot_project.* TO 'iot2023_admin'@'%';

SET PERSIST require_secure_transport=OFF;


