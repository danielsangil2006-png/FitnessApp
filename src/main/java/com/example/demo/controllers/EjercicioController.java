package com.example.demo.controllers;

import com.example.demo.models.Ejercicio;
import com.example.demo.repositories.EjercicioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/ejercicios")
@CrossOrigin(origins = "*") // Permite que Flutter se comunique sin bloqueos de seguridad CORS
public class EjercicioController {

    @Autowired
    private EjercicioRepository ejercicioRepository;

    // Flutter usará un método GET para pedir la lista de ejercicios
    @GetMapping
    public List<Ejercicio> obtenerEjercicios() {
        return ejercicioRepository.findAll();
    }

    // Flutter (o tú desde Postman) usará POST para agregar un ejercicio nuevo al catálogo
    @PostMapping
    public Ejercicio crearEjercicio(@RequestBody Ejercicio nuevoEjercicio) {
        return ejercicioRepository.save(nuevoEjercicio);
    }
}