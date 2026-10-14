<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageInsertMultiple"%>
<%@ page import="user.UserEJB" %>
<%@ page import="ferme.volaille.ReceptVolAeroport" %>
<%@ page import="ferme.volaille.ReceptVolAeroportDet" %>
<%@ page import="affichage.Liste" %>
<%@ page import="ferme.configuration.QualitePoussin" %>
<%@ page import="bean.TypeObjet" %>

<% try{ 
    UserEJB u = (user.UserEJB) session.getValue("u");
    String classeMere = "ferme.volaille.ReceptVolAeroport";
    String classeFille = "ferme.volaille.ReceptVolAeroportDet";
    String nomTableFille = "RECEPT_VOL_AERO_DET";
    String colonneMere = "idMere";
    String apres = "ferme/volaille/receptaero-fiche.jsp";
    String idCmdVolaille = request.getParameter("idCmdVolaille");

    ReceptVolAeroport mere = new ReceptVolAeroport();
    ReceptVolAeroportDet fille = new ReceptVolAeroportDet();
    int taille = 10;
    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, taille, u);
    pi.setLien((String) session.getValue("lien"));  
    pi.setTitre("Saisie r&eacute;ception volaille - A&eacute;roport");

    pi.getFormu().getChamp("daty").setLibelle("Date");
    pi.getFormu().getChamp("idCmdVolaille").setLibelle("Bon de commande");
    pi.getFormu().getChamp("nbTheoM").setLibelle("Nombre th&eacute;orique M&acirc;les");
    pi.getFormu().getChamp("nbTheoF").setLibelle("Nombre th&eacute;orique Femelles");
    pi.getFormu().getChamp("nbVivantM").setLibelle("Nombre vivants M&acirc;les");
    pi.getFormu().getChamp("nbVivantF").setLibelle("Nombre vivants Femelles");
    pi.getFormu().getChamp("nbMortM").setLibelle("Nombre morts M&acirc;les");
    pi.getFormu().getChamp("nbMortF").setLibelle("Nombre morts Femelles");
    pi.getFormu().getChamp("nbPerduM").setLibelle("Nombre perdus M&acirc;les");
    pi.getFormu().getChamp("nbPerduF").setLibelle("Nombre perdus Femelles");
    pi.getFormu().getChamp("etat").setVisible(false);
    pi.getFormu().getChamp("idCmdVolaille").setPageAppelComplete("ferme.volaille.CmdVolaille","id","CMD_VOLAILLE","id","id");

    if(idCmdVolaille != null && !idCmdVolaille.isEmpty()){
        pi.getFormu().getChamp("idCmdVolaille").setDefaut(idCmdVolaille);
        pi.getFormu().getChamp("idCmdVolaille").setAutre("readonly");
    }

    Liste[] listef = new Liste[2];
    TypeObjet sexe = new TypeObjet();
    sexe.setNomTable("SEXE");
    listef[0] = new Liste("idSexe", sexe, "val", "id");
    QualitePoussin qp = new QualitePoussin();
    listef[1] = new Liste("idQualitePoussin", qp, "val", "id");
    pi.getFormufle().changerEnChamp(listef);
    pi.getFormufle().getChamp("idSexe_0").setLibelle("Sexe");
    pi.getFormufle().getChamp("idQualitePoussin_0").setLibelle("Qualit&eacute;");
    pi.getFormufle().getChamp("qte_0").setLibelle("Quantit&eacute;");
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("idMere").getListeChamp(),false);
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("id").getListeChamp(),false);

    String[] colOrdre = {"idQualitePoussin","idSexe","qte"};
    pi.getFormufle().setColOrdre(colOrdre);

    String acte = request.getParameter("acte");
    if(acte != null && acte.equalsIgnoreCase("update")){
        pi.setTitre("Modification r&eacute;ception volaille - A&eacute;roport");
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