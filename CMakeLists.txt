cmake_minimum_required(VERSION 3.16)

project(m-translate-qt VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 LabsPlatform)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appm-translate-qt
    src/main.cpp
)

qt_add_qml_module(appm-translate-qt
    URI m.translate.qt
    VERSION 1.0
    QML_FILES
        src/qml/Main.qml
        src/qml/HomePage.qml
        src/qml/SettingsPage.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appm-translate-qt PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appm-translate-qt
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appm-translate-qt
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::LabsPlatform
)

include(GNUInstallDirs)
install(TARGETS appm-translate-qt
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
