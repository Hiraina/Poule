<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageInsertMultiple"%>
<%@ page import="user.UserEJB" %>
<%@ page import="ferme.volaille.MortVolaille" %>
<%@ page import="ferme.volaille.MortVolailleDet" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.TypeObjet" %>
<%@ page import="ferme.configuration.QualitePoussin" %>
<%@ page import="ferme.lot.Lot" %>
<%@ page import="ferme.configuration.Batiment" %>
<%@ page import="ferme.configuration.ParquetBatiment" %>

<% try{ 
    UserEJB u = (user.UserEJB) session.getValue("u");
    String classeMere = "ferme.volaille.MortVolaille";
    String classeFille = "ferme.volaille.MortVolailleDet";
    String nomTableFille = "MORT_VOLAILLE_DET";
    String colonneMere = "idMere";
    String apres = "ferme/volaille/mortvolaille-fiche.jsp";

    MortVolaille mere = new MortVolaille();
    MortVolailleDet fille = new MortVolailleDet();
    int taille = 10;
    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, taille, u);
    pi.setLien((String) session.getValue("lien"));  
    pi.setTitre("Saisie morts et perdus de volailles");

    pi.getFormu().getChamp("daty").setLibelle("Date");
    pi.getFormu().getChamp("idLot").setLibelle("Lot");
    pi.getFormu().getChamp("idBatiment").setLibelle("B&acirc;timent");
    pi.getFormu().getChamp("idParquet").setLibelle("Parquet");
    pi.getFormu().getChamp("nbMort").setLibelle("Nombre total de morts");
    pi.getFormu().getChamp("nbPerdu").setLibelle("Nombre total de perdus");
    pi.getFormu().getChamp("etat").setVisible(false);
    pi.getFormu().getChamp("idLot").setPageAppelComplete("ferme.lot.Lot","id","LOT","id","id");

    Liste[] listef = new Liste[3];
    TypeObjet sexes = new TypeObjet();
    sexes.setNomTable("SEXE");
    listef[0] = new Liste("idSexe", sexes, "val", "id");
    QualitePoussin qp = new QualitePoussin();
    listef[1] = new Liste("idQualitePoussin", qp, "val", "id");
    ParquetBatiment parquet = new ParquetBatiment();
    listef[2] = new Liste("idParquet", parquet, "val", "id");
    pi.getFormufle().changerEnChamp(listef);
    pi.getFormufle().getChamp("idSexe_0").setLibelle("Sexe");
    pi.getFormufle().getChamp("idQualitePoussin_0").setLibelle("Qualit&eacute;");
    pi.getFormufle().getChamp("idParquet_0").setLibelle("Parquet");
    pi.getFormufle().getChamp("nbMort_0").setLibelle("Morts");
    pi.getFormufle().getChamp("nbPerdu_0").setLibelle("Perdus");
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("idMere").getListeChamp(),false);
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("id").getListeChamp(),false);

    String[] colOrdre = {"idSexe","idQualitePoussin","idParquet","nbMort","nbPerdu"};
    pi.getFormufle().setColOrdre(colOrdre);

    String acte = request.getParameter("acte");
    if(acte != null && acte.equalsIgnoreCase("update")){
        pi.setTitre("Modification morts et perdus");
    }

    pi.preparerDataFormu();
    pi.getFormu().makeHtmlInsertTabIndex();
    pi.getFormufle().makeHtmlInsertTableauIndex();
%>

<div class="content-wrapper">
    <h1><%=pi.getTitre()%></h1>
    <form id="formId" class='container' action="<%=pi.getLien()%>?but=apresMultiple.jsp" method="post" >
        <%
            out.println(pi.getFormu().getHtmlInsert());
            out.println(pi.getFormufle().getHtmlTableauInsert());
        %>
        <input name="acte" type="hidden" id="nature" value="insert">
        <input name="bute" type="hidden" id="bute" value="<%=apres%>">
        <input name="classe" type="hidden" id="classe" value="<%=classeMere%>">
        <input name="classefille" type="hidden" id="classefille" value="<%=classeFille%>">
        <input name="nomtable" type="hidden" id="nomtable" value="<%=nomTableFille%>">
        <input name="nombreLigne" type="hidden" id="nombreLigne" value="<%=taille%>">
        <input name="colonneMere" type="hidden" id="colonneMere" value="<%=colonneMere%>">
    </form>
</div>

<% } catch (Exception e) {
  e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
    history.back();
</script>
<% }%>