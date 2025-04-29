package au.org.biodiversity.nsl

import java.sql.Timestamp

class TreeVersion {

    Tree tree
    Boolean published = false
    TreeVersion previousVersion
    String draftName

    String logEntry
    String createdBy
    Timestamp createdAt
    String publishedBy
    Timestamp publishedAt

    static hasMany = [treeVersionElements: TreeVersionElement]
    static belongsTo = [Tree]

    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        published defaultvalue: "false"
        draftName sqlType: 'Text'
        createdAt sqlType: 'timestamp with time zone'
        publishedAt sqlType: 'timestamp with time zone'
        logEntry sqlType: 'Text'

    }

    static constraints = {
        draftName maxSize: 1000
        logEntry maxSize: 4000, nullable: true
        publishedBy maxSize: 100, nullable: true
        publishedAt nullable: true
        previousVersion nullable: true
    }

    String hostPart() {
        tree.hostName
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (!(o instanceof TreeVersion)) return false

        TreeVersion that = (TreeVersion) o

        return id == that.id
    }

    int hashCode() {
        id ? id.hashCode() : 0
    }
}
