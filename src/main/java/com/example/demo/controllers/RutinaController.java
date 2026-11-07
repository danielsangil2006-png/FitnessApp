package com.example.demo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import com.example.demo.models.Rutina;
import com.example.demo.repositories.RutinaRepository;

@RestController
@RequestMapping("/api/rutinas")
@CrossOrigin(origins = "*") // Permite que Flutter se conecte sin errores de CORS
public class RutinaController {

    @Autowired
    private RutinaRepository rutinaRepository;

    // 1. Obtener todas las rutinas
    @GetMapping
    public List<Rutina> obtenerTodas() {
        return rutinaRepository.findAll();
    }

    // 2. Obtener detalle de una rutina
    @GetMapping("/{id}")
    public ResponseEntity<Rutina> obtenerPorId(@PathVariable Long id) {
        return rutinaRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // 3. Crear rutina desde el formulario de Flutter
    @PostMapping
    public ResponseEntity<Rutina> crearRutina(@RequestBody Rutina nuevaRutina) {
        try {
            // Vincular cada ejercicio a esta rutina antes de guardar
            if (nuevaRutina.getEjercicios() != null) {
                nuevaRutina.getEjercicios().forEach(ejercicio -> ejercicio.setRutina(nuevaRutina));
            }
            
            Rutina rutinaGuardada = rutinaRepository.save(nuevaRutina);
            return new ResponseEntity<>(rutinaGuardada, HttpStatus.CREATED);
            
        } catch (Exception e) {
            System.out.println("Error al guardar: " + e.getMessage());
            // SOLUCIÓN: Usar el patrón builder de ResponseEntity para evitar ambigüedad con el null
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}