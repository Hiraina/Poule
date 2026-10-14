package ferme.volaille;

import bean.TypeObjet;
import java.sql.Connection;

public class TypeVolaille extends TypeObjet {
    public TypeVolaille() {
        super.setNomTable("TYPEVOLAILLE");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("TYPEVOLAILLE");
        this.preparePk("TV", "GETSEQ_TYPEVOLAILLE");
        this.setId(this.makePK(c));
    }
}