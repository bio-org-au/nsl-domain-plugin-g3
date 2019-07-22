/*
    Copyright 2015 Australian National Botanic Gardens

    This file is part of NSL-domain-plugin.

    Licensed under the Apache License, Version 2.0 (the "License"); you may not
    use this file except in compliance with the License. You may obtain a copy
    of the License at http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/
package au.org.biodiversity.nsl

import groovy.transform.ToString

@ToString(includes = "name")
class DistEntry {

    DistRegion region
    String display
    Integer sortOrder

    static hasMany = [
            status: DistStatus,
            treeElements: TreeElement
    ]

    static belongsTo = [ TreeElement ]

    static mapping = {
        //datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
    }

    static constraints = {
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        DistEntry distEntry = (DistEntry) o

        return (id == distEntry.id)
    }

    int hashCode() {
        return (id != null ? id.hashCode() : 0)
    }

}
