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

@ToString(includes = ['name'])
class RefType {

    String name
    Boolean parentOptional
    RefType parent
    String rdfId
    String descriptionHtml
    //NSL-1827 get reference details from parent.
    Boolean useParentDetails

    static hasMany = [refTypes  : RefType,
                      references: Reference]

    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        descriptionHtml sqlType: 'text'
        parentOptional defaultValue: false
        useParentDetails defaultValue: false
    }

    static constraints = {
        name maxSize: 50, unique: true
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }
}
