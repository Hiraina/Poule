package ferme.volaille;

import bean.ClassFille;
import bean.ClassMAPTable;
import bean.ClassMere;
import bean.CGenUtil;
import java.sql.Connection;
import java.sql.Date;

public class ReceptVolCour extends ClassMere {
    private String id;
    private String idReceptAeroport;
    private Date daty;
    private int etat;

    public ReceptVolCour() throws Exception {
        this.setNomTable("RECEPT_VOL_COUR");
        this.setNomClasseFille("ferme.volaille.ReceptVolCourDet");
        this.setLiaisonFille("idMere");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("RVC", "GETSEQ_RECEPTVOLCOUR");
        this.setId(this.makePK(c));
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        // Contrôle : somme des effectifs des fille = vivants reçus (de l'aéroport)
        // On utilise les données de la réception aéroport
        ClassFille[] filles = this.getFille();
        if (filles != null && this.getIdReceptAeroport() != null) {
            double somme = 0;
            for (ClassFille f : filles) {
                if (f instanceof ReceptVolCourDet) {
                    ReceptVolCourDet d = (ReceptVolCourDet) f;
                    somme += d.getEffectif();
                }
            }
            // Récupérer les vivants de l'aéroport
            ReceptVolAeroport aero = new ReceptVolAeroport();
            aero.setId(this.getIdReceptAeroport());
            ReceptVolAeroport[] aeros = (ReceptVolAeroport[]) CGenUtil.rechercher(aero, null, null, c, "");
            if (aeros != null && aeros.length > 0) {
                double vivantsM = aeros[0].getNbVivantM();
                double vivantsF = aeros[0].getNbVivantF();
                double totalVivants = vivantsM + vivantsF;
                if (somme != totalVivants) {
                    throw new Exception("La somme des effectifs (" + somme + ") ne correspond pas aux vivants reçus (" + totalVivants + ")");
                }
            }
        }
        return super.createObject(u, c);
    }

    // Getters / Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdReceptAeroport() { return idReceptAeroport; }
    public void setIdReceptAeroport(String idReceptAeroport) { this.idReceptAeroport = idReceptAeroport; }
    public Date getDaty() { return daty; }
    public void setDaty(Date daty) { this.daty = daty; }
    public int getEtat() { return etat; }
    public void setEtat(int etat) { this.etat = etat; }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }
}