package ferme.volaille;

import bean.CGenUtil;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;

import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;
import java.util.Locale;

public class EclosionCalendrier {
    String[] listeMois;
    HashMap<String, Map<String, List<EclosionJourDetail>>> eclosionMensuels;
    String[] listeDate;
    HashMap<String, Vector> reservations;
    int[] jours;
    HashMap<String, Double[]> total = new HashMap<>();

    public EclosionCalendrier(String dtMin, String dtMax) throws Exception {
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            this.jours = new int[31];
            for (int i = 0; i < 31; i++) {
                jours[i] = i + 1;
            }
            this.setListeDate(dtMin, dtMax);
            this.setReservations(dtMin, dtMax, c);
            this.setEclosionMensuels();
            this.setTotal();
        } catch (Exception e) {
            throw e;
        } finally {
            if (c != null) c.close();
        }
    }

    public int[] getJours() { return jours; }
    public void setJours(int[] jours) { this.jours = jours; }

    public String[] getListeDate() { return listeDate; }
    public void setListeDate(String dtMin, String dtMax) {
        int day = Utilitaire.diffJourDaty(dtMax, dtMin);
        String[] liste = new String[day];
        for (int i = 0; i < day; i++) {
            liste[i] = Utilitaire.formatterDaty(Utilitaire.ajoutJourDate(dtMin, i));
        }
        this.listeDate = liste;
    }

    public HashMap<String, Vector> getReservations() { return reservations; }

    public void setReservations(String dMin, String dMax, Connection c) throws Exception {
        EclosionJourDetail res = new EclosionJourDetail();
        if (dMin == null || dMin.compareToIgnoreCase("") == 0)
            dMin = Utilitaire.formatterDaty(Utilitaire.getDebutSemaine(Utilitaire.dateDuJourSql()));
        String[] colInt = {"daty"};
        String[] valInt = {dMin, dMax};
        this.reservations = CGenUtil.rechercher2D(res, colInt, valInt, "daty", c, "");
    }
    
    public HashMap<String, Map<String, List<EclosionJourDetail>>> getEclosionMensuels() {
        return eclosionMensuels;
    }

    public void setEclosionMensuels(
            HashMap<String, Map<String, List<EclosionJourDetail>>> eclosionMensuels) {
        this.eclosionMensuels = eclosionMensuels;
    }

    public void setEclosionMensuels() {
        this.eclosionMensuels = fusionParMois(this.getReservations());
        this.listeMois = genererTousLesMois();
        for (String mois : listeMois) {
            if (!eclosionMensuels.containsKey(mois)) {
                eclosionMensuels.put(mois, new HashMap<>());
            }
        }
    }

    private String[] genererTousLesMois() {
        if (listeDate == null || listeDate.length == 0) {
            return new String[]{};
        }
        DateTimeFormatter inputFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.FRANCE);
        LinkedHashMap<String, Boolean> moisMap = new LinkedHashMap<>();
        LocalDate debut = LocalDate.parse(listeDate[0], inputFormat);
        LocalDate fin = LocalDate.parse(listeDate[listeDate.length - 1], inputFormat);
        LocalDate courant = debut;
        while (!courant.isAfter(fin)) {
            String cleMois = courant.getMonth().getDisplayName(TextStyle.FULL, Locale.FRANCE)
                    + " " + courant.getYear();
            moisMap.putIfAbsent(cleMois, true);
            courant = courant.plusMonths(1).withDayOfMonth(1);
        }
        return moisMap.keySet().toArray(new String[]{});
    }

    public HashMap<String, Map<String, List<EclosionJourDetail>>> fusionParMois(
            HashMap<String, Vector> caJour) {
        HashMap<String, Map<String, List<EclosionJourDetail>>> resultat = new LinkedHashMap<>();
        DateTimeFormatter inputFormat = DateTimeFormatter.ofPattern("dd/MM/yyyy", Locale.FRANCE);
        for (String dateStr : listeDate) {
            Vector valeursJour = caJour.get(dateStr);
            if (valeursJour != null) {
                LocalDate date = LocalDate.parse(dateStr, inputFormat);
                String cleMois = date.getMonth().getDisplayName(TextStyle.FULL, Locale.FRANCE)
                        + " " + date.getYear();
                String cleJour = String.valueOf(date.getDayOfMonth());
                resultat.putIfAbsent(cleMois, new HashMap<>());
                resultat.get(cleMois).putIfAbsent(cleJour, new ArrayList<>());
                resultat.get(cleMois).get(cleJour).addAll(valeursJour);
            }
        }
        return resultat;
    }

    public void setTotal() {
        this.total = new HashMap<>();
        for (String dt : listeMois) {
            double oeufsTotal = 0;
            double poussinsTotal = 0;
            int count = 0;
            Map<String, List<EclosionJourDetail>> caJours = this.eclosionMensuels.get(dt);
            for (Map.Entry<String, List<EclosionJourDetail>> entry : caJours.entrySet()) {
                List<EclosionJourDetail> v = entry.getValue();
                if (v != null) {
                    for (EclosionJourDetail res : v) {
                        oeufsTotal += res.getOeufsMisIncubateur();
                        poussinsTotal += res.getPoussinsEclos();
                    }
                    count += v.size();
                }
            }
            double taux = count > 0 && oeufsTotal > 0 ? (poussinsTotal / oeufsTotal) * 100 : 0;
            total.put(dt, new Double[]{oeufsTotal, poussinsTotal, taux});
        }
    }

    public HashMap<String, Double[]> getTotal() { return total; }

    public String[] getListeMois() { return listeMois; }
    public void setListeMois(String[] listeMois) { this.listeMois = listeMois; }

    public EclosionJourDetail[] getReservationByTime(int jour, String mois) throws Exception {
        List<EclosionJourDetail> res = this.eclosionMensuels.get(mois).get(String.valueOf(jour));
        if (res == null) {
            return null;
        }
        return res.toArray(new EclosionJourDetail[]{});
    }
}