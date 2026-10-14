<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageRecherche"%>
<%@ page import="ferme.volaille.CmdVolaille" %>

<% try{ 
    CmdVolaille o = new CmdVolaille();
    String[] listeCrt = {};
    String[] listeInt = {};
    String[] libEntete = {"id","daty","fournisseur","effectifTheoM","effectifTheoF","etat"};
    PageRecherche pr = new PageRecherche(o, request, listeCrt, listeInt, 4, libEntete, libEntete.length);
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("ferme/volaille/cmdvolaille-liste.jsp");

    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);

    String[] libEnteteAffiche = {"Num&eacute;ro","Date","Fournisseur","Effectif M th&eacute;orique","Effectif F th&eacute;orique","Etat"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
    pr.getTableau().setLienModif("ferme/volaille/cmdvolaille-fiche.jsp");
    pr.getTableau().setLienSupp("ferme/volaille/cmdvolaille-fiche.jsp");
    pr.getTableau().setLienAdd("ferme/volaille/cmdvolaille-saisie.jsp");
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Liste des bons de commande volaille</h1>
    </section>
    <section class="content">
        <div class="box">
            <div class="box-body">
                <%  if(pr.getTableau().getHtml() != null){
                        out.println(pr.getTableau().getHtml());
                    } else{ %>
                        <center><h4>Aucune donn&eacute;e trouv&eacute;e</h4></center>
                <%  } %>
            </div>
        </div>
    </section>
</div>

<% } catch (Exception e) {
  e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
    history.back();
</script>
<% }%>