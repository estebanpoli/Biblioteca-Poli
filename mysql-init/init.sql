CREATE DATABASE IF NOT EXISTS biblioteca;
USE biblioteca;

CREATE TABLE IF NOT EXISTS libros (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255),
    autor VARCHAR(255),
    categoria VARCHAR(255),
    cantidad INT
);
INSERT INTO libros (titulo, autor, categoria, cantidad)
VALUES ('Cien años de soledad', 'Gabriel García Márquez', 'Novela', 3);
