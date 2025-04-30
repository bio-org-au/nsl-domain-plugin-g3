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

import java.sql.Clob
import java.sql.Timestamp

//todo is this used at all?
class DelayedJobs {

    BigDecimal priority
    BigDecimal attempts
    Clob handler
    Clob lastError
    Timestamp runAt
    Timestamp lockedAt
    Timestamp failedAt
    String lockedBy
    String queue
    Timestamp createdAt
    Timestamp updatedAt

    static mapping = {

        id generator: 'sequence', params: [sequence_name: 'nsl_global_seq'], defaultValue: "nextval('nsl_global_seq')"
        version column: 'lock_version', defaultValue: "0"

        runAt sqlType: 'timestamp with time zone'
        lockedAt sqlType: 'timestamp with time zone'
        failedAt sqlType: 'timestamp with time zone'


        updatedAt sqlType: 'timestamp with time zone'
        createdAt sqlType: 'timestamp with time zone'
    }

    static constraints = {
        priority nullable: true
        attempts nullable: true
        handler nullable: true
        lastError nullable: true
        runAt nullable: true
        lockedAt nullable: true
        failedAt nullable: true
        lockedBy nullable: true, maxSize: 4000
        queue nullable: true, maxSize: 4000
    }
}
