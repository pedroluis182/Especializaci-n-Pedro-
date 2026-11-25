-- Nivel 1
-- Ejercicio 2
-- Listado de paises que estan generando ventas

USE transactions;

SELECT DISTINCT country FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE declined = 0;

-- Desde cuantos paises se generan las ventas

SELECT COUNT(DISTINCT country) AS cantidad_paises FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE declined = 0;

-- Empresa con mayores ventas promedio

SELECT company_name, AVG(amount) ventas_promedio FROM company c
JOIN transaction t ON c.id = t.company_id
WHERE declined = 0 GROUP BY 1 ORDER BY 2 DESC
LIMIT 1;

-- Ejercicio 3
-- Transacciones realizadas por empresas de alemania

SELECT * FROM transaction
WHERE company_id IN ( SELECT id FROM company
                    WHERE country = 'Germany');
                    
-- Empresas con un amount superior a la media de todas las transacciones

SELECT company_name FROM company WHERE id IN(
SELECT company_id FROM transaction WHERE amount >(
SELECT AVG(amount) FROM transaction));

-- Empresas sin transacciones realizadas

SELECT company_name FROM company WHERE id NOT IN(
SELECT company_id FROM transaction);

-- Ejercicio 4 

CREATE TABLE IF NOT EXISTS credit_card (
id VARCHAR(50) PRIMARY KEY,
iban VARCHAR(50),
pan VARCHAR(50),
pin VARCHAR(50),
cvv VARCHAR(50),
expiring_date VARCHAR(50));

SELECT STR_TO_DATE(expiring_date,'%m/%d/%y')
FROM credit_card;

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

-- Ejercicio 5

UPDATE credit_card
SET iban = " TR323456312213576817699999"
WHERE id = "CcU-2938" ;

SELECT id, iban FROM credit_card
WHERE ID = "CcU-2938";

-- Ejercicio 6

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ("108B1D1D-5B23-A76C-55EF-C568E49A99DD","CcU-9999","b-9999","9999","829.999","-117.999","111.11","0");

INSERT INTO credit_card (id)
VALUES ("CcU-9999");
INSERT INTO company (id)
VALUES ("b-9999");

SELECT * FROM transaction 
WHERE user_id = "9999";

-- Ejercicio 7

ALTER TABLE credit_card
DROP COLUMN pan;

SELECT * FROM credit_card;

-- Ejercicio 8

CREATE DATABASE transactions_2;
USE transactions_2;

CREATE TABLE IF NOT EXISTS european_users ( id INT PRIMARY KEY, name VARCHAR(100), surname VARCHAR(100), phone VARCHAR(50), email VARCHAR(255),
birth_date DATE, country VARCHAR(100), city VARCHAR(100), postal_code VARCHAR(20), address VARCHAR(255), signup_date DATE, user_segment VARCHAR(100),
income_band VARCHAR(50));

CREATE TABLE IF NOT EXISTS american_users ( id INT PRIMARY KEY, name VARCHAR(100), surname VARCHAR(100), phone VARCHAR(50), email VARCHAR(255),
birth_date DATE, country VARCHAR(100), city VARCHAR(100), postal_code VARCHAR(20), address VARCHAR(255), signup_date DATE, user_segment VARCHAR(100),
income_band VARCHAR(50));

CREATE TABLE IF NOT EXISTS companies ( company_id VARCHAR(20) PRIMARY KEY, company_name VARCHAR(255), phone VARCHAR(50), email VARCHAR(255), 
country VARCHAR(100), website VARCHAR(255), merchant_category VARCHAR(100), merchant_price_position VARCHAR(50));

CREATE TABLE IF NOT EXISTS credit_cards ( id VARCHAR(50) PRIMARY KEY, user_id INT, iban VARCHAR(50), pan VARCHAR(30), pin VARCHAR(10),
cvv VARCHAR(10), track1 TEXT, track2 TEXT, expiring_date VARCHAR(20), card_type VARCHAR(50), card_renewal_flag TINYINT);

CREATE TABLE IF NOT EXISTS transactions ( id VARCHAR(50) PRIMARY KEY, card_id VARCHAR(20), business_id VARCHAR(20), timestamp DATETIME,
amount DECIMAL(12,2), declined TINYINT, product_ids TEXT, user_id INT, lat DECIMAL(18,15), longitude DECIMAL(18,15), discount_amount DECIMAL(12,2),
tax_amount DECIMAL(12,2), shipping_amount DECIMAL(12,2), channel VARCHAR(50), campaign_id VARCHAR(100), device_type VARCHAR(50), is_international TINYINT,
decline_reason VARCHAR(255), distance_km DECIMAL(12,2));

CREATE TABLE IF NOT EXISTS products ( id INT PRIMARY KEY, product_name VARCHAR(255), price DECIMAL(10,2), colour VARCHAR(20), weight DECIMAL(10,2),
warehouse_id VARCHAR(20), category VARCHAR(100), brand VARCHAR(100), cost DECIMAL(10,2), launch_date DATE);

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/european_users.csv"
INTO TABLE european_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,@birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y');

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/american_users.csv"
INTO TABLE american_users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,name,surname,phone,email,@birth_date,country,city,postal_code,address,signup_date,user_segment,income_band)
SET birth_date = STR_TO_DATE(@birth_date, '%b %e, %Y');

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id,product_name,@price,colour,weight,warehouse_id,category,brand,@cost,launch_date)
SET
price = REPLACE(@price, '$', ''),
cost = REPLACE(@cost, '$', '');

CREATE TABLE users AS
SELECT *, "america" AS region
FROM american_users
UNION ALL
SELECT *,"europa" AS region
FROM european_users;

DROP TABLE american_users;
DROP TABLE european_users;

ALTER TABLE users ADD PRIMARY KEY (id);
ALTER TABLE transactions ADD CONSTRAINT fk_users FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE transactions ADD CONSTRAINT fk_companies FOREIGN KEY (business_id) REFERENCES companies(company_id);
ALTER TABLE transactions MODIFY COLUMN card_id VARCHAR(50); ALTER TABLE transactions ADD CONSTRAINT fk_credit_cards FOREIGN KEY (card_id) REFERENCES credit_cards(id);

-- Ejercicio 9
-- Usuarios con mas de 80 transacciones

SELECT name, surname FROM users WHERE id IN(
SELECT user_id FROM transactions 
GROUP BY user_id HAVING COUNT(id) > 80);

-- Ejercicio 10
-- Media de amount por iban de la compañia donec ltd

SELECT iban, AVG(amount) AS media_amount
FROM credit_cards c 
JOIN transactions t ON c.id = t.card_id
JOIN companies co ON t.business_id = co.company_id
WHERE company_name = "Donec Ltd"
GROUP BY iban;

-- Nivel 2 
-- Ejercicio 1
-- Cinco dias con mas venta

SELECT DATE(timestamp) AS fecha , SUM(amount) AS ventas_total
FROM transactions
GROUP BY fecha
ORDER BY 2 DESC
LIMIT 5;

-- Ejercicio 2
-- nombre, teléfono, país, fecha y amount, de empresas que realizaron operaciones con un valor comprendido
 -- entre 350 y 400 euros y en cualquiera de estas fechas: 29 de abril de 2015, 20 de julio de 2018 y 13 de marzo de 2024
 
 SELECT company_name, phone, country, timestamp, amount
 FROM companies c
 JOIN transactions t ON c.company_id = t.business_id
 WHERE amount BETWEEN 350 AND 400
 AND DATE(timestamp) IN ("2015-4-29","2018-7-20","2024-3-13");
 
 -- Ejercicio 3
 -- Empresas con 400 transacciones o menos

SELECT c.company_name, COUNT(t.id) AS cantidad_transacciones,
CASE WHEN COUNT(t.id) >= 400 THEN 'Mas 400'
ELSE 'Menos 400'
END AS clasificacion
FROM companies c
LEFT JOIN transactions t ON c.company_id = t.business_id
GROUP BY c.company_id, c.company_name
ORDER BY cantidad_transacciones DESC;
 
 -- Ejercicio 4
 -- Eliminar registro de la base de datos
 
DELETE FROM transactions
WHERE id = "000447FE-B650-4DCF-85DE-C7ED0EE1CAAD";

-- Ejercicio 5
-- Crear una vista con informacion clave de las empresas y sus transacciones

CREATE VIEW vista_marketing AS 
SELECT company_name, phone, country, ROUND(AVG(amount),2) AS media_compras 
FROM companies c
JOIN transactions t ON c.company_id = t.business_id
GROUP BY 1, 2, 3 ORDER BY 4 DESC;

SELECT * FROM vista_marketing;

-- Nivel 3
-- Ejercicio 1
-- Crear una tabla que refleje el estado de las trajetas de credito en 
-- funcion de sus ultimas tres compras si han sido rechazadas

CREATE TABLE estado_tarjeta AS 
SELECT card_id, CASE
WHEN SUM(declined)= 3 THEN "Inactiva"
ELSE "Activa"
END AS estado
FROM (SELECT card_id, declined, ROW_NUMBER() OVER
(PARTITION BY card_id
ORDER BY timestamp DESC) AS numero
FROM transactions) AS compras_numeradas
WHERE numero <=3
GROUP BY card_id;

-- tarjetas activas

SELECT COUNT(*) AS Activas
FROM estado_tarjeta
WHERE estado = "Activa";

-- Ejercicio 2
-- Crea una taula amb la qual puguem unir les dades de l'arxiu de products.csv amb la base de dades creada
-- (ja que fins ara no podíem fer-ho), tenint en compte que des de transaction tens product_ids. Genera la següent consulta:

CREATE TABLE transactions_products AS
SELECT t.id AS transaction_id, p.product_id
FROM transactions t,
JSON_TABLE(CONCAT(
'["',
REPLACE(t.product_ids, ',', '","'),
'"]'),
'$[*]' COLUMNS (product_id INT PATH '$')
) AS p;

SELECT * FROM transactions_products;

ALTER TABLE transactions_products
ADD PRIMARY KEY (transaction_id,product_id);

ALTER TABLE transactions_products ADD CONSTRAINT fk_transactions FOREIGN KEY (transaction_id) REFERENCES transactions(id);
ALTER TABLE transactions_products ADD CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(id);