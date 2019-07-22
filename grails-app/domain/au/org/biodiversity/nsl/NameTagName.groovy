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

import java.sql.Timestamp

/**
 * NameTagName is an explicit join table for Name to NameTag so we can use it in HQL properly
 */
class NameTagName implements Serializable {

    Name name
    NameTag tag

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    static mapping = {
        //datasource 'nsl'
        id composite: ['name', 'tag']
        version(false)
        name index: 'Name_Tag_Name_Index'
        tag index: 'Name_Tag_Tag_Index'

        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {

    }
}
