-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-11-2026 a las 14:33:54
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `fitness_app`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ejercicios`
--

CREATE TABLE `ejercicios` (
  `id` bigint(20) NOT NULL,
  `grupo_muscular` varchar(50) DEFAULT NULL,
  `met_valor` double DEFAULT NULL,
  `nombre` varchar(255) DEFAULT NULL,
  `url_video_tecnica` varchar(255) DEFAULT NULL,
  `url_animacion` varchar(500) DEFAULT NULL,
  `reps` int(11) DEFAULT NULL,
  `series` int(11) DEFAULT NULL,
  `rutina_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `ejercicios`
--

INSERT INTO `ejercicios` (`id`, `grupo_muscular`, `met_valor`, `nombre`, `url_video_tecnica`, `url_animacion`, `reps`, `series`, `rutina_id`) VALUES
(1, 'Pecho', 5, 'Press de Banca Plano', 'https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExemllN2xqbnZieDBxNDVsZWVxbWJvd2s5c29scmdrNmxuN2w1dGs2bSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/oCjoFbaqWHqVT2H6NL/giphy.gif', NULL, NULL, NULL, NULL),
(2, 'Piernas', 6, 'Sentadilla Libre en Rack', 'https://ejemplo.com/sentadilla.mp4', NULL, NULL, NULL, NULL),
(3, 'Brazos', 3, 'Curl de Bíceps con Barra EZ', 'https://ejemplo.com/curl_ez.mp4', NULL, NULL, NULL, NULL),
(4, 'Espalda', 4, 'Remo con Mancuernas', 'https://ejemplo.com/remo.mp4', NULL, NULL, NULL, NULL),
(10, NULL, NULL, 'Sentadilla', NULL, NULL, 12, 4, NULL),
(11, NULL, NULL, 'Peso muerto', NULL, NULL, 12, 3, NULL),
(12, NULL, NULL, 'Jalon al pecho', NULL, NULL, 12, 4, 10);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes_chat`
--

CREATE TABLE `mensajes_chat` (
  `id` bigint(20) NOT NULL,
  `contenido` text DEFAULT NULL,
  `fecha` datetime(6) DEFAULT NULL,
  `rol` varchar(255) DEFAULT NULL,
  `usuario_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `mensajes_chat`
--

INSERT INTO `mensajes_chat` (`id`, `contenido`, `fecha`, `rol`, `usuario_id`) VALUES
(1, 'hola', '2026-11-07 02:46:04.000000', 'user', 1),
(2, '¡Hola! Me alegra verte en Kinetix. ¿Qué te trae hoy? ¿Tienes algún objetivo en particular que quieras alcanzar en tu rutina de fitness?', '2026-11-07 02:46:06.000000', 'assistant', 1),
(3, 'hola', '2026-11-07 15:11:55.000000', 'user', 1),
(4, '¡Hola! Me parece que ya nos conocemos. Me parece que tienes una rutina de fitness en marcha. ¿Qué te gustaría hablar sobre? ¿Tienes algún problema o inquietud sobre tu progreso o tus rutinas? Estoy aquí para ayudarte.\n\nPor cierto, he visto tu historial de progresos y pesos. Me parece que has estado trabajando duro. ¿Quieres hablar sobre algún aspecto en particular?', '2026-11-07 15:12:00.000000', 'assistant', 1),
(5, 'hola', '2026-11-07 15:23:16.000000', 'user', 1),
(6, '¡Hola! Me parece que ya estamos en el tercer \"hola\". Estoy aquí para ayudarte con tu rutina de fitness. ¿Quieres hablar sobre algo en particular o simplemente charlar un poco?\n\nRecuerda que estoy aquí para ayudarte a alcanzar tus objetivos de fitness. ¿Tienes algún problema o inquietud sobre tu progreso o tus rutinas? Estoy aquí para ofrecerte consejos y recomendaciones.', '2026-11-07 15:23:22.000000', 'assistant', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `progresos`
--

CREATE TABLE `progresos` (
  `id` bigint(20) NOT NULL,
  `fecha` datetime(6) DEFAULT NULL,
  `rutina_id` bigint(20) NOT NULL,
  `usuario_id` bigint(20) NOT NULL,
  `tiempo_segundos` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `progresos`
--

INSERT INTO `progresos` (`id`, `fecha`, `rutina_id`, `usuario_id`, `tiempo_segundos`) VALUES
(2, NULL, 0, 0, NULL),
(3, '2026-10-31 18:23:34.000000', 7, 1, 8),
(4, '2026-11-06 21:36:57.000000', 5, 1, 1),
(5, '2026-11-06 21:40:46.000000', 8, 1, 4),
(6, '2026-11-06 22:03:18.000000', 5, 1, 1),
(7, '2026-11-07 00:47:10.000000', 10, 1, 17);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `progreso_series`
--

CREATE TABLE `progreso_series` (
  `id` bigint(20) NOT NULL,
  `ejercicio_index` int(11) DEFAULT NULL,
  `numero_serie` int(11) DEFAULT NULL,
  `peso_kg` double DEFAULT NULL,
  `progreso_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `progreso_series`
--

INSERT INTO `progreso_series` (`id`, `ejercicio_index`, `numero_serie`, `peso_kg`, `progreso_id`) VALUES
(1, 0, 1, 0, 5),
(2, 0, 2, 0, 5),
(3, 0, 3, 0, 5),
(4, 0, 1, 15, 7),
(5, 0, 2, 15, 7),
(6, 0, 3, 15, 7),
(7, 0, 4, 10, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rutinas`
--

CREATE TABLE `rutinas` (
  `id` bigint(20) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `nombre` varchar(255) NOT NULL,
  `usuario_id` bigint(20) NOT NULL,
  `activa` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `rutinas`
--

INSERT INTO `rutinas` (`id`, `descripcion`, `nombre`, `usuario_id`, `activa`) VALUES
(9, 'Rutina personalizada', 'Pierna', 1, b'1'),
(10, 'Rutina personalizada', 'Espalda', 1, b'1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rutina_ejercicios`
--

CREATE TABLE `rutina_ejercicios` (
  `id` bigint(20) NOT NULL,
  `repeticiones` int(11) NOT NULL,
  `series` int(11) NOT NULL,
  `ejercicio_id` bigint(20) NOT NULL,
  `rutina_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` bigint(20) NOT NULL,
  `email` varchar(255) NOT NULL,
  `nombre` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `altura` double DEFAULT NULL,
  `edad` int(11) DEFAULT NULL,
  `objetivo_fitness` varchar(255) DEFAULT NULL,
  `peso_actual` double DEFAULT NULL,
  `peso_objetivo` double DEFAULT NULL,
  `sexo` varchar(255) DEFAULT NULL,
  `genero` varchar(255) DEFAULT NULL,
  `objetivos` text DEFAULT NULL,
  `peso` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `email`, `nombre`, `password`, `altura`, `edad`, `objetivo_fitness`, `peso_actual`, `peso_objetivo`, `sexo`, `genero`, `objetivos`, `peso`) VALUES
(1, 'danielsanchezgil21@gmail.com', 'Daniel Sanchez', '10222094', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'abraham@gmail.com', 'Abraham Brito', '123456789', 1.68, 20, 'Ganar Músculo', 80, 75, 'Masculino', NULL, NULL, NULL),
(3, 'h@gmail.com', 'hernan', '123456789', 1.68, 20, NULL, NULL, NULL, NULL, 'Masculino', 'subir a 70', 65);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `ejercicios`
--
ALTER TABLE `ejercicios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FK1qutlfhu4b5utydegnox6jo8l` (`rutina_id`);

--
-- Indices de la tabla `mensajes_chat`
--
ALTER TABLE `mensajes_chat`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `progresos`
--
ALTER TABLE `progresos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `progreso_series`
--
ALTER TABLE `progreso_series`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKg7u74h8yxxwly0wqpxr4dja07` (`progreso_id`);

--
-- Indices de la tabla `rutinas`
--
ALTER TABLE `rutinas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKe3swm1g2oigxudqi4ilyfh8e0` (`usuario_id`);

--
-- Indices de la tabla `rutina_ejercicios`
--
ALTER TABLE `rutina_ejercicios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `FKbh869u4tkw3592vpwxt689ca2` (`ejercicio_id`),
  ADD KEY `FK52eejaujhbbb5rruodotgtp4b` (`rutina_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UKkfsp0s1tflm1cwlj8idhqsad0` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `ejercicios`
--
ALTER TABLE `ejercicios`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `mensajes_chat`
--
ALTER TABLE `mensajes_chat`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `progresos`
--
ALTER TABLE `progresos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `progreso_series`
--
ALTER TABLE `progreso_series`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `rutinas`
--
ALTER TABLE `rutinas`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `rutina_ejercicios`
--
ALTER TABLE `rutina_ejercicios`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `ejercicios`
--
ALTER TABLE `ejercicios`
  ADD CONSTRAINT `FK1qutlfhu4b5utydegnox6jo8l` FOREIGN KEY (`rutina_id`) REFERENCES `rutinas` (`id`);

--
-- Filtros para la tabla `progreso_series`
--
ALTER TABLE `progreso_series`
  ADD CONSTRAINT `FKg7u74h8yxxwly0wqpxr4dja07` FOREIGN KEY (`progreso_id`) REFERENCES `progresos` (`id`);

--
-- Filtros para la tabla `rutinas`
--
ALTER TABLE `rutinas`
  ADD CONSTRAINT `FKe3swm1g2oigxudqi4ilyfh8e0` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `rutina_ejercicios`
--
ALTER TABLE `rutina_ejercicios`
  ADD CONSTRAINT `FK52eejaujhbbb5rruodotgtp4b` FOREIGN KEY (`rutina_id`) REFERENCES `rutinas` (`id`),
  ADD CONSTRAINT `FKbh869u4tkw3592vpwxt689ca2` FOREIGN KEY (`ejercicio_id`) REFERENCES `ejercicios` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
