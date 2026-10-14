<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageConsulte"%>
<%@ page import="ferme.volaille.CmdVolaille" %>

<% try{ 
    CmdVolaille o = new CmdVolaille();
    o.setNomTable("CMD_VOLAILLE");
    String[] listeCrt = {};
    String[] listeInt = {};
    String[] libEntete = {"id","daty","fournisseur","idTypeVolaille","ageVolaille","effectifTheoM","effectifTheoF","remarque","etat"};
    PageConsulte pc = new PageConsulte(o, request, listeCrt, listeInt, libEntete, libEntete.length);
    pc.setUtilisateur((user.UserEJB) session.getValue("u"));
    pc.setLien((String) session.getValue("lien"));
    pc.setTitre("Fiche bon de commande volaille");
    String id = request.getParameter("id");
    String apres = "ferme/volaille/cmdvolaille-liste.jsp";
    
    pc.getFormu().getChamp("daty").setLibelle("Date");
    pc.getFormu().getChamp("fournisseur").setLibelle("Fournisseur");
    pc.getFormu().getChamp("idTypeVolaille").setLibelle("Type de volaille");
    pc.getFormu().getChamp("ageVolaille").setLibelle("Age (jours)");
    pc.getFormu().getChamp("effectifTheoM").setLibelle("Effectif th&eacute;orique M&acirc;le");
    pc.getFormu().getChamp("effectifTheoF").setLibelle("Effectif th&eacute;orique Femelle");
    pc.getFormu().getChamp("remarque").setLibelle("Remarque");
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
                <jsp:include page="inc/cmdvolaille-details.jsp">
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