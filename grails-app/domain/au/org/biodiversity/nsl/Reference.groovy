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

class Reference {

    String uri
    String doi
    String title
    String displayTitle
    String abbrevTitle
    Integer year                //a number representing a date year.
    String volume
    String edition
    String pages
    String verbatimReference
    String verbatimCitation
    String verbatimAuthor
    String citation
    String citationHtml
    String notes
    Boolean published
    String publisher
    String publishedLocation
    String publicationDate     //verbatim date of publication
    String isoPublicationDate  //another string as a date.
    String isbn
    String issn
    String bhlUrl
    String tl2
    RefType refType

    Reference parent
    Author author

    RefAuthorRole refAuthorRole
    Reference duplicateOf
    Language language
    Boolean validRecord = false

    Timestamp updatedAt
    String updatedBy
    Timestamp createdAt
    String createdBy

    String sourceSystem
    String sourceIdString
    Long sourceId

    Namespace namespace

    static hasMany = [
            instances               : Instance,
            referencesForDuplicateOf: Reference,
            referencesForParent     : Reference,
            comments                : Comment
    ]
    static belongsTo = [Language, Namespace, RefAuthorRole, RefType]

    static mappedBy = [
            referencesForDuplicateOf: "duplicateOf",
            referencesForParent     : "parent",
            comments                : "reference"
    ]

    static mapping = {

        id generator: 'sequence', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"
        uri sqlType: 'text'
        validRecord defaultvalue: "false"

        sourceId index: 'Ref_Source_Index'
        sourceIdString index: 'Ref_Source_String_Index'
        sourceSystem index: 'Ref_Source_Index,Ref_System_Index'
        namespace index: 'Ref_Source_Index'

        //FK indexes
        refType index: 'Reference_Type_Index'
        parent index: 'Reference_Parent_Index'
        author index: 'Reference_Author_Index'
        refAuthorRole index: 'Reference_AuthorRole_Index'
        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        uri nullable: true
        doi nullable: true, unique: true
        title maxSize: 2000
        displayTitle maxSize: 2000
        abbrevTitle nullable: true, maxSize: 2000
        year nullable: true, min: 0, max: 2999
        volume nullable: true, maxSize: 100
        edition nullable: true, maxSize: 100
        pages nullable: true, maxSize: 1000
        verbatimReference nullable: true, maxSize: 1000
        verbatimCitation nullable: true, maxSize: 2000
        verbatimAuthor nullable: true, maxSize: 1000
        notes nullable: true, maxSize: 1000
        parent nullable: true
        publisher nullable: true, maxSize: 1000
        publishedLocation nullable: true, maxSize: 1000
        publicationDate nullable: true, maxSize: 50
        isoPublicationDate nullable: true, maxSize: 10
        isbn nullable: true, maxSize: 16
        issn nullable: true, maxSize: 16
        bhlUrl nullable: true, maxSize: 4000
        tl2 nullable: true, maxSize: 30
        citation nullable: true, maxSize: 4000
        citationHtml nullable: true, maxSize: 4000

        updatedBy maxSize: 1000
        sourceSystem nullable: true, maxSize: 50
        sourceIdString nullable: true, maxSize: 100
        sourceId nullable: true
    }

    String getIsoYear() {
        isoPublicationDate?.substring(0, 4)
    }

    @Override
    String toString() {
        List<String> bits = ["Reference $id: ($refType.name);"]
        bits << "${displayTitle == 'Not set' ? '' : displayTitle} (${year ?: publicationDate});"
        bits << "${author ?: ''};"
        bits << "${parent ?: ''}"
        return bits.join(' ')
    }

}
