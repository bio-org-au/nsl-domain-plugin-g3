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

class Comment {

    String text
    Name name
    Instance instance
    Author author
    Reference reference

    String updatedBy
    Timestamp updatedAt
    String createdBy
    Timestamp createdAt

    static belongsTo = [Name, Instance, Reference, Author]


    static mapping = {
        //datasource 'nsl'

        id generator: 'native', params: [sequence: 'hibernate_sequence'], defaultValue: "nextval('hibernate_sequence')"
        version column: 'lock_version', defaultValue: "0"
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
        text sqlType: 'text'

        name index: 'Comment_name_Index'
        instance index: 'Comment_instance_Index'
        author index: 'Comment_author_Index'
        reference index: 'Comment_reference_Index'
    }

    static constraints = {
        name nullable: true
        instance nullable: true
        author nullable: true
        reference nullable: true
        updatedBy maxSize: 50
        createdBy maxSize: 50
    }

    @Override
    String toString() {
        def entity = name ?: instance ?: author ?: reference ?: 'nothing'
        "Comment $id: ${text} (${updatedBy} @ ${updatedAt}) on $entity"
    }
}
