package au.org.biodiversity.nsl

import net.kaleidos.hibernate.usertype.*
import org.hibernate.dialect.PostgreSQL9Dialect
import org.hibernate.dialect.function.SQLFunctionTemplate
import org.hibernate.type.StandardBasicTypes

import java.sql.Types

/**
 * User: pmcneil
 * Date: 18/05/15
 */
class ExtendedPostgreSQLDialect extends PostgreSQL9Dialect {
    ExtendedPostgreSQLDialect() {
        super()
        registerFunction("regex", new SQLFunctionTemplate(StandardBasicTypes.BOOLEAN, "(unaccent(?1) ~ unaccent(?2))"))
        registerFunction("iregex", new SQLFunctionTemplate(StandardBasicTypes.BOOLEAN, "(unaccent(?1) ~* unaccent(?2))"))
        registerFunction("not_regex", new SQLFunctionTemplate(StandardBasicTypes.BOOLEAN, "(unaccent(?1) !~ unaccent(?2))"))
        registerFunction("not_iregex", new SQLFunctionTemplate(StandardBasicTypes.BOOLEAN, "(unaccent(?1) !~* unaccent(?2))"))
        registerColumnType(Types.ARRAY, 'array')
        registerColumnType(ArrayType.LONG_ARRAY, '_int8')
        registerColumnType(ArrayType.INTEGER_ARRAY, '_int4')
        registerColumnType(ArrayType.ENUM_INTEGER_ARRAY, '_int4')
        registerColumnType(ArrayType.STRING_ARRAY, '_varchar')
        registerColumnType(ArrayType.DOUBLE_ARRAY, '_float8')
        registerColumnType(ArrayType.FLOAT_ARRAY, '_float4')
        registerColumnType(ArrayType.UUID_ARRAY, '_uuid')
        registerColumnType(HstoreMapType.SQLTYPE, 'hstore')
        registerColumnType(JsonMapType.SQLTYPE, 'json')
        registerColumnType(JsonbMapType.SQLTYPE, 'jsonb')
    }
}
