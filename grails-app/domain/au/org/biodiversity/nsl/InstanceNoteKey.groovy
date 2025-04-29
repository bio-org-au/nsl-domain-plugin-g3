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

class InstanceNoteKey {

    String name
    Integer sortOrder = 0
    Boolean deprecated = false
    String rdfId
    String descriptionHtml

    static hasMany = [citationTexts: InstanceNote]

    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        deprecated defaultValue: "false"
        descriptionHtml sqlType: 'text'
    }

    static constraints = {
        name unique: true, maxSize: 255
        sortOrder min: 0, max: 500
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
    }

    @Override
    String toString() {
        "Key $id: $name"
    }
}
