package ferme.volaille;

import bean.ClassMAPTable;
import bean.ClassMere;
import bean.CGenUtil;
import java.sql.Connection;
import java.sql.Date;

public class MortVolaille extends ClassMere {
    private String id;
    private Date daty;
    private String idLot;
    private String idBatiment;
    private String idParquet;
    private double nbMort;
    private double nbPerdu;
    private int etat;

    public MortVolaille() throws Exception {
        this.setNomTable("MORT_VOLAILLE");
        this.setNomClasseFille("ferme.volaille.MortVolailleDet");
        this.setLiaisonFille("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("MORV", "GETSEQ_MORTVOLAILLE");
        this.setId(this.makePK(c));
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        // Contrôle : somme des détails = totaux
        ClassFille[] filles = this.getFille();
        if (filles != null) {
            double sommeMort = 0, sommePerdu = 0;
            for (ClassFille f : filles) {
                if (f instanceof MortVolailleDet) {
                    MortVolailleDet d = (MortVolailleDet) f;
                    sommeMort += d.getNbMort();
                    sommePerdu += d.getNbPerdu();
                }
            }
            if (sommeMort != this.getNbMort()) {
                throw new Exception("Somme des morts (" + sommeMort + ") ≠ total (" + this.getNbMort() + ")");
            }
            if (sommePerdu != this.getNbPerdu()) {
                throw new Exception("Somme des perdus (" + sommePerdu + ") ≠ total (" + this.getNbPerdu() + ")");
            }
        }
        return super.createObject(u, c);
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public Date getDaty() { return daty; }
    public void setDaty(Date daty) { this.daty = daty; }
    public String getIdLot() { return idLot; }
    public void setIdLot(String idLot) { this.idLot = idLot; }
    public String getIdBatiment() { return idBatiment; }
    public void setIdBatiment(String idBatiment) { this.idBatiment = idBatiment; }
    public String getIdParquet() { return idParquet; }
    public void setIdParquet(String idParquet) { this.idParquet = idParquet; }
    public double getNbMort() { return nbMort; }
    public void setNbMort(double nbMort) { this.nbMort = nbMort; }
    public double getNbPerdu() { return nbPerdu; }
    public void setNbPerdu(double nbPerdu) { this.nbPerdu = nbPerdu; }
    public int getEtat() { return etat; }
    public void setEtat(int etat) { this.etat = etat; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }
}