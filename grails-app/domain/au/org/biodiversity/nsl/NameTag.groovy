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

/**
 * NameTag is a generic tag that can be applied to names. Names can have as many unique tags applied as required.
 * A tag does not imply any specific meaning within the system and is only used for categorisation by people.
 */
class NameTag {

    String name

    static hasMany = [names: NameTagName]

    static mapping = {
        version column: 'lock_version', defaultValue: "0"

        id generator: 'sequence', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
    }

    static constraints = {
        name unique: true
    }
}
