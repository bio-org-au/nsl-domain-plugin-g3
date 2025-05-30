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

class InstanceNote {

    Instance instance
    InstanceNoteKey instanceNoteKey
    String value

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    String sourceSystem
    String sourceIdString
    Long sourceId

    Namespace namespace

    static belongsTo = [Instance, InstanceNoteKey]

    static mapping = {

        id generator: 'sequence', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        sourceId index: 'Note_Source_Index'
        sourceIdString index: 'Note_Source_String_Index'
        sourceSystem index: 'Note_Source_Index,Note_System_Index'
        namespace index: 'Note_Source_Index'

        instance index: 'Note_Instance_Index'
        instanceNoteKey index: 'Note_Key_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        value maxSize: 4000

        updatedBy maxSize: 50
        createdBy maxSize: 50
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
    }

    @Override
    String toString() {
        "Text $id: ${instanceNoteKey.name}; $value"
    }
}
