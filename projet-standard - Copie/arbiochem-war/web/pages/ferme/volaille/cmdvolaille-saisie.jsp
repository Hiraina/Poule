<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageInsertMultiple"%>
<%@ page import="user.UserEJB" %>
<%@ page import="ferme.volaille.CmdVolaille" %>
<%@ page import="ferme.volaille.CmdVolailleDet" %>
<%@ page import="affichage.Liste" %>
<%@ page import="ferme.configuration.Souche" %>
<%@ page import="ferme.volaille.TypeVolaille" %>

<% try{ 
    UserEJB u = (user.UserEJB) session.getValue("u");
    String classeMere = "ferme.volaille.CmdVolaille";
    String classeFille = "ferme.volaille.CmdVolailleDet";
    String nomTableFille = "CMD_VOLAILLE_DET";
    String colonneMere = "idMere";
    String apres = "ferme/volaille/cmdvolaille-fiche.jsp";

    CmdVolaille mere = new CmdVolaille();
    CmdVolailleDet fille = new CmdVolailleDet();
    int taille = 10;
    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, taille, u);
    pi.setLien((String) session.getValue("lien"));  
    pi.setTitre("Saisie bon de commande volaille");

    pi.getFormu().getChamp("daty").setLibelle("Date");
    pi.getFormu().getChamp("fournisseur").setLibelle("Fournisseur");
    pi.getFormu().getChamp("idTypeVolaille").setLibelle("Type de volaille");
    pi.getFormu().getChamp("ageVolaille").setLibelle("Age (jours)");
    pi.getFormu().getChamp("effectifTheoM").setLibelle("Effectif th&eacute;orique M&acirc;le");
    pi.getFormu().getChamp("effectifTheoF").setLibelle("Effectif th&eacute;orique Femelle");
    pi.getFormu().getChamp("etat").setVisible(false);
    pi.getFormu().getChamp("remarque").setLibelle("Remarque");

    Liste[] liste = new Liste[2];
    liste[0] = new Liste("idSouche", new Souche(), "val", "id");
    liste[1] = new Liste("idTypeVolaille", new TypeVolaille(), "val", "id");
    pi.getFormufle().changerEnChamp(liste);

    pi.getFormufle().getChamp("idSouche_0").setLibelle("Souche");
    pi.getFormufle().getChamp("race_0").setLibelle("Race");
    pi.getFormufle().getChamp("effectifM_0").setLibelle("Effectif M&acirc;le");
    pi.getFormufle().getChamp("effectifF_0").setLibelle("Effectif Femelle");
    pi.getFormufle().getChamp("pu_0").setLibelle("PU");
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("idMere").getListeChamp(),false);
    affichage.Champ.setVisible(pi.getFormufle().getChampMulitple("id").getListeChamp(),false);

    String[] colOrdre = {"idSouche","race","effectifM","effectifF","pu"};
    pi.getFormufle().setColOrdre(colOrdre);

    String acte = request.getParameter("acte");
    if(acte != null && acte.equalsIgnoreCase("update")){
        pi.setTitre("Modification bon de commande volaille");
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