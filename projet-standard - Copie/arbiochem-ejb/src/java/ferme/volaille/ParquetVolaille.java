package ferme.volaille;

import bean.TypeObjet;
import java.sql.Connection;

public class ParquetVolaille extends TypeObjet {
    private String id;
    private String idBatiment;
    private String nom;
    private double capaciteMax;
    private int ageAutorise;
    private String sexesAutorise;

    public ParquetVolaille() {
        super.setNomTable("PARQUET_VOLAILLE");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("PARQUET_VOLAILLE");
        this.preparePk("PV", "GETSEQ_PARQUETVOLAILLE");
        this.setId(this.makePK(c));
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdBatiment() { return idBatiment; }
    public void setIdBatiment(String idBatiment) { this.idBatiment = idBatiment; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public double getCapaciteMax() { return capaciteMax; }
    public void setCapaciteMax(double capaciteMax) { this.capaciteMax = capaciteMax; }
    public int getAgeAutorise() { return ageAutorise; }
    public void setAgeAutorise(int ageAutorise) { this.ageAutorise = ageAutorise; }
    public String getSexeAutorise() { return sexesAutorise; }
    public void setSexeAutorise(String sexesAutorise) { this.sexesAutorise = sexesAutorise; }
}