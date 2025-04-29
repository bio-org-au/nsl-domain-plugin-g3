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

import net.kaleidos.hibernate.usertype.JsonbMapType

import java.sql.Timestamp

class Name {

    String uri
    String nameElement
    String statusSummary
    String verbatimRank

    String fullName
    String fullNameHtml
    String simpleName
    String simpleNameHtml
    String sortName

    Boolean orthVar = false

    NameType nameType
    NameStatus nameStatus
    NameRank nameRank

    Name parent
    Name secondParent
    Name family
    String namePath = "" // the taxonomic name path

    Author author
    Author baseAuthor
    Author exAuthor
    Author exBaseAuthor

    Author sanctioningAuthor

    Integer publishedYear

    Boolean validRecord = false
    Boolean changedCombination = false

    Long sourceDupOfId
    Name duplicateOf

    Long sourceId
    String sourceSystem
    String sourceIdString
    Namespace namespace

    Name basionym
    Instance primaryInstance

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    Map apniJson

    static hasMany = [
            instances: Instance,
            comments : Comment,
            tags     : NameTagName,
            resources: Resource
    ]

    static mappedBy = [
            comments: "name"
    ]

    static belongsTo = [NameRank, NameStatus, NameType, Namespace]

    static mapping = {

        id generator: 'native', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        uri sqlType: 'text'
        validRecord defaultvalue: "false"
        changedCombination defaultvalue: "false"
        orthVar defaultvalue: "false"

        nameElement index: 'Name_Name_Element_Index'
        fullName index: 'Name_Full_Name_Index'
        simpleName index: 'Name_Simple_Name_Index'

        sourceId index: 'Name_Source_Index'
        sourceIdString index: 'Name_Source_String_Index'
        sourceSystem index: 'Name_Source_Index,Name_System_Index'
        namespace index: 'Name_Source_Index'

//        FK indexes
        nameType index: 'Name_Type_Index'
        nameStatus index: 'Name_Status_Index'
        nameRank index: 'Name_Rank_Index'
        author index: 'Name_author_Index'
        baseAuthor index: 'Name_baseAuthor_Index'
        exAuthor index: 'Name_exAuthor_Index'
        exBaseAuthor index: 'Name_exBaseAuthor_Index'
        sanctioningAuthor index: 'Name_sanctioningAuthor_Index'
        parent index: "name_parent_id_Index"
        secondParent index: "name_second_parent_id_Index"
        namePath sqlType: 'text', index: "name_name_path_Index", defaultValue: ""

        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'

        apniJson type: JsonbMapType
    }

    static constraints = {
        uri nullable: true
        nameElement nullable: true
        statusSummary nullable: true, maxSize: 50
        updatedBy maxSize: 50
        createdBy maxSize: 50
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
        fullName nullable: true, maxSize: 512
        fullNameHtml nullable: true, maxSize: 2048
        simpleName nullable: true, maxSize: 250
        sortName nullable: true, maxSize: 250
        simpleNameHtml nullable: true, maxSize: 2048
        sanctioningAuthor nullable: true
        exBaseAuthor nullable: true
        author nullable: true
        baseAuthor nullable: true
        exAuthor nullable: true
        sourceDupOfId nullable: true
        duplicateOf nullable: true
        parent nullable: true
        secondParent nullable: true
        family nullable: true
        verbatimRank nullable: true, maxSize: 50
        apniJson nullable: true
        publishedYear nullable: true, max: 2500, min: 1700
        basionym nullable: true
        primaryInstance nullable: true
    }

    @Override
    String toString() {
        "Name $id: ${fullName ?: nameElement}"
    }
}
