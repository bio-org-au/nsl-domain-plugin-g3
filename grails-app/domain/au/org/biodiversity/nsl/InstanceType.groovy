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
class InstanceType {

    String name
    String ofLabel
    String hasLabel
    Boolean primaryInstance = false
    Boolean secondaryInstance = false
    Boolean relationship = false
    Boolean protologue = false
    Boolean taxonomic = false
    Boolean nomenclatural = false
    Boolean synonym = false
    Boolean proParte = false
    Boolean doubtful = false
    Boolean misapplied = false
    Boolean standalone = false
    Boolean unsourced = false
    Boolean citing = false
    Boolean deprecated = false
    Boolean bidirectional = false
    Integer sortOrder = 0
    String rdfId
    String descriptionHtml

    static mapping = {
        //datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        primaryInstance defaultvalue: "false"
        secondaryInstance defaultvalue: "false"
        relationship defaultvalue: "false"
        protologue defaultvalue: "false"
        taxonomic defaultvalue: "false"
        nomenclatural defaultvalue: "false"
        synonym defaultvalue: "false"
        proParte defaultvalue: "false"
        doubtful defaultvalue: "false"
        misapplied defaultvalue: "false"
        standalone defaultvalue: "false"
        unsourced defaultvalue: "false"
        citing defaultvalue: "false"
        deprecated defaultvalue: "false"
        bidirectional defaultvalue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true
        ofLabel maxSize: 255
        hasLabel maxSize: 255
        sortOrder min: 0, max: 500
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        InstanceType instanceType = (InstanceType) o

        return (id == instanceType.id)
    }

    int hashCode() {
        return (id != null ? id.hashCode() : 0)
    }

}
