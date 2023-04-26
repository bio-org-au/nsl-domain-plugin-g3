package au.org.biodiversity.nsl

import java.sql.Timestamp

class TreeElementDistEntry implements Comparable<TreeElementDistEntry> {
    String updatedBy
    Timestamp updatedAt

    static belongsTo = [treeElement: TreeElement, distEntry: DistEntry]

    static constraints = {
    }

    static mapping = {
        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        table "tree_element_distribution_entries"
        updatedAt sqlType: 'timestamp with time zone'
    }

    String toString() {
        return "TreeElementDistEntry : $id, $treeElement.id, $distEntry.id:$distEntry.display"
    }

    @Override
    int compareTo(TreeElementDistEntry o) {
        return id ? o?.id ? (id.compareTo(o.id) ?: treeElement.id.compareTo(treeElement.id) ?: distEntry.id.compareTo(o.distEntry.id)) : 1 : -1
    }
}
