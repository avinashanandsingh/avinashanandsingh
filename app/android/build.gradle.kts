// Top-level build file
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory configuration
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// Configure subproject build directories
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Ensure app module is evaluated first
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task to remove build artifacts
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
