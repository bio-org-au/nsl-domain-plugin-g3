package au.org.biodiversity.nsl

import net.kaleidos.hibernate.usertype.JsonbMapType

class Tree {

    String name
    String groupName  //the role group that owns/edits this tree
    TreeVersion defaultDraftTreeVersion
    TreeVersion currentTreeVersion
    Long referenceId  // an unconstrained FK to Reference for in-reference trees only.

    Boolean acceptedTree = false
    String hostName //host uri for tree version element id objects
    String descriptionHtml
    String linkToHomePage
    Map config //jsonb configuration object

    static hasMany = [treeVersions: TreeVersion]

    static mapping = {

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        name sqlType: 'Text', unique: true
        groupName sqlType: 'Text'
        descriptionHtml sqlType: 'Text', defaultValue: "'Edit me'"
        acceptedTree defaultvalue: "false"
        linkToHomePage sqlType: 'Text'
        config type: JsonbMapType
        hostName sqlType: 'Text'

    }

    static constraints = {
        name maxSize: 1000  //because it may be a citation
        groupName maxSize: 100
        currentTreeVersion nullable: true
        defaultDraftTreeVersion nullable: true
        referenceId nullable: true
        linkToHomePage nullable: true
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (!(o instanceof Tree)) return false

        Tree tree = (Tree) o

        if (groupName != tree.groupName) return false
        if (id != tree.id) return false
        if (name != tree.name) return false

        return true
    }

    int hashCode() {
        int result
        result = (name != null ? name.hashCode() : 0)
        result = 31 * result + (groupName != null ? groupName.hashCode() : 0)
        result = 31 * result + (id != null ? id.hashCode() : 0)
        return result
    }
}
