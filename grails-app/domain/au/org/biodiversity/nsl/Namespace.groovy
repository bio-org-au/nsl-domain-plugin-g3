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

@ToString
class Namespace {

    String name
    String rdfId
    String descriptionHtml

    static mapping = {

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        authors joinTable: "AUTHOR_NAMESPACE"
        names joinTable: "NAME_NAMESPACE"
        references joinTable: "REF_NAMESPACE"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }

    static transients = ['matches']

    Boolean matches(String nameSpaceName, boolean exact = false) {
        return nameSpaceName.toLowerCase() == name.toLowerCase()
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        Namespace namespace = (Namespace) o

        if (descriptionHtml != namespace.descriptionHtml) return false
        if (id != namespace.id) return false
        if (name != namespace.name) return false
        if (rdfId != namespace.rdfId) return false

        return true
    }

    int hashCode() {
        int result
        result = (name != null ? name.hashCode() : 0)
        result = 31 * result + (rdfId != null ? rdfId.hashCode() : 0)
        result = 31 * result + (descriptionHtml != null ? descriptionHtml.hashCode() : 0)
        result = 31 * result + (id != null ? id.hashCode() : 0)
        return result
    }
}
