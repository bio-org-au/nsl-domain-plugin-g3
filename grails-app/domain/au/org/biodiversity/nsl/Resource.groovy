package au.org.biodiversity.nsl

import java.sql.Timestamp

class Resource {

    String path
    Site site
    ResourceType resourceType

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    static hasMany = [
            instances: Instance,
            names    : Name
    ]
    static belongsTo = [Instance, Name]

    static mapping = {

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {

        path maxSize: 2400
        site nullable: false

        updatedBy maxSize: 50
        createdBy maxSize: 50
    }
}
