val releaseGroup: String by project
val releaseVersion: String by project

val javaCompileVersion = JavaLanguageVersion.of(libs.versions.java.compile.get())
val javaSupportVersion = JavaLanguageVersion.of(libs.versions.java.support.get())

allprojects {
    group = releaseGroup
    version = releaseVersion
}

plugins {
    java
    checkstyle
    alias(libs.plugins.shadow)
}

java.toolchain.languageVersion.set(javaCompileVersion)

checkstyle.toolVersion = libs.versions.checkstyle.get()

dependencies {
    checkstyle(libs.rulebook.checkstyle)

    implementation(libs.bundles.hadoop)
    implementation(libs.bundles.spark)
    implementation(libs.commons.lang)
    implementation(libs.commons.codec)

    testImplementation(platform(libs.junit.bom))
    testImplementation(libs.bundles.junit5)

    testRuntimeOnly(libs.junit.platform.launcher)
}

tasks {
    compileJava {
        options.release = javaSupportVersion.asInt()
    }
    test {
        useJUnitPlatform()
    }
    shadowJar {
        archiveFileName.set("hashgen.jar")
        isZip64 = true
    }
}
