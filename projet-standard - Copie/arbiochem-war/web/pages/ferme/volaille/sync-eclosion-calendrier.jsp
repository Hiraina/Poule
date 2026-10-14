<%@ page import="utilitaire.UtilDB" %>
<%@ page import="ferme.volaille.EclosionJourDetailSync" %>
<%@ page import="java.sql.Connection" %>
<%
    try {
        Connection c = new UtilDB().GetConn();
        c.setAutoCommit(false);
        String dtMin = request.getParameter("dtMin");
        String dtMax = request.getParameter("dtMax");
        EclosionJourDetailSync.synchroniser(c, dtMin, dtMax);
        c.commit();
        c.close();
        out.println("SUCCESS: Synchronisation terminée");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("ERROR: " + e.getMessage());
    }
%>