plugins {
    alias(libs.plugins.spring.boot) apply false
    alias(libs.plugins.spotless) apply false
}
subprojects {
    apply(plugin = "java-library")
    apply(plugin = "com.diffplug.spotless")
    repositories { mavenCentral() }
    configure<JavaPluginExtension> { toolchain.languageVersion.set(JavaLanguageVersion.of(25)) }
    dependencies {
        "testImplementation"(platform(rootProject.libs.junit.bom))
        "testImplementation"("org.junit.jupiter:junit-jupiter")
        "testRuntimeOnly"("org.junit.platform:junit-platform-launcher")
    }
    tasks.withType<Test>().configureEach {
        useJUnitPlatform()
        systemProperty("kiln.fixtures", rootProject.file("../fixtures/contracts").absolutePath)
    }
    configure<com.diffplug.gradle.spotless.SpotlessExtension> {
        java { googleJavaFormat("1.28.0") }
    }
    dependencyLocking { lockAllConfigurations() }
}
