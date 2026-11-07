package com.example.demo.dto;

public class RutinaEjercicioDTO {
    private Long idEjercicio;
    private String nombreEjercicio;
    private String urlAnimacion;
    private int series;
    private int repeticiones;

    public Long getIdEjercicio() { return idEjercicio; }
    public void setIdEjercicio(Long idEjercicio) { this.idEjercicio = idEjercicio; }

    public String getNombreEjercicio() { return nombreEjercicio; }
    public void setNombreEjercicio(String nombreEjercicio) { this.nombreEjercicio = nombreEjercicio; }

    public String getUrlAnimacion() { return urlAnimacion; }
    public void setUrlAnimacion(String urlAnimacion) { this.urlAnimacion = urlAnimacion; }

    public int getSeries() { return series; }
    public void setSeries(int series) { this.series = series; }

    public int getRepeticiones() { return repeticiones; }
    public void setRepeticiones(int repeticiones) { this.repeticiones = repeticiones; }
}