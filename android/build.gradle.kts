// android/build.gradle.kts
import com.android.build.gradle.LibraryExtension
import com.android.build.gradle.AppExtension

plugins {
    id("com.google.gms.google-services") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// مسیر build
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // تنظیم namespace به روش صحیح
    project.afterEvaluate {
        if (project.plugins.hasPlugin("com.android.application") ||
            project.plugins.hasPlugin("com.android.library")) {

            extensions.configure<com.android.build.gradle.BaseExtension> {
                if (namespace == null || namespace?.isEmpty() == true) {
                    namespace = project.group.toString().ifEmpty { "com.example.${project.name}" }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}