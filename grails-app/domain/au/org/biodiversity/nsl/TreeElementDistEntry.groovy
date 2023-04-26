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

    @Override
    int compareTo(TreeElementDistEntry o1, TreeElementDistEntry o2) {
        return o1.id == o2.id || (o1.treeElement.id == o2.treeElement.id && o1.distEntry.id == o2.distEntry.id)
    }

    String toString() {
        return "TreeElementDistEntry : $id, $treeElement.id, $distEntry.id:$distEntry.display"
    }
}
