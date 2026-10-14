package ferme.volaille;

import bean.ClassFille;
import java.sql.Connection;

public class MortVolailleDet extends ClassFille {
    private String id;
    private String idMere;
    private String idQualitePoussin;
    private String idSexe;
    private double nbMort;
    private double nbPerdu;

    public MortVolailleDet() throws Exception {
        this.setNomTable("MORT_VOLAILLE_DET");
        this.setNomClasseMere("ferme.volaille.MortVolaille");
        this.setLiaisonMere("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("MORD", "GETSEQ_MORTVOLAILLEDET");
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
    public double getNbMort() { return nbMort; }
    public void setNbMort(double nbMort) { this.nbMort = nbMort; }
    public double getNbPerdu() { return nbPerdu; }
    public void setNbPerdu(double nbPerdu) { this.nbPerdu = nbPerdu; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String getNomClasseMere() { return "ferme.volaille.MortVolaille"; }

    @Override
    public String getLiaisonMere() { return "idMere"; }
}