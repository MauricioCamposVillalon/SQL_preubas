-- Parte 2 - Creando el modelo en la base de datos
-- 1. Crear el modelo en una base de datos llamada biblioteca, considerando las tablas
--   definidas y sus atributos. (2 puntos).

--Creacion base de datos
CREATE DATABASE desafio_biblioteca;

-- Creacion de tablas & atributos --
CREATE TABLE region (
	id SERIAL PRIMARY KEY,
	nombre VARCHAR(30)
);

CREATE TABLE comuna (
	id_comuna SERIAL PRIMARY KEY,
	id_region INT NOT NULL,
	nombre VARCHAR(30) NOT NULL,
	FOREIGN KEY (id_region) REFERENCES region(id)
);

CREATE TABLE direccion (
	id SERIAL PRIMARY KEY,
	id_comuna INT NOT NULL,
	calle VARCHAR(45) NOT NULL,
	FOREIGN KEY (id_comuna) REFERENCES comuna(id_comuna)
);

CREATE TABLE socio (
	id_socio SERIAL PRIMARY KEY,
	id_direccion INT NOT NULL,
	rut  VARCHAR(10) NOT NULL,
	nombre VARCHAR(30) NOT NULL,
	apellido VARCHAR (30) NOT  NULL,
	telefono INT,
	FOREIGN KEY (id_direccion) REFERENCES direccion(id)
);

CREATE TABLE libro (
	id_libro SERIAL PRIMARY KEY,
	isbn VARCHAR(13) NOT NULL,
	titulo VARCHAR(30) NOT NULL,
	pagina INT NOT NULL
);

CREATE TABLE prestamo (
	id_prestamo SERIAL PRIMARY KEY,
	id_socio INT NOT NULL,
	id_libro INT NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_devolucion DATE,
	FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
	FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
);


CREATE TABLE tipo_autor (
	id_tipo SERIAL PRIMARY KEY,
	nombre VARCHAR(10) NOT NULL
);

CREATE TABLE autor(
	id_autor SERIAL PRIMARY KEY,
	nombre VARCHAR(30) NOT NULL,
	apellido VARCHAR(30) NOT NULL,
	fecha_nacimiento DATE NOT NULL,
	fecha_defuncion DATE
);

CREATE TABLE libro_autor(
	id_libro INT NOT NULL,
	id_autor INT NOT NULL,
	id_tipo_autor INT NOT NULL,
	FOREIGN KEY (id_libro) REFERENCES libro(id_libro),
	FOREIGN KEY (id_autor) REFERENCES autor(id_autor),
	FOREIGN KEY (id_tipo_autor) REFERENCES tipo_autor(id_tipo)
);

-- 2. Se deben insertar los registros en las tablas correspondientes (1 punto).

-- Insercion de datos --
INSERT INTO region(nombre) VALUES
('Metropolitana');
SELECT * FROM region;
-- Ingreso de Comunas -- 
INSERT INTO comuna(id_region,nombre) VALUES
(13, 'Santiago');
SELECT * FROM comuna ;
-- id comuna de Santiago es 1--
-- Inserto datos de direccion -- 
INSERT INTO direccion (id_comuna,calle) VALUES
(1,'Avenida 1'),
(1,'Pasaje 2'),
(1,'Avenida 2'),
(1,'Avenida 3'),
(1,'Pasaje 3');

ALTER TABLE direccion DROP COLUMN numeracion;
-- Se elimina columna numeracion ya que no influye en esta prueba --

-- Ingreso datos Socio ---
-- Para cambiar propiedad de una columna ALTER TABLE socio ALTER COLUMN rut TYPE varchar(10);

INSERT INTO socio (id_direccion,rut,nombre,apellido,telefono) VALUES
(1,'11111111-1','Juan','Soto',911111111),
(2,'22222222-2','Ana','Pérez',922222222),
(3,'33333333-3','Sandra','Aguilar',933333333),
(4,'44444444-4','Esteban','Jerez',944444444),
(5,'55555555-5','Silvana','Muñoz',955555555);
SELECT * FROM socio;

--ingreso tipo socio ---
INSERT INTO tipo_autor (nombre) VALUES
('Principal'),
('Coautor');

SELECT * FROM tipo_autor;

-- Ingreso datos Libro --
INSERT INTO libro (isbn,titulo,pagina) VALUES
('1111111111111','Cuentos de Terror',344),
('2222222222222','Poesias contemporaneas',167),
('3333333333333','Historia de ASIA',511),
('4444444444444','Manual de mecánica',298);

Select * FROM libro;

-- Ingreso datos Autor --

INSERT INTO autor (id_autor,nombre,apellido,fecha_nacimiento,fecha_defuncion) VALUES
(3,'Jose','Salgado','1968/01/01','2020/12/31'),
(4,'Ana','Salgado','1972/01/01',NULL),
(1,'Andres','Ulloa','1982/01/01',NULL),
(2,'Sergio','Mardones','1950/01/01','2012/12/31'),
(5,'Martin','Porta','1976/01/01',NULL);

-- Insertar datos en libro autor --
INSERT INTO libro_autor (id_libro,id_autor,id_tipo_autor) VALUES
(1,3,1),
(1,4,2),
(2,1,1),
(3,2,1),
(4,5,1);

SELECT * FROM libro_autor;
CREATE TABLE prestamo (
	id_prestamo SERIAL PRIMARY KEY,
	id_socio INT NOT NULL,
	id_libro INT NOT NULL,
	fecha_inicio DATE NOT NULL,
	fecha_devolucion DATE,
	FOREIGN KEY (id_socio) REFERENCES socio(id_socio),
	FOREIGN KEY (id_libro) REFERENCES libro(id_libro)
);


INSERT INTO prestamo (id_socio,id_libro,fecha_inicio,fecha_devolucion) VALUES
(1,1,'2020/01/20','2020/01/27'),
(5,2,'2020/01/20','2020/01/30'),
(3,3,'2020/01/22','2020/01/30'),
(4,4,'2020/01/23','2020/01/30'),
(2,1,'2020/01/27','2020/02/04'),
(1,4,'2020/01/31','2020/02/12'),
(3,2,'2020/01/31','2020/02/12');

--              Parte 2 - Creando el modelo en la base de datos     --
-- 3. Realizar las siguientes consultas:

--		(a) Mostrar todos los libros que posean  menos de 300 páginas --
SELECT titulo As nombre_libro, pagina FROM libro where pagina < 300;

--		(b) Mostrar todos los autores que hayan nacido despues del 01-01-1970.
SELECT concat(nombre,' ',apellido)AS Nombre_autor, extract(year FROM fecha_nacimiento) AS año_nacimiento
	FROM autor WHERE fecha_nacimiento >=('1970/01/01'::date);

--		(c) ¿Cual es el Libro mas solicitado ?

SELECT li.titulo, count(p.id_libro)as mayor FROM libro li INNER JOIN prestamo p 
	ON p.id_libro = li.id_libro
	GROUP BY li.titulo, p.id_libro ORDER BY mayor desc LIMIT 1;
	
--		(d) Si se cobrara una multa de $100 por cada día de atraso, mostrar cuánto
--    		debería pagar cada usuario que entregue el préstamo después de 7 días.

SELECT concat(s.nombre,' ',s.apellido)AS nombre_usuario,
	((p.fecha_devolucion::date-p.fecha_inicio::date) - 7 ) AS dias_de_atraso,
	(((p.fecha_devolucion::date-p.fecha_inicio::date) - 7 )*100 )AS Valor_atraso 
	FROM socio s INNER JOIN prestamo p ON s.id_socio=p.id_socio 
	WHERE ((p.fecha_devolucion::date-p.fecha_inicio::date) - 7 ) >=1;


SELECT * FROM prestamo;
Select * FROM autor;
Select * FROM libro;
SELECT * FROM tipo_autor;
SELECT * from socio;
SELECT * FROM direccion;
-- 179
select * from comuna;

-- llamada tabla libros --
SELECT li.isbn, li.titulo, li.pagina AS cant_de_paginas, au.id_autor,au.nombre,au.apellido,
		concat((extract (year from au.fecha_nacimiento)),'  --  ',(extract(year from au.fecha_defuncion)))AS Nacimiento_Muerte,ta.nombre AS tipo_autor
		FROM libro li inner join libro_autor la on li.id_libro=la.id_libro
		inner join autor au on au.id_autor = la.id_autor
		inner join tipo_autor ta on ta.id_tipo = la.id_tipo_autor
		
-- Datos Socios
SELECT so.rut, so.nombre, so.apellido, concat(d.calle,', ',c.nombre)AS direccion,so.telefono FROM socio so
		inner join direccion d on d.id = so.id_direccion
		inner join comuna c on c.id_comuna = d.id_comuna
		
