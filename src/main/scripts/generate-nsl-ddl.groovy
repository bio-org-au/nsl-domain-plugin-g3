import grails.dev.commands.ExecutionContext

description "This generates the NSL DDL from the domain objects and sql sources in webapp/sql", "grails generate-nsl-ddl"

println "Generating NSL DDL from domain objects and sql sources"

try {
    runCommand('schema-export')

    File ddl = new File("build/ddl.sql")
    String text = ddl.text
            .replaceAll(/alter table/, 'alter table if exists')
            .replaceAll(/drop table/, 'drop table if exists')
            .replaceAll(/boolean not null/, 'boolean default false not null')
            .replaceAll(/create sequence nsl_global_seq;/, '')
            .replaceAll(/drop sequence nsl_global_seq;/, 'drop sequence nsl_global_seq;\n    create sequence nsl_global_seq minvalue 1000 maxvalue 10000000;')
            .replaceAll(/create sequence hibernate_sequence;/, '')
            .replaceAll(/drop sequence hibernate_sequence;/, 'drop sequence hibernate_sequence;\n    create sequence hibernate_sequence;')

    File dataDir = new File("src/main/resources/sql")
    File viewsDir = new File(dataDir, 'views')
    File nslDdl = new File(dataDir, "nsl-ddl.sql")
    nslDdl.write(text)
    viewsDir.listFiles().sort().each { File view ->
        nslDdl.append("\n-- ${view.name}\n")
        nslDdl.append(view.text)
    }
    return true
} catch (e) {
    println e.message
    return false
}