dependencies {
    api(project(":application"))
    implementation(libs.sqlite)
    implementation(libs.jackson)
    implementation(libs.bouncycastle)
    implementation(libs.mail)
}
