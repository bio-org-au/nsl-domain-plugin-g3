package net.kaleidos.hibernate.usertype

import groovy.transform.CompileStatic
import org.hibernate.HibernateException
import org.hibernate.engine.spi.SessionImplementor
import org.hibernate.engine.spi.SharedSessionContractImplementor
import org.hibernate.usertype.UserType

import java.sql.PreparedStatement
import java.sql.ResultSet
import java.sql.SQLException
import java.sql.Types

@CompileStatic
class HstoreMapType implements UserType {

    static int SQLTYPE = 90011

    @Override
    int[] sqlTypes() {
        return SQLTYPE as int[]
    }

    @Override
    Class<?> returnedClass() {
        Map
    }

    @Override
    boolean equals(Object x, Object y) throws HibernateException {
        if (x == null) {
            return y == null
        }

        Map m1 = x as Map
        Map m2 = y as Map

        return m1.equals(m2)
    }

    @Override
    int hashCode(Object x) throws HibernateException {
        x ? x.hashCode() : 0
    }

    @Override
    Object nullSafeGet(ResultSet rs, String[] names, SharedSessionContractImplementor session, Object owner) throws HibernateException, SQLException {
        String col = names[0]
        String val = rs.getString(col)

        return HstoreHelper.toMap(val)
    }

    @Override
    void nullSafeSet(PreparedStatement st, Object value, int index, SharedSessionContractImplementor session) throws HibernateException, SQLException {
        String s = HstoreHelper.toString(value as Map)
        st.setObject(index, s, Types.OTHER)
    }

    @Override
    Object deepCopy(Object value) throws HibernateException {
        value == null ? null : new HashMap(value as Map)
    }

    @Override
    boolean isMutable() {
        true
    }

    @Override
    Serializable disassemble(Object value) throws HibernateException {
        value as Serializable
    }

    @Override
    Object assemble(Serializable cached, Object owner) throws HibernateException {
        cached
    }

    @Override
    Object replace(Object original, Object target, Object owner) throws HibernateException {
        original
    }
}
