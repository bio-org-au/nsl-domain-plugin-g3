package au.org.biodiversity.nsl


import net.kaleidos.hibernate.usertype.JsonbMapType

import java.sql.Timestamp

class TreeElement {

    TreeElement previousElement

    Long instanceId          //unconstrained FK to the instance - depends on the shard
    Long nameId              //unconstrained FK to the name - depends on the shard
    Boolean excluded = false //is this an excluded concept

    String displayHtml
    String synonymsHtml
    String simpleName
    String nameElement
    String rank
    String sourceShard      //where the taxon comes from
    Map synonyms
    Map profile

    String sourceElementLink //Link to the source tree element for composed trees
    String nameLink
    String instanceLink

    String updatedBy
    Timestamp updatedAt

    static hasMany = [treeVersionElements: TreeVersionElement, distributionEntries: TreeElementDistEntry]

    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        nameId index: "tree_element_name_index"
        instanceId index: "tree_element_instance_index"
        previousElement index: "tree_element_previous_index"
        updatedAt sqlType: 'timestamp with time zone'
        displayHtml sqlType: 'Text'
        synonymsHtml sqlType: 'Text'
        simpleName sqlType: 'Text', index: "tree_simple_name_index"
        sourceShard sqlType: 'Text'
        nameLink sqlType: 'Text'
        instanceLink sqlType: 'Text'
        sourceElementLink sqlType: 'Text'
        synonyms type: JsonbMapType
        profile type: JsonbMapType
        excluded defaultValue: false
    }

    static constraints = {
        previousElement nullable: true
        sourceElementLink nullable: true
        synonyms nullable: true
        rank maxSize: 50
        nameElement maxSize: 255
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (!(o instanceof TreeElement)) return false

        TreeElement that = (TreeElement) o

        if (excluded != that.excluded) return false
        if (id != that.id) return false
        if (instanceId != that.instanceId) return false
        if (instanceLink != that.instanceLink) return false
        if (nameId != that.nameId) return false
        if (nameLink != that.nameLink) return false

        return true
    }

    int hashCode() {
        int result
        result = (instanceId != null ? instanceId.hashCode() : 0)
        result = 31 * result + (nameId != null ? nameId.hashCode() : 0)
        result = 31 * result + (excluded != null ? excluded.hashCode() : 0)
        result = 31 * result + (nameLink != null ? nameLink.hashCode() : 0)
        result = 31 * result + (instanceLink != null ? instanceLink.hashCode() : 0)
        result = 31 * result + (id != null ? id.hashCode() : 0)
        return result
    }
    static transients = ['name', 'instance']

    /**
     * Null if name doesn't exist
     * @return the name for NameId. Note this doesn't work for trees outside the shard
     */
    Name getName() {
        Name.get(nameId)
    }

    /**
     * Null if instance doesn't exist
     * @return the instance for InstanceId. Note this doesn't work for trees outside the shard
     */
    Instance getInstance() {
        Instance.get(instanceId)
    }

    String toString() {
        "TreeElement: $simpleName : $id"
    }
}
