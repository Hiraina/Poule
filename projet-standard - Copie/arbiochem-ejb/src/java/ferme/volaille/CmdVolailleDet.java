package ferme.volaille;

import bean.ClassFille;
import java.sql.Connection;

public class CmdVolailleDet extends ClassFille {
    private String id;
    private String idMere;
    private String idSouche;
    private String race;
    private double effectifM;
    private double effectifF;
    private double pu;

    public CmdVolailleDet() throws Exception {
        this.setNomTable("CMD_VOLAILLE_DET");
        this.setNomClasseMere("ferme.volaille.CmdVolaille");
        this.setLiaisonMere("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("CMDVD", "GETSEQ_CMDVOLAILLEDET");
        this.setId(this.makePK(c));
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdMere() { return idMere; }
    public void setIdMere(String idMere) { this.idMere = idMere; }
    public String getIdSouche() { return idSouche; }
    public void setIdSouche(String idSouche) { this.idSouche = idSouche; }
    public String getRace() { return race; }
    public void setRace(String race) { this.race = race; }
    public double getEffectifM() { return effectifM; }
    public void setEffectifM(double effectifM) { this.effectifM = effectifM; }
    public double getEffectifF() { return effectifF; }
    public void setEffectifF(double effectifF) { this.effectifF = effectifF; }
    public double getPu() { return pu; }
    public void setPu(double pu) { this.pu = pu; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String getNomClasseMere() { return "ferme.volaille.CmdVolaille"; }

    @Override
    public String getLiaisonMere() { return "idMere"; }
}