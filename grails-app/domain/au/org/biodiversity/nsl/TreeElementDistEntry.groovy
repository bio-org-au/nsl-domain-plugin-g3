package au.org.biodiversity.nsl

class TreeElementDistEntry implements Serializable {
    static belongsTo = [treeElement: TreeElement, distEntry: DistEntry]

    static constraints = {
        treeElement unique: ['distEntry']
    }

    static mapping = {
        version false
        table "tree_element_distribution_entries"
        id composite: [ 'treeElement', 'distEntry']
    }

    int hashCode() {
        int result
        result = treeElement?.id
        result = 31 * result + distEntry?.id
        return result
    }

    boolean equals(other) {
        if (!(other instanceof TreeElementDistEntry)) {
            return false
        }
        other.treeElement.id == treeElement.id && other.distEntry.id == distEntry.id
    }
}
