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
class NameStatus {

    String name
    Boolean nomIlleg
    Boolean nomInval
    NameStatus nameStatus
    NameGroup nameGroup
    Boolean display = true
    Boolean deprecated = false
    String rdfId
    String descriptionHtml

    static hasMany = [
            nameStatuses: NameStatus,
            names       : Name
    ]
    static belongsTo = [NameGroup]

    static mapping = {

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        display defaultValue: "true"
        deprecated defaultValue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name nullable: true, maxSize: 50 //note unique constraint defined in sql elsewhere because GORM/Hibernate doesn't give it a unique constraint name.
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        NameStatus nameStatus = (NameStatus) o

        return (id == nameStatus.id)
    }

    int hashCode() {
        return (id != null ? id.hashCode() : 0)
    }

}
