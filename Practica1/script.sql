CREATE DATABASE BD2_practica1;

USE BD2_practica1;

CREATE TABLE PACIENTE (
    idPaciente INT PRIMARY KEY,
    edad INT,
    genero VARCHAR(20)
);

CREATE TABLE HABITACION (
    idHabitacion INT PRIMARY KEY,
    habitacion VARCHAR(50)
);

CREATE TABLE LOG_HABITACION (
    timestampx VARCHAR(100) PRIMARY KEY,
    statusx VARCHAR(45),
    idHabitacion INT,
    FOREIGN KEY (idHabitacion) REFERENCES HABITACION(idHabitacion)
);


CREATE TABLE LOG_ACTIVIDAD (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestampx VARCHAR(100),
    actividad VARCHAR(500),
    paciente INT,
    habitacion INT,
    FOREIGN KEY (paciente) REFERENCES PACIENTE(idPaciente),
    FOREIGN KEY (habitacion) REFERENCES HABITACION(idHabitacion)
    
);