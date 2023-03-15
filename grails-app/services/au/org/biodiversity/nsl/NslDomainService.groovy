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
import groovy.sql.Sql
import org.hibernate.SessionFactory

@Transactional
class NslDomainService {
    def grailsApplication
    SessionFactory sessionFactory

    static final Integer currentVersion = 41

    @SuppressWarnings("unused")
    File getDdlFile() {
        URL resource = this.class.classLoader.getResource("sql/nsl-ddl.sql")
        log.info "nsl-ddl.sql file path $resource.file"
        return new File(resource.toURI())
    }

    Boolean checkUpToDate() {
        try {
            Integer dbVersion = DbVersion.get(1)?.version
            println "Current database version check: $dbVersion"
            dbVersion == currentVersion
        } catch (e) {
            log.error e.message
            e.printStackTrace()
            return false
        }
    }

    /**
     * update the database to the current version using update scripts
     * @return true if worked
     */
    @Transactional
    @SuppressWarnings("unused")
    Boolean updateToCurrentVersion(Sql sql, Map params) {
        Integer dbVersion = DbVersion.get(1)?.version
        if (!dbVersion) {
            log.error "Database version not found, not updating."
            return false
        }
        if (dbVersion > currentVersion) {
            log.error "Database version $dbVersion is ahead of the services $currentVersion. Exiting to prevent bad things."
            return false
        }

        sessionFactory.getCurrentSession().flush()
        sessionFactory.getCurrentSession().clear()
        for (Integer versionNumber in ((dbVersion + 1)..currentVersion)) {
            log.error "updating to version $versionNumber"
            URL updateFile = getUpdateFile(versionNumber)
            params.putAll(getParamsFile(versionNumber))
            if (updateFile) {
                String sqlSource = replaceParams(updateFile, params)
                runSqlBits(splitSql(sqlSource), sql)
                log.error "updated to version $versionNumber"
            }
        }
        if (params.postUpgradeScript) {
            runPostUpgradeScript((String)params.postUpgradeScript)
        }
        sessionFactory.getCurrentSession().flush()
        sessionFactory.getCurrentSession().clear()
        log.info "Update complete"
        return checkUpToDate()
    }

    def runPostUpgradeScript(String fileName) {
        log.info "Running post upgrade script $fileName"
        File updatesDir = new File(grailsApplication.config.updates.dir.toString())
        File file = new File(updatesDir, fileName)
        if (file?.exists()) {
            new GroovyShell().run(file)
        } else {
            log.error "Specified post upgrade script $fileName not found."
            throw Exception("Specified post upgrade script $fileName not found.")
        }
    }

    @SuppressWarnings("GrMethodMayBeStatic")
    private runSqlBits(String[] bits, Sql sql) {
        if (bits.size() > 0) {
            for (String bit in bits) {
                log.info "Update: ${bit.find(/.*/)}"
                String src = bit.replaceFirst(/.*/, '')
                log.debug src
                sql.execute(src) { isResultSet, result ->
                    if (isResultSet) log.debug result.toString()
                }
            }
        }
    }

    private static splitSql(String source) {
        return ('-- Start\n' + source).split(/\n--/)
    }

    private static replaceParams(URL file, Map params) {
        String sqlSource = file.text
        params.each { k, v ->
            String match = '\\$\\{' + k + '\\}'
            log.debug "Replacing $match with $v"
            sqlSource = sqlSource.replaceAll(match, v as String)
        }
        return sqlSource
    }


    Map getParamsFile(Integer versionNumber) {
        File updatesDir = new File(grailsApplication.config.updates.dir.toString())
        File file = new File(updatesDir, "UpdateTo${versionNumber}Params.groovy")
        if (file?.exists()) {
            Map params = new GroovyShell().evaluate(file.text, file.name) as Map
            return params
        }
        return [:]
    }

    URL getUpdateFile(Integer versionNumber) {
        URL resource = this.class.classLoader.getResource("sql/update-to-${versionNumber}.sql")
        log.info "nsl-ddl.sql file path $resource.file"
        return resource
    }
}
