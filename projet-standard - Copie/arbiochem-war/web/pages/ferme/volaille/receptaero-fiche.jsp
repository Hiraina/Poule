<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageConsulte"%>
<%@ page import="ferme.volaille.ReceptVolAeroport" %>

<% try{ 
    ReceptVolAeroport o = new ReceptVolAeroport();
    o.setNomTable("RECEPT_VOL_AERO");
    String[] listeCrt = {};
    String[] listeInt = {};
    String[] libEntete = {"id","daty","idCmdVolaille","nbTheoM","nbTheoF","nbVivantM","nbVivantF","nbMortM","nbMortF","nbPerduM","nbPerduF","etat"};
    PageConsulte pc = new PageConsulte(o, request, listeCrt, listeInt, libEntete, libEntete.length);
    pc.setUtilisateur((user.UserEJB) session.getValue("u"));
    pc.setLien((String) session.getValue("lien"));
    pc.setTitre("Fiche r&eacute;ception volaille - A&eacute;roport");
    String id = request.getParameter("id");
    String apres = "ferme/volaille/receptaero-liste.jsp";
    
    pc.getFormu().getChamp("daty").setLibelle("Date");
    pc.getFormu().getChamp("idCmdVolaille").setLibelle("Bon de commande");
    pc.getFormu().getChamp("nbTheoM").setLibelle("Th&eacute;orique M");
    pc.getFormu().getChamp("nbTheoF").setLibelle("Th&eacute;orique F");
    pc.getFormu().getChamp("nbVivantM").setLibelle("Vivants M");
    pc.getFormu().getChamp("nbVivantF").setLibelle("Vivants F");
    pc.getFormu().getChamp("nbMortM").setLibelle("Morts M");
    pc.getFormu().getChamp("nbMortF").setLibelle("Morts F");
    pc.getFormu().getChamp("nbPerduM").setLibelle("Perdus M");
    pc.getFormu().getChamp("nbPerduF").setLibelle("Perdus F");
    pc.getFormu().getChamp("etat").setLibelle("Etat");

    pc.preparerDataFormu();
    pc.getFormu().makeHtmlConsult();
%>

<div class="content-wrapper">
    <h1><%=pc.getTitre()%></h1>
    <%
        out.println(pc.getFormu().getHtmlConsult());
    %>
</div>

<% } catch (Exception e) {
  e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
    history.back();
</script>
<% }%>