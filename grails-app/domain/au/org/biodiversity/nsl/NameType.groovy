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

@ToString(includes = 'name')
class NameType {

    String name
    Boolean hybrid = false
    Boolean autonym = false
    Boolean formula = false
    Boolean scientific = false
    Boolean cultivar = false
    Boolean deprecated = false
    Integer sortOrder = 0
    String connector
    NameGroup nameGroup
    NameCategory nameCategory
    String rdfId
    String descriptionHtml

    static hasMany = [names: Name]
    static belongsTo = [NameCategory, NameGroup]

    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        deprecated defaultvalue: "false"
        hybrid defaultvalue: "false"
        autonym defaultvalue: "false"
        formula defaultvalue: "false"
        scientific defaultvalue: "false"
        cultivar defaultvalue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        //note unique name + nameGroup constraint defined in sql elsewhere because GORM/Hibernate doesn't give it a unique constraint name.
        sortOrder min: 0, max: 500
        connector maxSize: 1, nullable: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        NameType nameType = (NameType) o

        return (id == nameType.id)
    }

    int hashCode() {
        return (id != null ? id.hashCode() : 0)
    }

}
