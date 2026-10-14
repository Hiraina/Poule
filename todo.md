Bon point. La catégorie (PONTE/CHAIR) dépend de l'âge, et le **sexe n'a de sens que pour les poussins** (on commande séparément M/F). Pour les adults, le sexes définit le rôle (poule=œufs, coq=viande).

## Modèle clarifié

```
Âge 0 (poussin)  → commande par effet M + F séparés
Âge croissant   → CATEGORIELOT (PONTE si pondeuse, CHAIR si broiler)
Sexe            → pertinente dès le poussin (femelle→pondeuse, mâle→chair)
```

## Implémentation

### 1. Données de référence (tables existantes + une nouvelle)

| Table | Statut | Usage |
|-------|--------|-------|
| `CATEGORIELOT` | ✅ existe | 1=PONTE, 2=CHAIR — déterminée par l'âge (pour distinguer mâle et femelle) |
| `SOUCHE` | ✅ existe | Ross 308, Cobb 500, Hubbard (commande de race) |
| `SEXE` | ✅ existe | M/F |
| `LOT` | ✅ existe | lot (IDCATEGORIELOT, IDSOUCHE, DATEARRIVEE) |
| `TYPEVOLAILLE` | ❌ à créer | POUSSIN / POULE / COQ — dérivé de l'âge |

> **Règle** : `TYPEVOLAILLE` = f(âge) :
> - âge 0 → POUSSIN
> - âge < ~20j → CHAIR (broiler)
> - âge ≥ 20j → POULE (si F) / COQ (si M)

### 2. Tables à créer (Variante A)

```sql
CREATE SEQUENCE GETSEQ_CMDVOLAILLE;
CREATE SEQUENCE GETSEQ_CMDVOLAILLEDET;
CREATE SEQUENCE GETSEQ_RECEPTVOLAERO;
CREATE SEQUENCE GETSEQ_RECEPTVOLAERODET;
CREATE SEQUENCE GETSEQ_RECEPTVOLCOUR;
CREATE SEQUENCE GETSEQ_RECEPTVOLCOURDET;
CREATE SEQUENCE GETSEQ_PARQUETVOLAILLE;
CREATE SEQUENCE GETSEQ_TYPEVOLAILLE;

CREATE TABLE TYPEVOLAILLE (ID VARCHAR2(20) PRIMARY KEY, VAL VARCHAR2(50), DESCE VARCHAR2(100));
INSERT INTO TYPEVOLAILLE VALUES ('TV001','POUSSIN','Volaille jour');
INSERT INTO TYPEVOLAILLE VALUES ('TV002','POULE','Pondeuse adulte');
INSERT INTO TYPEVOLAILLE VALUES ('TV003','COQ','Mâle adulte');

CREATE TABLE CMD_VOLAILLE (
  ID VARCHAR2(20) PRIMARY KEY, DATY DATE, FOURNISSEUR VARCHAR2(20),
  IDTYPEVOLAILLE VARCHAR2(20), AGE_VOLAILLE NUMBER,
  EFFECTIF_THEO_M NUMBER, EFFECTIF_THEO_F NUMBER,
  ETAT NUMBER DEFAULT 0, REMARQUE VARCHAR2(200)
);
CREATE TABLE CMD_VOLAILLE_DET (
  ID VARCHAR2(20) PRIMARY KEY, IDMERE VARCHAR2(20),
  IDSOUCHE VARCHAR2(20), RACE VARCHAR2(50),
  EFFECTIF_M NUMBER, EFFECTIF_F NUMBER, PU NUMBER(15,2)
);

CREATE TABLE RECEPT_VOL_AERO (
  ID VARCHAR2(20) PRIMARY KEY, IDCMDVOLAILLE VARCHAR2(20), DATY DATE,
  NB_THEO_M NUMBER, NB_THEO_F NUMBER,
  NB_VIVANT_M NUMBER, NB_VIVANT_F NUMBER,
  NB_MORT_M NUMBER, NB_MORT_F NUMBER,
  NB_PERDU_M NUMBER, NB_PERDU_F NUMBER,
  ETAT NUMBER DEFAULT 0
);
CREATE TABLE RECEPT_VOL_COUR (
  ID VARCHAR2(20) PRIMARY KEY, IDRECEPTAERO VARCHAR2(20), DATY DATE,
  ETAT NUMBER DEFAULT 0
);
CREATE TABLE RECEPT_VOL_COUR_DET (
  ID VARCHAR2(20) PRIMARY KEY, IDMERE VARCHAR2(20), IDPARQUET VARCHAR2(20),
  EFFECTIF NUMBER, SEXE CHAR(1), ECHELLE_SANTE NUMBER,
  STATUT NUMBER DEFAULT 0, NB_MORT NUMBER DEFAULT 0, NB_PERDU NUMBER DEFAULT 0
);

CREATE TABLE PARQUET_VOLAILLE (
  ID VARCHAR2(20) PRIMARY KEY, IDBATIMENT VARCHAR2(20), NOM VARCHAR2(50),
  CAPACITE_MAX NUMBER, AGE_AUTORISE NUMBER, SEXE_AUTORISE CHAR(1)
);
```

### 3. Classes EJB (`ferme/volaille/`)

| Classe | Hérite | Contrôles |
|--------|--------|-----------|
| `TypeVolaille` | `TypeObjet` | PK |
| `CmdVolaille` | `ClassMere` | somme M/F théorique = Σ fille |
| `CmdVolailleDet` | `ClassFille` | PK |
| `ReceptVolAeroport` | `ClassMere` | **théorique = vivants+morts+perdus** |
| `ReceptVolAeroportDet` | `ClassFille` | PK |
| `ReceptVolCour` | `ClassMere` | Σ répartition = vivants reçus |
| `ReceptVolCourDet` | `ClassFille` | capacité, âge, sexes, verrouillage |
| `ParquetVolaille` | `TypeObjet` | PK |

### 4. Contrôles (composés)

```
1. CmdVolaille.createObject : Σ effectif fille = théorique
2. ReceptVolAeroport.createObject : théorique = vivants+morts+perdus (par sexes)
3. ReceptVolCour.createObject : Σ répartition = vivants reçus
4. ReceptVolCourDet.createObject :
   - Σ effectifs + existant ≤ CAPACITE_MAX
   - AGE == AGE_AUTORISE du parquet
   - SEXE == SEXE_AUTORISE (ou mixte si NULL)
   - Si STATUT ≥ 11 → refus modification
```

### 5. JSP (`web/pages/ferme/volaille/`)

| Page | Pattern | Spécificités |
|------|---------|--------------|
| `cmdvolaille-saisie.jsp` | `PageInsertMultiple` | dropdown TypeVolaille, Souche, âge, effectifs M/F |
| `cmdvolaille-fiche.jsp` | `PageConsulte` | onglets (détails, réceptions) |
| `cmdvolaille-liste.jsp` | `PageRecherche` | filtres |
| `receptaero-saisie.jsp` | `PageInsertMultiple` | vivants/morts/perdus M/F |
| `receptaero-fiche.jsp` | `PageConsulte` | — |
| `receptaero-liste.jsp` | `PageRecherche` | — |
| `receptcour-saisie.jsp` | grille custom | parquet (dropdown), effectif, sexes, santé 1-10, boutons Enregistrer/Valider |
| `receptcour-fiche.jsp` | `PageConsulte` | — |
| `receptcour-liste.jsp` | `PageRecherche` | — |
| `inc/receptcour-details.jsp` | `PageRecherche` | — |

### 6. Méthodes réutilisées

| Méthode | Depuis | Pour |
|---------|--------|------|
| `createObject()` | `TriageBatimentParquet`, `ReceptionPoussinAeroport` | contrôles somme |
| `construirePK()` | partout | `preparePk` + `makePK` |
| `CGenUtil.rechercher()` | partout | capacités, théorique |
| `controler()` | `ProgrammeZootechniqueDetails` | contrôle doublon âge/sexe |
| `PageInsertMultiple` | `triagebatimentparquet-saisie.jsp` | grille saisie |
| `Liste.setDeroulanteDependante()` | `transfertpoulet-saisie.jsp` | bâtiment→parquet |
| `Champ.setPageAppelComplete()` | partout | dropdowns |
| Pattern `ETAT` (=11 verrouillé) | `As_BonDeCommande.annulerVisa()` | validation |

### 7. Ordre d'exécution

1. DDL (tables + séquences + données TypeVolaille)
2. Classes EJB (TypeVolaille → CmdVolaille → ReceptVolAeroport → ReceptVolCour → ParquetVolaille)
3. JSP commande (saisie, fiche, liste)
4. JSP réception aéroport
5. JSP réception cour (le cœur : grille + boutons + contrôles)
6. Intégration menu + droits

---

# Suite

## TODO LIST - Mort/Perdus + Calendrier Œufs/Éclosion

### Phase A — Mortalité/Perdus (formulaire journalier)

**À créer** (tables + classes + JSP) :

| # | Tâche | Détail |
|---|-------|--------|
| A.1 | Table `MORT_VOLAILLE` | ID, DATY, IDLOT, IDBATIMENT, IDPARQUET, IDSEXE, NB_MORT, NB_PERDU, ETAT |
| A.2 | Séquence `GETSEQ_MORTVOLAILLE` | — |
| A.3 | Classe `MortVolaille` (ClassMere) | createObject() : contrôle Σ détails = totaux |
| A.4 | Classe `MortVolailleDet` (ClassFille) | Champs : idQualitePoussin, nbMort, nbPerdu |
| A.5 | JSP `mortvolaille-saisie.jsp` | PageInsertMultiple (comme triagebatimentparquet-saisie) |
| A.6 | JSP `mortvolaille-liste.jsp` | PageRecherche |
| A.7 | JSP `mortvolaille-fiche.jsp` | PageConsulte + onglet détails |

**Règles métiers** :
- Morts : n'affectent pas l'effectif (seul le statut change)
- Perdus : affectent l'effectif (diminution)
- Chaque ligne a une date (DATY)

### Phase B — Calendrier Œufs / Éclosion

**À créer** (copier le pattern `CaCalendrier` de `vente/CaCalendrier.java` + `ca-calendrier-v2.jsp`) :

| # | Tâche | Détail |
|---|-------|--------|
| B.1 | Analyser `CaCalendrier.java` (vente) | Comprendre le pattern mois → jour → détails |
| B.2 | Analyser `CaJourDetailPourCalendrier.java` | Comprendre la structure journalière |
| B.3 | Analyser `ca-calendrier-v2.jsp` | Comprendre l'affichage grille |
| B.4 | Créer `EclosionCalendrier.java` | Copie du pattern CaCalendrier |
| B.5 | Remplir avec `MiseEnIncubateur.dateeclosionprevue` | Nombre d'œufs mis en incubateur (prédiction) |
| B.6 | Remplir avec `Eclosion.dateeclosion` | Nombre de poussins éclos (réel) |
| B.7 | Calculer `tauxEclosion` | poussinsEclos / oeufsMisIncubateur |
| B.8 | JSP `eclosion-calendrier.jsp` | Grille mois/jour avec coloration (prédit vs réel) |

### Phase C — Intégration avec Programme Zootechnique

Le `ProgrammeZootechniqueDetails` contient déjà :
- `pontehebdomadaire` (œufs par semaine)
- `tauxeclosion` (% d'éclosion)
- `poussins` (nombre de poussins par œuf)

| # | Tâche | Détail |
|---|-------|--------|
| C.1 | Lire `ProgrammeZootechniqueDetails.java` | Comprendre les champs existants |
| C.2 | Lire `ProgrammeZootechnique.java` | Comprendre le contrôle doublon âge/sexe |
| C.3 | Utiliser `pontehebdomadaire` | Estimer les œufs pondus par semaine |
| C.4 | Utiliser `tauxeclosion` | Estimer les poussins à naître |
| C.5 | Utiliser `poussins` | Nombre théorique de poussins par lot |

### Phase D — Workflow complet

| # | Tâche | Détail |
|---|-------|--------|
| D.1 | Poule pond → `pontehebdomadaire` (Programme Zootechnique) | — |
| D.2 | Œuf mis en incubateur → `MiseEnIncubateur` | `dateeclosionprevue` = date + 21j |
| D.3 | Éclosion → `Eclosion` | `dateeclosion` = date réelle |
| D.4 | Mort → `SuiviJournalierDetail.mortalite` | Journalier |
| D.5 | Perdu → `SuiviJournalierDetail.culls` | Journalier |
| D.6 | Calendrier → `EclosionCalendrier` | Affichage prédit vs réel |

### Phase E — Tests

| # | Tâche |
|---|-------|
| E.1 | Test saisie morts/perdus |
| E.2 | Test calendrier œufs/éclosion (prédit vs réel) |
| E.3 | Test workflow complet : ponte → incubation → éclosion → mortalité |

---

**Déjà intégré** :
- `SuiviJournalierDetail.mortalite` (morts journaliers)
- `SuiviJournalierDetail.culls` (perdus journaliers)
- `MiseEnIncubateur.dateeclosionprevue` (prédiction)
- `Eclosion.dateeclosion` (réel)
- `ProgrammeZootechniqueDetails.pontehebdomadaire`, `tauxeclosion`, `poussins`

**À copier** :
- `CaCalendrier.java` (vente) → pattern calendrier
- `ca-calendrier-v2.jsp` → pattern grille mois/jour
