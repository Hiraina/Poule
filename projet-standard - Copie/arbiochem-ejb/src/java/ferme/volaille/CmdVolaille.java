package ferme.volaille;

import bean.ClassMAPTable;
import bean.ClassFille;
import bean.ClassMere;
import java.sql.Connection;
import java.sql.Date;

public class CmdVolaille extends ClassMere {
    private String id;
    private Date daty;
    private String fournisseur;
    private String idTypeVolaille;
    private int ageVolaille;
    private double effectifTheoM;
    private double effectifTheoF;
    private int etat;
    private String remarque;

    public CmdVolaille() throws Exception {
        this.setNomTable("CMD_VOLAILLE");
        this.setNomClasseFille("ferme.volaille.CmdVolailleDet");
        this.setLiaisonFille("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("CMDV", "GETSEQ_CMDVOLAILLE");
        this.setId(this.makePK(c));
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        // Contrôle : somme des effectifs des fille = théorique
        ClassFille[] filles = this.getFille();
        if (filles != null) {
            double sommeM = 0, sommeF = 0;
            for (ClassFille f : filles) {
                if (f instanceof CmdVolailleDet) {
                    CmdVolailleDet d = (CmdVolailleDet) f;
                    sommeM += d.getEffectifM();
                    sommeF += d.getEffectifF();
                }
            }
            if (sommeM != this.getEffectifTheoM()) {
                throw new Exception("La somme des effectifs males (" + sommeM + ") ne correspond pas au théorique (" + this.getEffectifTheoM() + ")");
            }
            if (sommeF != this.getEffectifTheoF()) {
                throw new Exception("La somme des effectifs femelles (" + sommeF + ") ne correspond pas au théorique (" + this.getEffectifTheoF() + ")");
            }
        }
        return super.createObject(u, c);
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public Date getDaty() { return daty; }
    public void setDaty(Date daty) { this.daty = daty; }
    public String getFournisseur() { return fournisseur; }
    public void setFournisseur(String fournisseur) { this.fournisseur = fournisseur; }
    public String getIdTypeVolaille() { return idTypeVolaille; }
    public void setIdTypeVolaille(String idTypeVolaille) { this.idTypeVolaille = idTypeVolaille; }
    public int getAgeVolaille() { return ageVolaille; }
    public void setAgeVolaille(int ageVolaille) { this.ageVolaille = ageVolaille; }
    public double getEffectifTheoM() { return effectifTheoM; }
    public void setEffectifTheoM(double effectifTheoM) { this.effectifTheoM = effectifTheoM; }
    public double getEffectifTheoF() { return effectifTheoF; }
    public void setEffectifTheoF(double effectifTheoF) { this.effectifTheoF = effectifTheoF; }
    public int getEtat() { return etat; }
    public void setEtat(int etat) { this.etat = etat; }
    public String getRemarque() { return remarque; }
    public void setRemarque(String remarque) { this.remarque = remarque; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }
}
