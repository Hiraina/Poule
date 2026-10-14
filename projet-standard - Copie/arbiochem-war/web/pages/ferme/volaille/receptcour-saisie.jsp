<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageInsertMultiple"%>
<%@ page import="user.UserEJB" %>
<%@ page import="ferme.volaille.ReceptVolCour" %>
<%@ page import="ferme.volaille.ReceptVolCourDet" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.TypeObjet" %>
<%@ page import="ferme.volaille.ParquetVolaille" %>

<% try{ 
    UserEJB u = (user.UserEJB) session.getValue("u");
    String classeMere = "ferme.volaille.ReceptVolCour";
    String classeFille = "ferme.volaille.ReceptVolCourDet";
    String nomTableFille = "RECEPT_VOL_COUR_DET";
    String colonneMere = "idMere";
    String apres = "ferme/volaille/receptcour-fiche.jsp";
    String idReceptAeroport = request.getParameter("idReceptAeroport");

    ReceptVolCour mere = new ReceptVolCour();
    ReceptVolCourDet fille = new ReceptVolCourDet();
    int taille = 10;
    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, taille, u);
    pi.setLien((String) session.getValue("lien"));  
    pi.setTitre("Saisie r&eacute;ception volaille - Cour");

    pi.getFormu().getChamp("daty").setLibelle("Date");
    pi.getFormu().getChamp("idReceptAeroport").setLibelle("R&eacute;ception A&eacute;roport");
    pi.getFormu().getChamp("etat").setVisible(false);
    pi.getFormu().getChamp("idReceptAeroport").setPageAppelComplete("ferme.volaille.ReceptVolAeroport","id","RECEPT_VOL_AERO","id","id");

    if(idReceptAeroport != null && !idReceptAeroport.isEmpty()){
        pi.getFormu().getChamp("idReceptAeroport").setDefaut(idReceptAeroport);
        pi.getFormu().getChamp("idReceptAeroport").setAutre("readonly");
    }

    Liste[] listef = new Liste[2];
    TypeObjet sexe = new TypeObjet();
    sexe.setNomTable("SEXE");
    listef[0] = new Liste("sexes", sexe, "val", "id");
    ParquetVolaille parquet = new ParquetVolaille();
    listef[1] = new Liste("idParquet", parquet, "nom", "id");
    pi.getFormufle().changerEnChamp(listef);
    pi.getFormufle().getChamp("idParquet_0").setLibelle("Parquet");
    pi.getFormufle().getChamp("sexes_0").setLibelle("Sexe");
    pi.getFormufle().getChamp("effectif_0").setLibelle("Effectif");
    pi.getFormufle().getChamp("echelleSante_0").setLibelle("Echelle de sant&eacute; (1-10)");
    pi.getFormufle().getChamp("nbMort_0").setLibelle("Morts");
    pi.getFormufle().getChamp("nbPerdu_0").setLibelle("Perdus");
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("idMere").getListeChamp(),false);
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("id").getListeChamp(),false);
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("statut").getListeChamp(),false);
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("ageVolaille").getListeChamp(),false);

    String[] colOrdre = {"idParquet","sexes","effectif","echelleSante","nbMort","nbPerdu"};
    pi.getFormufle().setColOrdre(colOrdre);

    String acte = request.getParameter("acte");
    if(acte != null && acte.equalsIgnoreCase("update")){
        pi.setTitre("Modification r&eacute;ception volaille - Cour");
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