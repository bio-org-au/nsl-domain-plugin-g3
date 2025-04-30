package au.org.biodiversity.nsl

import java.sql.Timestamp

class Site {

    String url
    String name
    String description

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    static mapping = {

        id generator: 'sequence', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {

        url maxSize: 500
        name maxSize: 100
        description maxSize: 1000

        updatedBy maxSize: 50
        createdBy maxSize: 50
    }
}
