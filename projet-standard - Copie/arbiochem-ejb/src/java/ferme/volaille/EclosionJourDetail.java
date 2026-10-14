package ferme.volaille;

import bean.ClassMAPTable;

import java.sql.Date;

public class EclosionJourDetail extends ClassMAPTable {
    Date daty;
    int jour, mois, annee;
    String jourLib;
    double oeufsMisIncubateur;
    double poussinsEclos;
    double tauxEclosion;

    public EclosionJourDetail() {
        this.setNomTable("ECLOSION_JOUR_DETAIL");
    }

    @Override
    public String getTuppleID() {
        return "";
    }

    @Override
    public String getAttributIDName() {
        return "";
    }

    public Date getDaty() { return daty; }
    public void setDaty(Date daty) { this.daty = daty; }
    public int getJour() { return jour; }
    public void setJour(int jour) { this.jour = jour; }
    public int getMois() { return mois; }
    public void setMois(int mois) { this.mois = mois; }
    public int getAnnee() { return annee; }
    public void setAnnee(int annee) { this.annee = annee; }
    public String getJourLib() { return jourLib; }
    public void setJourLib(String jourLib) { this.jourLib = jourLib; }
    public double getOeufsMisIncubateur() { return oeufsMisIncubateur; }
    public void setOeufsMisIncubateur(double oeufsMisIncubateur) { this.oeufsMisIncubateur = oeufsMisIncubateur; }
    public double getPoussinsEclos() { return poussinsEclos; }
    public void setPoussinsEclos(double poussinsEclos) { this.poussinsEclos = poussinsEclos; }
    public double getTauxEclosion() { return tauxEclosion; }
    public void setTauxEclosion(double tauxEclosion) { this.tauxEclosion = tauxEclosion; }
}