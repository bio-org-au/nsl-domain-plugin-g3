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

class Instance {

    String uri
    String verbatimNameString
    String page
    String pageQualifier
    String nomenclaturalStatus
    String bhlUrl

    InstanceType instanceType
    Name name
    Reference reference
    Instance parent
    Instance cites
    Instance citedBy
    Boolean validRecord = false
    Boolean draft = false

    Long sourceId
    String sourceSystem
    String sourceIdString
    Namespace namespace

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    String cachedSynonymyHtml  // cache for the current synonymyHtml used on a tree

    static hasMany = [
            instancesForCitedBy: Instance,
            instancesForCites  : Instance,
            instancesForParent : Instance,
            instanceNotes      : InstanceNote,
            comments           : Comment,
            resources          : Resource
    ]
    static belongsTo = [Name, Namespace, Reference]

    static mappedBy = [
            instancesForCitedBy: "citedBy",
            instancesForCites  : "cites",
            instancesForParent : "parent",
            comments           : "instance"
    ]

    static mapping = {

        id generator: 'native', params: [sequence: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        uri sqlType: 'text'
        validRecord defaultvalue: "false"
        draft defaultvalue: "false"

        sourceId index: 'Instance_Source_Index'
        sourceIdString index: 'Instance_Source_String_Index'
        sourceSystem index: 'Instance_Source_Index,Instance_System_Index'
        namespace index: 'Instance_Source_Index'

        //FK indexes
        instanceType index: 'Instance_InstanceType_Index'
        name index: 'Instance_Name_Index'
        reference index: 'Instance_Reference_Index'
        parent index: 'Instance_Parent_Index'
        cites index: 'Instance_Cites_Index'
        citedBy index: 'Instance_CitedBy_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
        cachedSynonymyHtml sqlType: 'text'
    }

    static constraints = {
        uri nullable: true
        verbatimNameString nullable: true
        page nullable: true
        pageQualifier nullable: true
        nomenclaturalStatus nullable: true, maxSize: 50
        bhlUrl nullable: true, maxSize: 4000

        parent nullable: true
        cites nullable: true
        citedBy nullable: true

        updatedBy maxSize: 1000
        createdBy maxSize: 50
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
        cachedSynonymyHtml nullable: true
    }

    @Override
    String toString() {
        "Inst $id: ${verbatimNameString ?: name}; $instanceType.name"
    }
}
