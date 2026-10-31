package com.example.demo.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@RestController
@RequestMapping("/api/videos")
public class VideoController {

    // Carpeta donde se guardarán los videos en tu computadora/servidor
    private static final String UPLOAD_DIR = "uploads/";

    @PostMapping("/subir")
    public ResponseEntity<?> subirVideo(@RequestParam("file") MultipartFile file) {
        try {
            // Crea la carpeta si no existe
            File dir = new File(UPLOAD_DIR);
            if (!dir.exists()) dir.mkdirs();

            // Genera un nombre único usando la fecha actual en milisegundos
            String nombreArchivo = System.currentTimeMillis() + "_" + file.getOriginalFilename();
            Path path = Paths.get(UPLOAD_DIR + nombreArchivo);
            
            // Guarda el archivo
            Files.write(path, file.getBytes());

            return ResponseEntity.ok("Video subido correctamente: " + nombreArchivo);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body("Error al guardar el video");
        }
    }
}