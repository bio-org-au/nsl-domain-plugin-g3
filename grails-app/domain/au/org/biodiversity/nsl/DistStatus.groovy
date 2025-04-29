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
class DistStatus {

    String name
    Boolean deprecated = false
    String descriptionHtml
    String def_link //link to the definition of this status (term)
    Integer sortOrder

    /**
     * combining status is a status that is allowed to be combined with this status
     */
    static hasMany = [combiningStatus: DistStatus]
    static belongsTo = [DistEntry]

    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        deprecated defaultValue: "false"
        descriptionHtml sqlType: 'text'
        sortOrder defaultValue: "0"
    }

    static constraints = {
        name unique: true
        descriptionHtml nullable: true
        def_link nullable: true
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        DistStatus nameStatus = (DistStatus) o

        return (id == nameStatus.id)
    }

    int hashCode() {
        return (id != null ? id.hashCode() : 0)
    }

}
