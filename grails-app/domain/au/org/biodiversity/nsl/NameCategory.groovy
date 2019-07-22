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

@ToString(excludes = 'sortOrder')
class NameCategory {

    String name
    Integer sortOrder = 0
    String rdfId
    String descriptionHtml

    Integer maxParentsAllowed
    Integer minParentsRequired
    String parent1HelpText
    String parent2HelpText
    Boolean requiresFamily = false
    Boolean requiresHigherRankedParent = false
    Boolean requiresNameElement = false
    Boolean takesAuthorOnly = false
    Boolean takesAuthors = false
    Boolean takesCultivarScopedParent = false
    Boolean takesHybridScopedParent = false
    Boolean takesNameElement = false
    Boolean takesVerbatimRank = false
    Boolean takesRank = false

    static hasMany = [nameTypes: NameType]

    static mapping = {
        //datasource 'nsl'

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        sortOrder defaultValue: "0"
        descriptionHtml sqlType: 'text'
        maxParentsAllowed defaultValue: 0
        minParentsRequired defaultValue: 0
        parent1HelpText sqlType: 'text', column: 'parent_1_help_text'
        parent2HelpText sqlType: 'text', column: 'parent_2_help_text'
        requiresFamily defaultValue: false
        requiresHigherRankedParent defaultValue: false
        requiresNameElement defaultValue: false
        takesAuthorOnly defaultValue: false
        takesAuthors defaultValue: false
        takesCultivarScopedParent defaultValue: false
        takesHybridScopedParent defaultValue: false
        takesNameElement defaultValue: false
        takesVerbatimRank defaultValue: false
        takesRank defaultValue: false
    }

    static constraints = {
        name maxSize: 50, unique: true
        sortOrder min: 0, max: 500
        rdfId maxSize: 50, nullable: true
        descriptionHtml nullable: true
        parent1HelpText nullable: true
        parent2HelpText nullable: true
    }
}
