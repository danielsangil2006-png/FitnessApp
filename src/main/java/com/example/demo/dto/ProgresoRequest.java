package com.example.demo.dto;

public class ProgresoRequest {
    private Long rutinaId;
    private int duracionSegundos;
    private double pesoTotalLevantado;

    // Getters y Setters
    public Long getRutinaId() { return rutinaId; }
    public void setRutinaId(Long rutinaId) { this.rutinaId = rutinaId; }
    public int getDuracionSegundos() { return duracionSegundos; }
    public void setDuracionSegundos(int duracionSegundos) { this.duracionSegundos = duracionSegundos; }
    public double getPesoTotalLevantado() { return pesoTotalLevantado; }
    public void setPesoTotalLevantado(double pesoTotalLevantado) { this.pesoTotalLevantado = pesoTotalLevantado; }
}