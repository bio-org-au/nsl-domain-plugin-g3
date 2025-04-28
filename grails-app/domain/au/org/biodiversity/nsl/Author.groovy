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

class Author {

    String uri
    String abbrev
    String name
    String fullName
    String dateRange
    String notes
    String ipniId
    Author duplicateOf
    Boolean validRecord = false

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    String sourceSystem
    String sourceIdString
    Long sourceId

    Namespace namespace

    static hasMany = [namesForAuthor           : Name,
                      namesForBaseAuthor       : Name,
                      namesForExAuthor         : Name,
                      namesForExBaseAuthor     : Name,
                      namesForSanctioningAuthor: Name,
                      references               : Reference,
                      comments                 : Comment
    ]
    static belongsTo = [Namespace]

    static mappedBy = [namesForAuthor           : "author",
                       namesForBaseAuthor       : "baseAuthor",
                       namesForExAuthor         : "exAuthor",
                       namesForExBaseAuthor     : "exBaseAuthor",
                       namesForSanctioningAuthor: "sanctioningAuthor",
                       comments                 : "author"
    ]

    static mapping = {

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        uri sqlType: 'text'
        validRecord defaultvalue: "false"

        sourceId index: 'Auth_Source_Index'
        sourceIdString index: 'Auth_Source_String_Index'
        sourceSystem index: 'Auth_Source_Index,Auth_System_Index'
        namespace index: 'Auth_Source_Index'

        abbrev index: 'Author_Abbrev_Index'
        name index: 'Author_Name_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        uri nullable: true
        abbrev nullable: true, maxSize: 150, unique: true
        name nullable: true, maxSize: 1000
        fullName nullable: true
        dateRange nullable: true, maxSize: 50
        notes nullable: true, maxSize: 1000
        ipniId nullable: true, maxSize: 50
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
        duplicateOf nullable: true
    }

    @Override
    String toString() {
        return "Author $id: ${name ?: abbrev}"
    }
}
