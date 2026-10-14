<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageConsulte"%>
<%@ page import="ferme.volaille.MortVolaille" %>

<% try{ 
    MortVolaille o = new MortVolaille();
    o.setNomTable("MORT_VOLAILLE");
    String[] listeCrt = {};
    String[] listeInt = {};
    String[] libEntete = {"id","daty","idLot","idBatiment","idParquet","nbMort","nbPerdu","etat"};
    PageConsulte pc = new PageConsulte(o, request, listeCrt, listeInt, libEntete, libEntete.length);
    pc.setUtilisateur((user.UserEJB) session.getValue("u"));
    pc.setLien((String) session.getValue("lien"));
    pc.setTitre("Fiche morts et perdus");
    String id = request.getParameter("id");
    String apres = "ferme/volaille/mortvolaille-liste.jsp";
    
    pc.getFormu().getChamp("daty").setLibelle("Date");
    pc.getFormu().getChamp("idLot").setLibelle("Lot");
    pc.getFormu().getChamp("idBatiment").setLibelle("B&acirc;timent");
    pc.getFormu().getChamp("idParquet").setLibelle("Parquet");
    pc.getFormu().getChamp("nbMort").setLibelle("Morts");
    pc.getFormu().getChamp("nbPerdu").setLibelle("Perdus");
    pc.getFormu().getChamp("etat").setLibelle("Etat");

    pc.preparerDataFormu();
    pc.getFormu().makeHtmlConsult();
%>

<div class="content-wrapper">
    <h1><%=pc.getTitre()%></h1>
    <%
        out.println(pc.getFormu().getHtmlConsult());
    %>
    <div class="nav-tabs-custom">
        <ul class="nav nav-tabs">
            <li class="active"><a href="#details" data-toggle="tab">D&eacute;tails</a></li>
        </ul>
        <div class="tab-content">
            <div class="tab-pane active" id="details">
                <jsp:include page="inc/mortvolaille-details.jsp">
                    <jsp:param name="id" value="<%=id%>"/>
                </jsp:include>
            </div>
        </div>
    </div>
</div>

<% } catch (Exception e) {
  e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
    history.back();
</script>
<% }%>