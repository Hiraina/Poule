package ferme.volaille;

import bean.ClassFille;
import bean.ClassMAPTable;
import bean.CGenUtil;
import java.sql.Connection;

public class ReceptVolCourDet extends ClassFille {
    private String id;
    private String idMere;
    private String idParquet;
    private double effectif;
    private String sexes;
    private int echelleSante;
    private int statut;
    private double nbMort;
    private double nbPerdu;
    private int ageVolaille;

    public ReceptVolCourDet() throws Exception {
        this.setNomTable("RECEPT_VOL_COUR_DET");
        this.setNomClasseMere("ferme.volaille.ReceptVolCour");
        this.setLiaisonMere("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("RVCD", "GETSEQ_RECEPTVOLCOURDET");
        this.setId(this.makePK(c));
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        // Contrôle : si statut >= 11, refus modification
        if (this.getStatut() >= 11) {
            throw new Exception("Cette ligne est déjà validée, modification impossible");
        }
        if (this.getEchelleSante() < 1 || this.getEchelleSante() > 10) {
            throw new Exception("L'échelle de santé doit être comprise entre 1 et 10");
        }

        // Contrôle : capacité du parquet
        if (this.getIdParquet() != null && !this.getIdParquet().isEmpty()) {
            ParquetVolaille parquet = new ParquetVolaille();
            parquet.setId(this.getIdParquet());
            ParquetVolaille[] parquets = (ParquetVolaille[]) CGenUtil.rechercher(parquet, null, null, c, "");
            if (parquets != null && parquets.length > 0) {
                double capacite = parquets[0].getCapaciteMax();
                // Calculer l'effectif déjà dans le parquet
                ReceptVolCourDet[] existants = (ReceptVolCourDet[]) CGenUtil.rechercher(
                    new ReceptVolCourDet(), null, null, c, " and idparquet='" + this.getIdParquet().replace("'", "''") + "'");
                double deja = 0;
                for (ReceptVolCourDet e : existants) {
                    if (this.getId() == null || !this.getId().equals(e.getId())) {
                        deja += e.getEffectif();
                    }
                }
                if (deja + this.getEffectif() > capacite) {
                    throw new Exception("Capacité du parquet dépassée : " + deja + " + " + this.getEffectif() + " > " + capacite);
                }

                // Contrôle : âge autorisé
                if (parquets[0].getAgeAutorise() > 0 && this.getAgeVolaille() > 0) {
                    if (this.getAgeVolaille() != parquets[0].getAgeAutorise()) {
                        throw new Exception("L'âge " + this.getAgeVolaille() + " ne correspond pas à l'âge autorisé " + parquets[0].getAgeAutorise() + " pour ce parquet");
                    }
                }

                // Contrôle : sexes autorisé
                if (parquets[0].getSexeAutorise() != null && !parquets[0].getSexeAutorise().trim().isEmpty()) {
                    if (this.getSexes() == null || !parquets[0].getSexeAutorise().equalsIgnoreCase(this.getSexes())) {
                        throw new Exception("Le sexes " + this.getSexes() + " ne correspond pas au sexes autorisé " + parquets[0].getSexeAutorise() + " pour ce parquet");
                    }
                }
            }
        }

        return super.createObject(u, c);
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdMere() { return idMere; }
    public void setIdMere(String idMere) { this.idMere = idMere; }
    public String getIdParquet() { return idParquet; }
    public void setIdParquet(String idParquet) { this.idParquet = idParquet; }
    public double getEffectif() { return effectif; }
    public void setEffectif(double effectif) { this.effectif = effectif; }
    public String getSexes() { return sexes; }
    public void setSexes(String sexes) { this.sexes = sexes; }
    public int getEchelleSante() { return echelleSante; }
    public void setEchelleSante(int echelleSante) { this.echelleSante = echelleSante; }
    public int getStatut() { return statut; }
    public void setStatut(int statut) { this.statut = statut; }
    public double getNbMort() { return nbMort; }
    public void setNbMort(double nbMort) { this.nbMort = nbMort; }
    public double getNbPerdu() { return nbPerdu; }
    public void setNbPerdu(double nbPerdu) { this.nbPerdu = nbPerdu; }
    public int getAgeVolaille() { return ageVolaille; }
    public void setAgeVolaille(int ageVolaille) { this.ageVolaille = ageVolaille; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String getNomClasseMere() { return "ferme.volaille.ReceptVolCour"; }

    @Override
    public String getLiaisonMere() { return "idMere"; }
}
