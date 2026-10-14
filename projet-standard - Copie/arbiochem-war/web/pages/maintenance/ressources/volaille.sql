-- Script de création des tables pour le workflow commande/réception de volailles
-- Exécuter une fois dans Oracle

-- ============================================================
-- 1. SÉQUENCES
-- ============================================================
CREATE SEQUENCE GETSEQ_TYPEVOLAILLE;
CREATE SEQUENCE GETSEQ_PARQUETVOLAILLE;
CREATE SEQUENCE GETSEQ_CMDVOLAILLE;
CREATE SEQUENCE GETSEQ_CMDVOLAILLEDET;
CREATE SEQUENCE GETSEQ_RECEPTVOLAERO;
CREATE SEQUENCE GETSEQ_RECEPTVOLAERODET;
CREATE SEQUENCE GETSEQ_RECEPTVOLCOUR;
CREATE SEQUENCE GETSEQ_RECEPTVOLCOURDET;

CREATE SEQUENCE GETSEQ_MORTVOLAILLE;
CREATE SEQUENCE GETSEQ_MORTVOLAILLEDET;
CREATE SEQUENCE GETSEQ_ECLOSIONJOURDETAIL;

-- ============================================================
-- 12. TABLE : ECLOSION_JOUR_DETAIL (détails journaliers œufs/éclosion)
-- ============================================================
CREATE TABLE ECLOSION_JOUR_DETAIL (
    ID              VARCHAR2(20) PRIMARY KEY,
    DATY            DATE,
    JOUR            NUMBER,
    MOIS            NUMBER,
    ANNEE           NUMBER,
    JOURLIB         VARCHAR2(20),
    OEUF_MIS_INCUB  NUMBER DEFAULT 0,
    POUSSINS_ECLOS  NUMBER DEFAULT 0,
    TAUX_ECLOS      NUMBER DEFAULT 0
);

-- ============================================================
-- 2. TABLE DE RÉFÉRENCE : TYPEVOLAILLE
-- ============================================================
CREATE TABLE TYPEVOLAILLE (
    ID     VARCHAR2(20) PRIMARY KEY,
    VAL    VARCHAR2(50),
    DESCE  VARCHAR2(100)
);

INSERT INTO TYPEVOLAILLE (ID, VAL, DESCE) VALUES ('TV001', 'POUSSIN', 'Volaille jour');
INSERT INTO TYPEVOLAILLE (ID, VAL, DESCE) VALUES ('TV002', 'POULE', 'Pondeuse adulte');
INSERT INTO TYPEVOLAILLE (ID, VAL, DESCE) VALUES ('TV003', 'COQ', 'Mâle adulte');

-- ============================================================
-- 3. TABLE : PARQUET_VOLAILLE (compartiments)
-- ============================================================
CREATE TABLE PARQUET_VOLAILLE (
    ID              VARCHAR2(20) PRIMARY KEY,
    IDBATIMENT      VARCHAR2(20),
    NOM             VARCHAR2(50),
    CAPACITE_MAX    NUMBER,
    AGE_AUTORISE    NUMBER,
    SEXE_AUTORISE   CHAR(1)
);

-- ============================================================
-- 4. TABLE : CMD_VOLAILLE (bon de commande fournisseur)
-- ============================================================
CREATE TABLE CMD_VOLAILLE (
    ID              VARCHAR2(20) PRIMARY KEY,
    DATY            DATE,
    FOURNISSEUR     VARCHAR2(20),
    IDTYPEVOLAILLE  VARCHAR2(20),
    AGE_VOLAILLE    NUMBER,
    EFFECTIF_THEO_M NUMBER,
    EFFECTIF_THEO_F NUMBER,
    ETAT            NUMBER DEFAULT 0,
    REMARQUE        VARCHAR2(200)
);

-- ============================================================
-- 5. TABLE : CMD_VOLAILLE_DET (lignes de commande)
-- ============================================================
CREATE TABLE CMD_VOLAILLE_DET (
    ID          VARCHAR2(20) PRIMARY KEY,
    IDMERE      VARCHAR2(20),
    IDSOUCHE    VARCHAR2(20),
    RACE        VARCHAR2(50),
    EFFECTIF_M  NUMBER,
    EFFECTIF_F  NUMBER,
    PU          NUMBER(15,2)
);

-- ============================================================
-- 6. TABLE : RECEPT_VOL_AERO (réception à l'aéroport)
-- ============================================================
CREATE TABLE RECEPT_VOL_AERO (
    ID              VARCHAR2(20) PRIMARY KEY,
    IDCMDVOLAILLE   VARCHAR2(20),
    DATY            DATE,
    NB_THEO_M       NUMBER,
    NB_THEO_F       NUMBER,
    NB_VIVANT_M     NUMBER,
    NB_VIVANT_F     NUMBER,
    NB_MORT_M       NUMBER,
    NB_MORT_F       NUMBER,
    NB_PERDU_M      NUMBER,
    NB_PERDU_F      NUMBER,
    ETAT            NUMBER DEFAULT 0
);

-- ============================================================
-- 7. TABLE : RECEPT_VOL_AERO_DET (détails réception aéroport)
-- ============================================================
CREATE TABLE RECEPT_VOL_AERO_DET (
    ID              VARCHAR2(20) PRIMARY KEY,
    IDMERE          VARCHAR2(20),
    IDQUALITEPOUSSIN VARCHAR2(20),
    IDSEXE          CHAR(1),
    QTE             NUMBER
);

-- ============================================================
-- 8. TABLE : RECEPT_VOL_COUR (réception à la cour)
-- ============================================================
CREATE TABLE RECEPT_VOL_COUR (
    ID              VARCHAR2(20) PRIMARY KEY,
    IDRECEPTAERO    VARCHAR2(20),
    DATY            DATE,
    ETAT            NUMBER DEFAULT 0
);

-- ============================================================
-- 9. TABLE : RECEPT_VOL_COUR_DET (lignes réception cour)
-- ============================================================
CREATE TABLE RECEPT_VOL_COUR_DET (
    ID              VARCHAR2(20) PRIMARY KEY,
    IDMERE          VARCHAR2(20),
    IDPARQUET       VARCHAR2(20),
    EFFECTIF        NUMBER,
    SEXE            CHAR(1),
    ECHELLE_SANTE   NUMBER,
    STATUT          NUMBER DEFAULT 0,
    NB_MORT         NUMBER DEFAULT 0,
    NB_PERDU        NUMBER DEFAULT 0,
    AGE_VOLAILLE    NUMBER
);

-- ============================================================
-- 10. TABLE : MORT_VOLAILLE (entête morts/perdus journalier)
-- ============================================================
CREATE TABLE MORT_VOLAILLE (
    ID              VARCHAR2(20) PRIMARY KEY,
    DATY            DATE,
    IDLOT           VARCHAR2(20),
    IDBATIMENT      VARCHAR2(20),
    IDPARQUET       VARCHAR2(20),
    NB_MORT         NUMBER DEFAULT 0,
    NB_PERDU        NUMBER DEFAULT 0,
    ETAT            NUMBER DEFAULT 0
);

-- ============================================================
-- 11. TABLE : MORT_VOLAILLE_DET (détails morts/perdus)
-- ============================================================
CREATE TABLE MORT_VOLAILLE_DET (
    ID              VARCHAR2(20) PRIMARY KEY,
    IDMERE          VARCHAR2(20),
    IDQUALITEPOUSSIN VARCHAR2(20),
    IDSEXE          CHAR(1),
    NB_MORT         NUMBER DEFAULT 0,
    NB_PERDU        NUMBER DEFAULT 0
);
