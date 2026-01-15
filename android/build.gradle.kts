allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuración de directorios de build personalizados (tu lógica actual)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // --- INICIO DEL FIX PARA ISAR / NAMESPACE ---
    afterEvaluate {
        // Verifica si el subproyecto tiene la extensión de Android (es una librería o app)
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension

            // Si la librería no tiene namespace definido (error de Isar 3.1.0), le asignamos uno dinámico
            if (android.namespace == null) {
                val name = project.name.replace("-", "_").replace(":", ".")
                android.namespace = "fix.isar_namespace.$name"
            }
        }
    }
    // --- FIN DEL FIX ---
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}