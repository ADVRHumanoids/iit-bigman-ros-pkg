cmake_minimum_required(VERSION 2.8)
PROJECT(iit-bigman-ros-pkg)




add_custom_target(  acm
                    COMMAND ${CMAKE_SOURCE_DIR}/bigman_urdf/script/create_acm.sh bigman)

add_custom_target(	remove_old_bigman_urdf_gazebo ALL
    				COMMAND ${CMAKE_COMMAND} -E remove_directory 
        			"~/.gazebo/models/bigman_urdf/")

add_custom_target(  remove_old_bigman_gazebo ALL
                    COMMAND ${CMAKE_COMMAND} -E remove_directory 
                    "~/.gazebo/models/bigman/")

add_custom_target(  compile_urdf_sdf ALL
                    COMMAND ${CMAKE_SOURCE_DIR}/bigman_urdf/script/create_urdf_srdf_sdf.sh bigman)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    add_custom_target(	copy_bigman_gazebo ALL
        				COMMAND ${CMAKE_COMMAND} -E copy_directory 
            			"${PROJECT_SOURCE_DIR}/bigman_gazebo/sdf/" 
            			"~/.gazebo/models/bigman/"
            			DEPENDS remove_old_bigman_gazebo)
endif()

# install urdf and srdf folders in the correct path
install(DIRECTORY bigman_urdf/urdf/ DESTINATION "${CMAKE_INSTALL_PREFIX}/share/robots/bigman/urdf") #FILES_MATCHING PATTERN "*.urdf / .srdf"
install(DIRECTORY bigman_srdf/srdf/ DESTINATION "${CMAKE_INSTALL_PREFIX}/share/robots/bigman/srdf") #FILES_MATCHING PATTERN "*.urdf / .srdf"