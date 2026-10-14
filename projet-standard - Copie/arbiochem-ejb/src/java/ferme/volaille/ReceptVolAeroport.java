package ferme.volaille;

import bean.ClassMAPTable;
import bean.ClassMere;
import java.sql.Connection;
import java.sql.Date;

public class ReceptVolAeroport extends ClassMere {
    private String id;
    private String idCmdVolaille;
    private Date daty;
    private double nbTheoM;
    private double nbTheoF;
    private double nbVivantM;
    private double nbVivantF;
    private double nbMortM;
    private double nbMortF;
    private double nbPerduM;
    private double nbPerduF;
    private int etat;

    public ReceptVolAeroport() throws Exception {
        this.setNomTable("RECEPT_VOL_AERO");
        this.setNomClasseFille("ferme.volaille.ReceptVolAeroportDet");
        this.setLiaisonFille("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("RVA", "GETSEQ_RECEPTVOLAERO");
        this.setId(this.makePK(c));
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        // Contrôle : théorique = vivants + morts + perdus (par sexes)
        if (this.getNbTheoM() != (this.getNbVivantM() + this.getNbMortM() + this.getNbPerduM())) {
            throw new Exception("Pour les males : théorique (" + this.getNbTheoM() + ") ≠ vivants+morts+perdus (" + (this.getNbVivantM() + this.getNbMortM() + this.getNbPerduM()) + ")");
        }
        if (this.getNbTheoF() != (this.getNbVivantF() + this.getNbMortF() + this.getNbPerduF())) {
            throw new Exception("Pour les femelles : théorique (" + this.getNbTheoF() + ") ≠ vivants+morts+perdus (" + (this.getNbVivantF() + this.getNbMortF() + this.getNbPerduF()) + ")");
        }
        return super.createObject(u, c);
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdCmdVolaille() { return idCmdVolaille; }
    public void setIdCmdVolaille(String idCmdVolaille) { this.idCmdVolaille = idCmdVolaille; }
    public Date getDaty() { return daty; }
    public void setDaty(Date daty) { this.daty = daty; }
    public double getNbTheoM() { return nbTheoM; }
    public void setNbTheoM(double nbTheoM) { this.nbTheoM = nbTheoM; }
    public double getNbTheoF() { return nbTheoF; }
    public void setNbTheoF(double nbTheoF) { this.nbTheoF = nbTheoF; }
    public double getNbVivantM() { return nbVivantM; }
    public void setNbVivantM(double nbVivantM) { this.nbVivantM = nbVivantM; }
    public double getNbVivantF() { return nbVivantF; }
    public void setNbVivantF(double nbVivantF) { this.nbVivantF = nbVivantF; }
    public double getNbMortM() { return nbMortM; }
    public void setNbMortM(double nbMortM) { this.nbMortM = nbMortM; }
    public double getNbMortF() { return nbMortF; }
    public void setNbMortF(double nbMortF) { this.nbMortF = nbMortF; }
    public double getNbPerduM() { return nbPerduM; }
    public void setNbPerduM(double nbPerduM) { this.nbPerduM = nbPerduM; }
    public double getNbPerduF() { return nbPerduF; }
    public void setNbPerduF(double nbPerduF) { this.nbPerduF = nbPerduF; }
    public int getEtat() { return etat; }
    public void setEtat(int etat) { this.etat = etat; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }
}