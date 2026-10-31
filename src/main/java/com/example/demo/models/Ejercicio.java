package com.example.demo.models;

import jakarta.persistence.*;
import com.fasterxml.jackson.annotation.JsonIgnore;

@Entity
@Table(name = "ejercicios")
public class Ejercicio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nombre;
    private Integer series;
    private Integer reps;

    @ManyToOne
    @JoinColumn(name = "rutina_id")
    @JsonIgnore // ¡CRUCIAL! Evita el error de bucle infinito al devolver el JSON a Flutter
    private Rutina rutina;

    // Getters y Setters OBLIGATORIOS
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    
    public Integer getSeries() { return series; }
    public void setSeries(Integer series) { this.series = series; }
    
    public Integer getReps() { return reps; }
    public void setReps(Integer reps) { this.reps = reps; }
    
    public Rutina getRutina() { return rutina; }
    public void setRutina(Rutina rutina) { this.rutina = rutina; }
}