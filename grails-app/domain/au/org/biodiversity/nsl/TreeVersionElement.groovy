package au.org.biodiversity.nsl

import java.sql.Timestamp

class TreeVersionElement {

    TreeVersionElement parent
    TreeElement treeElement
    TreeVersion treeVersion
    Long taxonId

    String treePath
    String namePath
    Integer depth = 0
    String elementLink
    String taxonLink
    Boolean mergeConflict = false

    String updatedBy
    Timestamp updatedAt

    static belongsTo = [TreeVersion, TreeElement]

    static mapping = {

        id generator: 'assigned', name: 'elementLink', type: 'string'
        version false

        elementLink sqlType: 'Text', index: 'tree_version_element_link_index'
        parent sqlType: 'Text', index: 'tree_version_element_parent_index'
        taxonLink sqlType: 'Text', index: 'tree_version_element_taxon_link_index'
        treeElement index: 'tree_version_element_element_index'
        treeVersion index: 'tree_version_element_version_index'
        taxonId index: 'tree_version_element_taxon_id_index'
        treePath sqlType: 'Text', index: "tree_path_index"
        namePath sqlType: 'Text', index: "tree_name_path_index"
        depth defaultValue: 0
        updatedAt sqlType: 'timestamp with time zone'
        mergeConflict defaultValue: false
    }

    static constraints = {
        parent nullable: true
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (!(o instanceof TreeVersionElement)) return false

        TreeVersionElement that = (TreeVersionElement) o

        if (elementLink != that.elementLink) return false

        return true
    }

    int hashCode() {
        return elementLink ? elementLink.hashCode() : 0
    }

    String toString() {
        "TreeVersionElement ${treeElement?.simpleName} v: ${treeVersion?.id} e:${treeElement?.id} ($elementLink) t: $taxonId"
    }

    String fullElementLink() {
        "${hostPart()}$elementLink"
    }

    String fullTaxonLink() {
        "${hostPart()}$taxonLink"
    }

    String hostPart() {
        treeVersion.hostPart()
    }
}
