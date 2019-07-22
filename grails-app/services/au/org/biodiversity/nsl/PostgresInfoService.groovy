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

import grails.gorm.transactions.Transactional
import org.hibernate.SessionFactory
import org.hibernate.transform.Transformers

/**
 * This postgres-specific service returns information about the nsl session, allowing us to verify what databases things are running against at run time
 * @author ibis
 */

@Transactional
class PostgresInfoService {
	SessionFactory sessionFactory

	static class ConnectionInfo {
		String database
		String schema
		String currentUser
		String sessionUser
		String clientAddr
		Integer clientPort
		String serverAddr
		Integer serverPort
		Integer pid
		String version

		String toString() {
			"Connected to ${currentUser}@${schema}.${database} at ${serverAddr}:${serverPort} as ${sessionUser} at ${clientAddr}:${clientPort}"
		}
	}
	
	ConnectionInfo getConnectionInfo() {
		sessionFactory.currentSession.createSQLQuery("""
			select 
					current_database() as "database",
					current_schema() as "schema", 
					current_user as "currentUser", 
					session_user as "sessionUser",
					inet_client_addr() || '' as "clientAddr", 
					inet_client_port() as "clientPort",
					inet_server_addr() || '' as "serverAddr", 
					inet_server_port() as "serverPort",
					pg_backend_pid() as "pid", 
					version() as "version"
			""").with {
			
			setResultTransformer(Transformers.aliasToBean(ConnectionInfo.class))
			uniqueResult()
		} as ConnectionInfo
	}
}
