# LISTE À APPRENDRE - Projet Volailles
## 1. TABLES (Base de données Oracle)
### Tables existantes (à comprendre)
- LOT : lot de volailles (id, nomlot, reference, dateeclosion, datearrivee, idSouche, idCategorieLot, idOrigine...)
- LOT_LIB (vue) : vue enrichie avec libellés et âge
- BATIMENT / BATIMENTDETAIL : bâtiments et parquets
- PARQUET : parquets (TypeObjet)
- SIEGE / FERME : structure
- SEXE (TypeObjet) : 0=Femelle, 1=Mâle
- SOUCHE (TypeObjet) : races (Ross, Cobb...)
- CATEGORIELOT (TypeObjet) : catégorie du lot
- ORIGINELOT (TypeObjet)
- QUALITEPOUSSIN (TypeObjet)
- ProgrammeZootechnique / ProgrammeZootechniqueDetails
- ReceptionPoussinAeroport / ReceptionPoussinAeroportDetail
- TriageBatimentParquet / TriageBatimentParquetDetail
- TransfertPoulet / TransfertPouletDetail

### Tables créées (à connaître)
- TYPEVOLAILLE (TypeObjet): TV001=POUSSIN, TV002=POULE, TV003=COQ
- PARQUET_VOLAILLE: ID, IDBATIMENT, NOM, CAPACITE_MAX, AGE_AUTORISE, SEXE_AUTORISE
- CMD_VOLAILLE (Mere): ID, DATY, FOURNISSEUR, IDTYPEVOLAILLE, AGE_VOLAILLE, EFFECTIF_THEO_M, EFFECTIF_THEO_F, ETAT, REMARQUE
- CMD_VOLAILLE_DET (Fille): ID, IDMERE, IDSOUCHE, RACE, EFFECTIF_M, EFFECTIF_F, PU
- RECEPT_VOL_AERO (Mere): ID, IDCMDVOLAILLE, DATY, NB_THEO_M,F, NB_VIVANT_M,F, NB_MORT_M,F, NB_PERDU_M,F, ETAT
- RECEPT_VOL_AERO_DET (Fille): ID, IDMERE, IDQUALITEPOUSSIN, IDSEXE, QTE
- RECEPT_VOL_COUR (Mere): ID, IDRECEPTAERO, DATY, ETAT
- RECEPT_VOL_COUR_DET (Fille): ID, IDMERE, IDPARQUET, EFFECTIF, SEXES, ECHELLE_SANTE, STATUT, NB_MORT, NB_PERDU


## 2. CLASSES EJB (Java - package ferme.volaille)
### Créées (à apprendre)
1. TypeVolaille.java (hérite TypeObjet)
   - setNomTable("TYPEVOLAILLE")
   - construirePK: prefixe "TV", séquence GETSEQ_TYPEVOLAILLE

2. ParquetVolaille.java (hérite TypeObjet)
   - Champs: idBatiment, nom, capaciteMax, ageAutorise, sexeAutorise (sexesAutorise)
   - prefixe "PV", GETSEQ_PARQUETVOLAILLE

3. CmdVolaille.java (hérite ClassMere)
   - Fille: ferme.volaille.CmdVolailleDet (liaison idMere)
   - construirePK: "CMDV", GETSEQ_CMDVOLAILLE
   - createObject(): contrôle somme M+F détail == théorique M+F (Exception si différent)

4. CmdVolailleDet.java (hérite ClassFille)
   - Mere: ferme.volaille.CmdVolaille, liaison idMere
   - prefixe "CMDVD", GETSEQ_CMDVOLAILLEDET
   - Champs: idSouche, race, effectifM, effectifF, pu

5. ReceptVolAeroport.java (hérite ClassMere)
   - Fille: ferme.volaille.ReceptVolAeroportDet
   - prefixe "RVA", GETSEQ_RECEPTVOLAERO
   - createObject(): nbTheoM == nbVivantM+nbMortM+nbPerduM (idem F)

6. ReceptVolAeroportDet.java (hérite ClassFille)
   - prefixe "RVAD", GETSEQ_RECEPTVOLAERODET
   - Champs: idQualitePoussin, idSexe, qte

7. ReceptVolCour.java (hérite ClassMere)
   - Fille: ferme.volaille.ReceptVolCourDet
   - prefixe "RVC", GETSEQ_RECEPTVOLCOUR
   - createObject(): somme effectifs détails == total vivants réception aéroport

8. ReceptVolCourDet.java (hérite ClassFille)
   - prefixe "RVCD", GETSEQ_RECEPTVOLCOURDET
   - Champs: idParquet, effectif, sexes, echelleSante (1-10), statut, nbMort, nbPerdu, ageVolaille
   - createObject(): statut>=11 → refuse modif; vérif capacité parquet + existants; vérif âge autorisé; vérif sexe autorisé


## 3. FRAMEWORK - Concepts à maîtriser
- ClassMere / ClassFille / ClassEtat / TypeObjet (héritage)
- CGenUtil.rechercher(ClassMAPTable, ...)
- construirePK() + preparePk(prefixe, sequence) + makePK(c)
- createObject(String u, Connection c) / super.createObject(...)
- getFille(), setFille(), setNomClasseFille(), setLiaisonFille
- setNomTable(), getTuppleID(), getAttributIDName()
- controler() (usage)

## 4. JSP - À apprendre (pages créées)
Dossier: arbiochem-war/web/pages/ferme/volaille/

### Pages principales
1. cmdvolaille-liste.jsp - PageRecherche (liste commande)
2. cmdvolaille-saisie.jsp - PageInsertMultiple (saisie commande + détails, taille=10)
3. cmdvolaille-fiche.jsp - PageConsulte + onglet détails
4. inc/cmdvolaille-details.jsp - PageRecherche (détails sous-onglet)

5. receptaero-liste.jsp - PageRecherche
6. receptaero-saisie.jsp - PageInsertMultiple (détails avec idSexe, idQualitePoussin)
7. receptaero-fiche.jsp - PageConsulte

8. receptcour-liste.jsp - PageRecherche
9. receptcour-saisie.jsp - PageInsertMultiple (grille: idParquet, sexes, effectif, echelleSante 1-10)
10. receptcour-fiche.jsp - PageConsulte + onglet détails
11. inc/receptcour-details.jsp - PageRecherche

### Classes/objets JSP utilisés
- PageInsertMultiple(mere, fille, request, taille, u)
- PageRecherche(objet, request, listeCrt, listeInt, nbLigne, libEntete, nbCol)
- PageConsulte(objet, request, listeCrt, listeInt, libEntete, nbCol)
- Liste(nomChamp, objetRef, champAffiche, champValeur)
- formufle.changerEnChamp(), formufle.setColOrdre(), formufle.getHtmlTableauInsert()
- Champ.setVisible(), getFormu().getHtmlInsert/Consult
- apresMultiple.jsp (traitement insert/update multiple)


## 5. SEQUENCES (Oracle)
- GETSEQ_TYPEVOLAILLE
- GETSEQ_PARQUETVOLAILLE
- GETSEQ_CMDVOLAILLE
- GETSEQ_CMDVOLAILLEDET
- GETSEQ_RECEPTVOLAERO
- GETSEQ_RECEPTVOLAERODET
- GETSEQ_RECEPTVOLCOUR
- GETSEQ_RECEPTVOLCOURDET

## 6. LIENS À COMPRENDRE
Workflow:
1. Bon de commande (CMD_VOLAILLE + CMD_VOLAILLE_DET) - saisie par M/F théorique + détail par souche
2. Réception aéroport (RECEPT_VOL_AERO + RECEPT_VOL_AERO_DET) - compare théorique vs vivants+morts+perdus
3. Réception cour (RECEPT_VOL_COUR + RECEPT_VOL_COUR_DET) - répartition dans parquets (capacité, âge, sexe, santé 1-10)

Clés: liaison IDMERE (ClassFille)

## 7. NOUVELLES FONCTIONNALITÉS - Mortalité/Perdus + Calendrier Œufs/Éclosion
### Tables créées (à connaître)
- MORT_VOLAILLE: ID, DATY, IDLOT, IDBATIMENT, IDPARQUET, NB_MORT, NB_PERDU, ETAT
- MORT_VOLAILLE_DET: ID, IDMERE, IDQUALITEPOUSSIN, IDSEXE, NB_MORT, NB_PERDU
- ECLOSION_JOUR_DETAIL: ID, DATY, JOUR, MOIS, ANNEE, JOURLIB, OEUF_MIS_INCUB, POUSSINS_ECLOS, TAUX_ECLOS

### Classes EJB (Java - package ferme.volaille)
#### Créées (à apprendre)
1. MortVolaille.java (hérite ClassMere)
   - Fille: ferme.volaille.MortVolailleDet (liaison idMere)
   - construirePK: "MORV", GETSEQ_MORTVOLAILLE
   - createObject(): contrôle somme des détails = totaux (Exception si différent)

2. MortVolailleDet.java (hérite ClassFille)
   - Mere: ferme.volaille.MortVolaille, liaison idMere
   - prefixe: "MORD", séquence GETSEQ_MORTVOLAILLEDET
   - Champs: idQualitePoussin, idSexe, nbMort, nbPerdu

### Service de synchronisation (Java - package ferme.volaille)
- EclosionJourDetailSync.java: Service qui calcule et met à jour les données du calendrier
  - Synchronise les données prédites (MiseEnIncubateur.dateeclosionprevue) avec les données réelles (Eclosion.dateeclosion)
  - Calcule les valeurs théoriques à partir de ProgrammeZootechnique (pontehebdomadaire, tauxeclosion, poussins)
  - Met à jour la table ECLOSION_JOUR_DETAIL

### JSP - À apprendre (pages créées)
Dossier: arbiochem-war/web/pages/ferme/volaille/

#### Pages principales
1. mortvolaille-liste.jsp - PageRecherche (liste morts/perdus)
2. mortvolaille-saisie.jsp - PageInsertMultiple (saisie morts/perdus + détails, taille=10)
3. mortvolaille-fiche.jsp - PageConsulte + onglet détails
4. inc/mortvolaille-details.jsp - PageRecherche (détails sous-onglet)
5. eclosion-calendrier.jsp - Affichage grille mois/jour avec prédiction vs réel (basé sur ca-calendrier-v2.jsp)
6. sync-eclosion-calendrier.jsp - Page de déclenchement de la synchronisation

#### Classes/objets JSP utilisés
- PageInsertMultiple(mere, fille, request, taille, u)
- PageRecherche(objet, request, listeCrt, listeInt, nbLigne, libEntete, nbCol)
- PageConsulte(objet, request, listeCrt, listeInt, libEntete, nbCol)
- Liste(nomChamp, objetRef, champAffiche, champValeur)
- formufle.changerEnChamp(), formufle.setColOrdre(), formufle.getHtmlTableauInsert()
- Champ.setVisible(), getFormu().getHtmlInsert/Consult
- apresMultiple.jsp (traitement insert/update multiple)

### Séquences (Oracle)
- GETSEQ_MORTVOLAILLE
- GETSEQ_MORTVOLAILLEDET
- GETSEQ_ECLOSIONJOURDETAIL (existante)

### Workflow de l'éclosion
1. Ponte hebdomadaire (ProgrammeZootechnique.pontehebdomadaire) → estimation des œufs pondus
2. Œuf mis en incubateur → MiseEnIncubateur.dateeclosionprevue = date + 21j (prédiction)
3. Éclosion → Eclosion.dateeclosion = date réelle
4. Mort → SuiviJournalierDetail.mortalite (journalier)
5. Perdu → SuiviJournalierDetail.culls (journalier)
6. Calendrier → EclosionCalendrier affiche prédit vs réel (données de ECLOSION_JOUR_DETAIL)
