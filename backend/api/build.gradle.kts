plugins { alias(libs.plugins.spring.boot) }
dependencies {
    implementation(project(":application"))
    implementation(project(":infrastructure"))
    implementation(platform("org.springframework.boot:spring-boot-dependencies:4.1.1"))
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation(libs.jackson)
}
