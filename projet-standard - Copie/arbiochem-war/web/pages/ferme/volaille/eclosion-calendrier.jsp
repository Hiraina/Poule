<%--
  Calendrier Éclosion - Grille mois/jour avec prédiction vs réel
  Pattern basé sur ca-calendrier-v2.jsp
--%>
<%@ page import="affichage.*" %>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@ page import="utils.ConstanteAsync" %>
<%@ page import="utils.UrlUtils" %>
<%@ page import="java.sql.Date" %>
<%@ page import="java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%@ page import="utilitaire.Utilitaire" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Vector" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="ferme.volaille.EclosionCalendrier" %>
<%@ page import="ferme.volaille.EclosionJourDetail" %>
<%@ page import="utils.CalendarUtil" %>

<style>
    .table-container {
        max-width: 100%;
        max-height: 80vh;
        overflow-y: auto;
        overflow-x: auto;
        border: 1px solid #ccc;
        padding: 0;
    }

    table {
        border-collapse: collapse;
        width: 100%;
        table-layout: auto;
        min-width: fit-content;
    }

    th, td {
        border: 1px solid #999;
        padding: 6px;
        text-align: right;
        font-size: 11px;
    }

    th {
        background-color: #f2f2f2;
        text-align: center;
        position: sticky;
        top: 0;
        z-index: 2;
    }

    .jour-cell {
        text-align: center;
        position: sticky;
        left: 0;
        background: #fff;
        z-index: 1;
        width: 100px;
    }

    .jour{
        text-align: left;
        position: sticky;
        left: 0;
        background: #fff;
        z-index: 3;
        min-width: 100px;
        max-width: 100px;
        white-space: nowrap;
    }

    .dimanche {
        background-color: #fdd;
    }

    .oeufs {
        color: #0066cc;
        font-weight: bold;
    }
    .poussins {
        color: #009900;
        font-weight: bold;
    }
    .taux {
        color: #cc6600;
    }
    .montant{
        text-align: right;
    }

    .total{
        font-weight: bold;
    }
    .predit {
        background-color: #e8f0fe;
    }
    .reel {
        background-color: #e8f5e9;
    }
    .alerte {
        background-color: #fff3e0;
    }

    .legend {
        margin: 10px 0;
        padding: 10px;
        background: #f9f9f9;
        border-radius: 4px;
        font-size: 12px;
    }
    .legend span {
        display: inline-block;
        margin-right: 15px;
        padding: 2px 8px;
        border-radius: 3px;
    }
</style>

<%
    try{
        String lien = (String) session.getValue("lien");
        user.UserEJB u= (user.UserEJB) session.getValue("u");

        /* Récuperer la date par défaut */
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        String dateEncours = request.getParameter("d");
        LocalDate dtJour = LocalDate.now();
        if (dateEncours!=null){
            dateEncours = CalendarUtil.castDateToFormat(dateEncours,DateTimeFormatter.ofPattern("yyyy-MM-dd"),formatter);
            dtJour = LocalDate.parse(dateEncours,formatter);
        }
        if (dateEncours == null || dateEncours.trim().isEmpty()) {
            LocalDate aujourdHui = LocalDate.now();
            dateEncours = aujourdHui.format(formatter);
        }

        String debutEtFinDeSemaine[]=CalendarUtil.getDebutFinAnnee(dtJour,request.getParameter("moisDebut"),request.getParameter("anneeDebut"),request.getParameter("moisFin"),request.getParameter("anneeFin"));
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");
        EclosionCalendrier eta=new EclosionCalendrier(debutEtFinDeSemaine[0],debutEtFinDeSemaine[1]);
        String[] listeDate=eta.getListeMois();
        int [] listeJours=eta.getJours();
        HashMap<String,Double[]> total = eta.getTotal();

        // URL du site
        String urlComplete = request.getRequestURL().toString();
        String queryString = request.getQueryString();

        if (queryString != null) {
            urlComplete += "?" + queryString;
        }
        String lienPrecedent = UrlUtils.modifierParametreDansUrl(urlComplete,"d" ,CalendarUtil.castDateToFormat(debutEtFinDeSemaine[2],formatter,DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        String lienSuivant = UrlUtils.modifierParametreDansUrl(urlComplete,"d" ,CalendarUtil.castDateToFormat(debutEtFinDeSemaine[3],formatter,DateTimeFormatter.ofPattern("yyyy-MM-dd")));

        String temp="";
        temp=temp+ "<div class=\"modal fade\" id=\"linkModal\" tabindex=\"-1\" role=\"dialog\" aria-labelledby=\"linkModalLabel\" aria-hidden=\"true\">\r\n" +
                "  <div style='width:60%;background:transparent;' class=\"modal-dialog modal-dialog-centered\" role=\"dialog\">\r\n" + //
                "    <div style=\"border-radius: 16px;padding:15px;overflow-y:auto;height:80vh\" class=\"modal-content\">\r\n" + //
                "      <div class=\"modal-body\">\r\n"+
                "       <div id=\"modalContent\">\r\n>";
        temp +=                "</div>\r\n" + //
                "    </div>\r\n" + //
                "   </div>\r\n" + //
                "  </div>\r\n" + //
                "</div>";
        String bute = "ferme/volaille/eclosion-calendrier.jsp";

        String[] mois = {
                "Janvier", "F&eacute;vrier", "Mars",
                "Avril", "Mai", "Juin",
                "Juillet", "Aout", "Septembre",
                "Octobre", "Novembre", "D&eacute;cembre"
        };
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Calendrier Éclosion - Prédit vs Réel</h1>
    </section>
    <div style="width: 100%;display: flex;justify-content: space-between;align-items: end">
        <form class="col-md-6 col-xs-12 nopadding" action="<%=lien%>?but=<%= bute %>" method="Get" style="border-radius: 8px;display: flex;align-items: end;">
            <div class="form-input col-md-4 col-xs-12 nopadding">
                <label class="input-label">Mois & Ann&eacute;e D&eacute;but</label>
                <span style="display: flex;gap: 2px">
                    <select class="form-control" name="moisDebut">
                        <% for (int i = 0; i < mois.length; i++) {
                            String isSelected = "";
                            String moisDebutParam = request.getParameter("moisDebut");
                            if (moisDebutParam != null && moisDebutParam.equals(String.valueOf(i+1))){
                                isSelected = "selected";
                            }
                        %>
                            <option value="<%=i+1%>" <%=isSelected%>><%=mois[i]%></option>
                        <% } %>
                    </select>
                    <% String defaultYear = String.valueOf(LocalDate.now().getYear()); %>
                    <input class="form-control" type="number" name="anneeDebut" value="<%= (request.getParameter("anneeDebut") != null && !request.getParameter("anneeDebut").trim().isEmpty()) ? request.getParameter("anneeDebut") : defaultYear %>">
                </span>
            </div>
            <div class="form-input col-md-4 col-xs-12">
                <label class="input-label">Mois & Ann&eacute;e Fin</label>
                <span style="display: flex;gap: 2px">
                    <select class="form-control" name="moisFin">
                        <% for (int i = 0; i < mois.length; i++) {
                            String isSelected = "";
                            String moisFinParam = request.getParameter("moisFin");
                            if (moisFinParam != null && moisFinParam.equals(String.valueOf(i+1))){
                                isSelected = "selected";
                            }
                        %>
                            <option value="<%=i+1%>" <%=isSelected%>><%=mois[i]%></option>
                        <% } %>
                    </select>
                    <input class="form-control" type="number" name="anneeFin" value="<%= (request.getParameter("anneeFin") != null && !request.getParameter("anneeFin").trim().isEmpty()) ? request.getParameter("anneeFin") : defaultYear %>">
                </span>
            </div>
            <input type='hidden' value='<%=bute%>' name='but'>
            <div class="form-input col-md-4 col-xs-12">
                <button class="btn btn-primary btn-small" style="width: 70%;height: 32px;text-align: center" type="submit">Afficher</button>
            </div>
        </form>
    </div>

    <!-- Légende -->
    <div class="legend">
        <span style="background:#e8f0fe;color:#0066cc">Œufs mis en incubateur (Prédit)</span>
        <span style="background:#e8f5e9;color:#009900">Poussins éclos (Réel)</span>
        <span style="background:#fff3e0;color:#cc6600">Taux éclosion < 80%</span>
        <span style="background:#fdd">Dimanche</span>
    </div>
    <div class="table-container">
        <table>
            <thead>
            <tr style="position: sticky;top:0;z-index: 5;">
                <th class="jour-cell jour">Jours</th>
                <% for(int i=0;i<listeDate.length;i++)
                { %>
                <th class="jour-cell" colspan="3" style="width: 180px;"><%= listeDate[i].toUpperCase() %></th>
                <%  } %>
            </tr>
            <tr style="position: sticky;top:30px;z-index: 4;">
                <th class="jour-cell jour"></th>
                <% for(int i=0;i<listeDate.length;i++) { %>
                <th class="jour-cell" style="width: 60px;">Œufs</th>
                <th class="jour-cell" style="width: 60px;">Poussins</th>
                <th class="jour-cell" style="width: 60px;">Taux %</th>
                <% } %>
            </tr>
            </thead>
            <tbody>
                    <% for(int i=0;i<listeJours.length;i++) {
                        int jour= listeJours[i];
                    %>
            <tr>
                <td class="jour-cell jour">
                    <%=jour%>
                </td>
                    <% for(int j=0;j<listeDate.length;j++) { %>
                <%
                    EclosionJourDetail[] eclosionJours = eta.getReservationByTime(jour,listeDate[j]);
                    if(eclosionJours != null && eclosionJours.length>0) {
                        boolean isDimanche2 = eclosionJours[0].getJourLib().equalsIgnoreCase("Dimanche");
                        double oeufs = eclosionJours[0].getOeufsMisIncubateur();
                        double poussins = eclosionJours[0].getPoussinsEclos();
                        double taux = eclosionJours[0].getTauxEclosion();
                        String jj = eclosionJours[0].getJourLib().substring(0, 3)+".";
                        boolean tauxBas = taux > 0 && taux < 80;
                %>
                <td class="jour-cell <%= isDimanche2 ? "dimanche" : "" %> <%= tauxBas ? "alerte" : "" %> predit">
                    <%= oeufs > 0 ? String.format("%,.0f", oeufs) : "-" %>
                </td>
                <td class="jour-cell <%= isDimanche2 ? "dimanche" : "" %> <%= tauxBas ? "alerte" : "" %> reel">
                    <%= poussins > 0 ? String.format("%,.0f", poussins) : "-" %>
                </td>
                <td class="jour-cell <%= isDimanche2 ? "dimanche" : "" %> <%= tauxBas ? "alerte" : "" %> taux">
                    <%= taux > 0 ? String.format("%.1f", taux) : "-" %>
                </td>
                <%  } else { %>
                <td class="jour-cell">
                    -
                </td>
                <td class="jour-cell">
                    -
                </td>
                <td class="jour-cell">
                    -
                </td>
                <% } %>
                <%  } %>
            </tr>
            <%  } %>

            </tbody>
            <tfoot>
            <tr>
                <td class="jour-cell jour  total ">
                    TOTAL
                </td>
                <% for(int k=0;k<listeDate.length;k++) {
                    Double [] tab = total.get(listeDate[k]);
                %>
                <td class="jour-cell montant total predit" colspan="3">
                    <%= (tab != null && tab.length >= 3 && tab[0] != null && tab[0] > 0) ? 
                        String.format("%,.0f œufs / %,.0f poussins / %.1f%%", 
                            tab[0], tab[1], tab[2]) : "-" %>
                </td>
                <%  } %>
            </tr>
            </tfoot>
        </table>
    </div>
</div>

<% out.println(temp);%>

<%
    } catch (Exception e) {
        e.printStackTrace();
    } %>