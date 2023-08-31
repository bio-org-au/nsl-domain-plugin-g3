appender('STDOUT', ConsoleAppender) {
    encoder(PatternLayoutEncoder) {
        pattern =
                '%level %logger %message%n%xException'
    }
}
logger("StackTrace", ERROR, ['STDOUT'], false)
logger("au.gov", DEBUG, ['STDOUT'], false)
logger("au.org.biodiversity", DEBUG, ['STDOUT'], false)
logger("grails.plugin.externalconfig", INFO, ['STDOUT'], false)
logger("org.hibernate.orm.deprecation", OFF)
root(WARN, ['STDOUT'])
