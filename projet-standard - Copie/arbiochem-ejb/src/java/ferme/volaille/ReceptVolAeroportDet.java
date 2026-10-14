package ferme.volaille;

import bean.ClassFille;
import java.sql.Connection;

public class ReceptVolAeroportDet extends ClassFille {
    private String id;
    private String idMere;
    private String idQualitePoussin;
    private String idSexe;
    private double qte;

    public ReceptVolAeroportDet() throws Exception {
        this.setNomTable("RECEPT_VOL_AERO_DET");
        this.setNomClasseMere("ferme.volaille.ReceptVolAeroport");
        this.setLiaisonMere("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("RVAD", "GETSEQ_RECEPTVOLAERODET");
        this.setId(this.makePK(c));
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdMere() { return idMere; }
    public void setIdMere(String idMere) { this.idMere = idMere; }
    public String getIdQualitePoussin() { return idQualitePoussin; }
    public void setIdQualitePoussin(String idQualitePoussin) { this.idQualitePoussin = idQualitePoussin; }
    public String getIdSexe() { return idSexe; }
    public void setIdSexe(String idSexe) { this.idSexe = idSexe; }
    public double getQte() { return qte; }
    public void setQte(double qte) { this.qte = qte; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String getNomClasseMere() { return "ferme.volaille.ReceptVolAeroport"; }

    @Override
    public String getLiaisonMere() { return "idMere"; }
}