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
 * This maps an incoming ID to an NSL destination id. It relies on three pieces of information to uniquely identify the
 * resource we're looking for, namely:
 *  <ul>
 *      <li>namespace - the (source) namespace, e.g. APNI or AMANI</li>
 *      <li>system - the source system, e.g. AUTHOR, or NSL-AUTHOR</li>
 *      <li>fromId - the source ID (a number)</li>
 *  </ul>
 *
 * because the NSL currently has unique IDs, the combination of fromId and ID should be unique.
 */
class IdMapper {

    Namespace namespace //source namespace of the data e.g. APNI
    String system //system the fromId is from e.g. AUTHOR
    Long fromId //The incoming Id
    Long toId

    static mapping = {

        version false

        namespace index: 'id_mapper_from_Index'
        system index: 'id_mapper_from_Index'
        fromId index: 'id_mapper_from_Index'
    }

    static constraints = {
        fromId unique: 'toId'
        toId nullable: true
        system inList: [
                'AUTHOR',
                'PLANT_NAME_REFERENCE',
                'REFERENCE',
                'PLANT_NAME',
                'AUTHOR_REFERENCE',
                'PUBLICATION',
                'NSL_AUTHOR',
                'NSL_INSTANCE',
                'NSL_NAME',
                'NSL_REFERENCE'
        ]
    }
}
