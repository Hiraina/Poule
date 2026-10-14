<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageRecherche"%>
<%@ page import="ferme.volaille.MortVolaille" %>

<% try{ 
    MortVolaille o = new MortVolaille();
    String[] listeCrt = {};
    String[] listeInt = {};
    String[] libEntete = {"id","daty","idLot","idBatiment","idParquet","nbMort","nbPerdu","etat"};
    PageRecherche pr = new PageRecherche(o, request, listeCrt, listeInt, 4, libEntete, libEntete.length);
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("ferme/volaille/mortvolaille-liste.jsp");

    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);

    String[] libEnteteAffiche = {"Num&eacute;ro","Date","Lot","B&acirc;timent","Parquet","Morts","Perdus","Etat"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
    pr.getTableau().setLienModif("ferme/volaille/mortvolaille-fiche.jsp");
    pr.getTableau().setLienSupp("ferme/volaille/mortvolaille-fiche.jsp");
    pr.getTableau().setLienAdd("ferme/volaille/mortvolaille-saisie.jsp");
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Gestion des morts et perdus de volailles</h1>
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