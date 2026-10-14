package ferme.volaille;

import bean.CGenUtil;
import bean.ClassMAPTable;
import ferme.lot.Lot;
import ferme.lot.LotLib;
import ferme.programme.ProgrammeZootechnique;
import ferme.programme.ProgrammeZootechniqueDetails;
import ferme.programme.ProgrammeZootechniqueDetailsLib;
import utilitaire.UtilDB;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;

public class EclosionJourDetailSync {
    
    public static void synchroniser(Connection c) throws Exception {
        synchroniser(c, null, null);
    }
    
    public static void synchroniser(Connection c, String dtMin, String dtMax) throws Exception {
        if (dtMin == null || dtMin.trim().isEmpty()) {
            dtMin = Utilitaire.formatterDaty(Utilitaire.getDebutSemaine(Utilitaire.dateDuJourSql()));
        }
        if (dtMax == null || dtMax.trim().isEmpty()) {
            dtMax = Utilitaire.formatterDaty(Utilitaire.dateDuJourSql());
        }
        
        // 1. Récupérer les œufs mis en incubateur (prédiction) groupés par dateeclosionprevue
        Map<String, Double> oeufsParDate = getOeufsMisIncubateurParDate(dtMin, dtMax, c);
        
        // 2. Récupérer les poussins éclos (réel) groupés par dateeclosion
        Map<String, Double> poussinsParDate = getPoussinsEclosParDate(dtMin, dtMax, c);
        
        // 3. Fusionner toutes les dates
        Set<String> allDates = new HashSet<>();
        allDates.addAll(oeufsParDate.keySet());
        allDates.addAll(poussinsParDate.keySet());
        
        // 4. Pour chaque date, insérer ou mettre à jour ECLOSION_JOUR_DETAIL
        for (String dateStr : allDates) {
            Double oeufs = oeufsParDate.get(dateStr);
            Double poussins = poussinsParDate.get(dateStr);
            
            if (oeufs == null) oeufs = 0.0;
            if (poussins == null) poussins = 0.0;
            
            double taux = oeufs > 0 ? (poussins / oeufs) * 100 : 0;
            
            // Calculer les valeurs théoriques
            double[] theorique = calculerValeursTheoriquesPourDate(c, dateStr);
            double oeufsTheoriques = theorique[0];
            double poussinsTheoriques = theorique[1];
            double tauxTheorique = theorique[2];
            
            upsertEclosionJourDetail(c, dateStr, oeufs, poussins, taux, oeufsTheoriques, poussinsTheoriques, tauxTheorique);
        }
    }
    
    private static Map<String, Double> getOeufsMisIncubateurParDate(String dMin, String dMax, Connection c) throws Exception {
        Map<String, Double> result = new HashMap<>();
        String sql = "SELECT TO_CHAR(MEI.DATEECLOSIONPREVUE, 'DD/MM/YYYY') as DATY, " +
                     "SUM(MEID.QTE) as TOTAL_OEUFS " +
                     "FROM MISEENINCUBATEUR MEI " +
                     "JOIN MISEENINCUBATEURDETAIL MEID ON MEI.ID = MEID.IDMERE " +
                     "WHERE MEI.DATEECLOSIONPREVUE BETWEEN TO_DATE(?, 'DD/MM/YYYY') AND TO_DATE(?, 'DD/MM/YYYY') " +
                     "GROUP BY MEI.DATEECLOSIONPREVUE";
        
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, dMin);
            ps.setString(2, dMax);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getString("DATY"), rs.getDouble("TOTAL_OEUFS"));
                }
            }
        }
        return result;
    }
    
    private static Map<String, Double> getPoussinsEclosParDate(String dMin, String dMax, Connection c) throws Exception {
        Map<String, Double> result = new HashMap<>();
        String sql = "SELECT TO_CHAR(E.DATEECLOSION, 'DD/MM/YYYY') as DATY, " +
                     "SUM(ED.QTE) as TOTAL_POUSSINS " +
                     "FROM ECLOSION E " +
                     "JOIN ECLOSIONDETAIL ED ON E.ID = ED.IDMERE " +
                     "WHERE E.DATEECLOSION BETWEEN TO_DATE(?, 'DD/MM/YYYY') AND TO_DATE(?, 'DD/MM/YYYY') " +
                     "GROUP BY E.DATEECLOSION";
        
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, dMin);
            ps.setString(2, dMax);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getString("DATY"), rs.getDouble("TOTAL_POUSSINS"));
                }
            }
        }
        return result;
    }
    
    /**
     * Calcule les valeurs théoriques pour une date donnée
     * @return double[3] {oeufsTheoriques, poussinsTheoriques, tauxTheorique}
     */
    private static double[] calculerValeursTheoriquesPourDate(Connection c, String dateStr) throws Exception {
        double oeufsTheoriques = 0;
        double poussinsTheoriques = 0;
        double tauxTheorique = 0;
        
        // Pour obtenir les œufs théoriques qui devraient éclore à cette date,
        // on regarde les œufs mis en incubateur 21 jours auparavant
        LocalDate targetDate = LocalDate.parse(dateStr, DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        LocalDate miseEnIncubeDate = targetDate.minusDays(21);
        String dateMiseEnIncubeStr = Utilitaire.formatterDaty(Date.valueOf(miseEnIncubeDate));
        
        // Récupérer les lots qui ont eu des œufs mis en incubateur à cette date
        Map<String, Double> oeufsParLot = getOeufsMisIncubateurParLotEtDate(c, dateMiseEnIncubeStr, dateMiseEnIncubeStr);
        
        // Pour chaque lot, obtenir son programme zootechnique et calculer les théorèmes
        for (Map.Entry<String, Double> entry : oeufsParLot.entrySet()) {
            String lotId = entry.getKey();
            double oeufsLot = entry.getValue();
            
            try {
                // Obtenir le programme du lot
                Lot lot = new LotLib();
                lot.setId(lotId);
                lot = (Lot) CGenUtil.rechercher(lot, null, null, c, null)[0];
                
                String idProgramme = lot.getIdprogramme();
                if (idProgramme != null && !idProgramme.isEmpty()) {
                    // Obtenir le détail du programme
                    ProgrammeZootechniqueDetails progDetail = new ProgrammeZootechniqueDetailsLib();
                    progDetail.setIdmere(idProgramme);
                    ProgrammeZootechniqueDetails[] details = (ProgrammeZootechniqueDetails[]) CGenUtil.rechercher(progDetail, null, null, c, null);
                    
                    if (details != null && details.length > 0) {
                        ProgrammeZootechniqueDetails detail = details[0]; // Prendre le premier
                        
                        double ponteHebdo = detail.getPontehebdomadaire(); // œufs par semaine
                        double tauxEclosion = detail.getTauxeclosion();    // taux éclosion (0-1)
                        double poussinsParOeuf = detail.getPoussins();    // poussins par œuf
                        
                        // Calcul théorique pour ce lot
                        double oeufsJournalieresLot = oeufsLot; // Déjà journalier depuis la requête
                        double poussinsJournalieresLot = oeufsJournalieresLot * tauxEclosion * poussinsParOeuf;
                        double tauxLot = tauxEclosion * poussinsParOeuf * 100; // En pourcentage
                        
                        // Accumuler
                        oeufsTheoriques += oeufsJournalieresLot;
                        poussinsTheoriques += poussinsJournalieresLot;
                        // Pour le taux moyen, on fait une moyenne pondérée
                        if (oeufsJournalieresLot > 0) {
                            tauxTheorique += tauxLot * oeufsJournalieresLot;
                        }
                    }
                }
            } catch (Exception e) {
                // En cas d'erreur on continue avec les autres lots
                e.printStackTrace();
                continue;
            }
        }
        
        // Calculer le taux moyen pondéré
        if (oeufsTheoriques > 0) {
            tauxTheorique = tauxTheorique / oeufsTheoriques;
        }
        
        return new double[]{oeufsTheoriques, poussinsTheoriques, tauxTheorique};
    }
    
    private static Map<String, Double> getOeufsMisIncubateurParLotEtDate(String dMin, String dMax, Connection c) throws Exception {
        Map<String, Double> result = new HashMap<>();
        String sql = "SELECT L.IDLOT, SUM(MEID.QTE) as TOTAL_OEUFS " +
                     "FROM MISEENINCUBATEUR MEI " +
                     "JOIN MISEENINCUBATEURDETAIL MEID ON MEI.ID = MEID.IDMERE " +
                     "JOIN LOT L ON MEID.IDLOT = L.ID " +
                     "WHERE MEI.DATEECLOSIONPREVUE BETWEEN TO_DATE(?, 'DD/MM/YYYY') AND TO_DATE(?, 'DD/MM/YYYY') " +
                     "GROUP BY L.IDLOT";
        
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, dMin);
            ps.setString(2, dMax);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.put(rs.getString("IDLOT"), rs.getDouble("TOTAL_OEUFS"));
                }
            }
        }
        return result;
    }
    
    private static void upsertEclosionJourDetail(Connection c, String dateStr, double oeufs, double poussins, double taux, 
                                                 double oeufsTheoriques, double poussinsTheoriques, double tauxTheorique) throws Exception {
        // Vérifier si l'enregistrement existe
        String checkSql = "SELECT ID FROM ECLOSION_JOUR_DETAIL WHERE DATY = TO_DATE(?, 'DD/MM/YYYY')";
        String existingId = null;
        
        try (PreparedStatement ps = c.prepareStatement(checkSql)) {
            ps.setString(1, dateStr);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    existingId = rs.getString("ID");
                }
            }
        }
        
        LocalDate ld = LocalDate.parse(dateStr, DateTimeFormatter.ofPattern("dd/MM/yyyy"));
        int jour = ld.getDayOfMonth();
        int mois = ld.getMonthValue();
        int annee = ld.getYear();
        String jourLib = ld.getDayOfWeek().getDisplayName(TextStyle.FULL, Locale.FRANCE);
        
        if (existingId != null) {
            // UPDATE - NOTE: Ceci échouera si les colonnes théoriques n'existent pas encore dans la table
            String updateSql = "UPDATE ECLOSION_JOUR_DETAIL SET " +
                               "JOUR = ?, MOIS = ?, ANNEE = ?, JOURLIB = ?, " +
                               "OEUF_MIS_INCUB = ?, POUSSINS_ECLOS = ?, TAUX_ECLOS = ?, " +
                               "OEUF_THEORIQUE = ?, POUSSINS_THEORIQUE = ?, TAUX_ECLOS_THEORIQUE = ? " +
                               "WHERE ID = ?";
            try (PreparedStatement ps = c.prepareStatement(updateSql)) {
                ps.setInt(1, jour);
                ps.setInt(2, mois);
                ps.setInt(3, annee);
                ps.setString(4, jourLib);
                ps.setDouble(5, oeufs);
                ps.setDouble(6, poussins);
                ps.setDouble(7, taux);
                ps.setDouble(8, oeufsTheoriques);
                ps.setDouble(9, poussinsTheoriques);
                ps.setDouble(10, tauxTheorique);
                ps.setString(11, existingId);
                ps.executeUpdate();
            }
        } else {
            // INSERT - NOTE: Ceci échouera si les colonnes théoriques n'existent pas encore dans la table
            String insertSql = "INSERT INTO ECLOSION_JOUR_DETAIL (ID, DATY, JOUR, MOIS, ANNEE, JOURLIB, " +
                               "OEUF_MIS_INCUB, POUSSINS_ECLOS, TAUX_ECLOS, OEUF_THEORIQUE, POUSSINS_THEORIQUE, TAUX_ECLOS_THEORIQUE) " +
                               "VALUES (GETSEQ_ECLOSIONJOURDETAIL.NEXTVAL, TO_DATE(?, 'DD/MM/YYYY'), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = c.prepareStatement(insertSql)) {
                ps.setString(1, dateStr);
                ps.setInt(2, jour);
                ps.setInt(3, mois);
                ps.setInt(4, annee);
                ps.setString(5, jourLib);
                ps.setDouble(6, oeufs);
                ps.setDouble(7, poussins);
                ps.setDouble(8, taux);
                ps.setDouble(9, oeufsTheoriques);
                ps.setDouble(10, poussinsTheoriques);
                ps.setDouble(11, tauxTheorique);
                ps.executeUpdate();
            }
        }
    }
    
    public static void main(String[] args) {
        // Test standalone
        Connection c = null;
        try {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            synchroniser(c);
            c.commit();
            System.out.println("Synchronisation terminée avec succès");
        } catch (Exception e) {
            e.printStackTrace();
            try { if (c != null) c.rollback(); } catch (Exception ex) {}
        } finally {
            try { if (c != null) c.close(); } catch (Exception ex) {}
        }
    }
}