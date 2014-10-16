   # check for Gazebo4 gz
    IS_GZSDF_GAZEBO4=true;
    type gz >/dev/null 2>&1 || { IS_GZSDF_GAZEBO4=false; }

    cd ../urdf

    echo "Creating bare urdf of bigman.urdf.xacro"
    rosrun xacro xacro.py bigman.urdf.xacro > bigman.urdf
    echo "...urdf correctly created!"

    echo "Creating urdf of bigman_robot.urdf.xacro"
    rosrun xacro xacro.py bigman_robot.urdf.xacro > bigman_robot.urdf
    echo "...urdf correctly created!"

    echo "Creating sdf of bigman_robot.urdf..."
    if [ $IS_GZSDF_GAZEBO4 == true ]; then
    	gz sdf --print bigman_robot.urdf > bigman.sdf
    else
	gzsdf print bigman_robot.urdf > bigman.sdf
    fi

    python ../script/gazebowtf.py wtf/bigman.gazebo.wtf bigman_config.urdf.xacro > bigman2.sdf

    mv bigman2.sdf bigman.sdf

    echo "...sdf correctly created!"

    echo "Removing bigman_robot.urdf."
    rm bigman_robot.urdf


    echo "Moving bigman.sdf in bigman_gazebo/sdf."
    mv bigman.sdf ../../bigman_gazebo/sdf/

    echo "Copying meshes in bigman_gazebo/sdf."
    cp -r ../meshes/ ../../bigman_gazebo/sdf/

    cd ../../bigman_gazebo

    echo "Copying all data in bigman_gazebo/sdf in ~/.gazebo/models/bigman_urdf"

    rm -rf ~/.gazebo/models/bigman_urdf
    rm -rf ~/.gazebo/models/bigman
    mkdir -p ~/.gazebo/models/bigman_urdf
    cp -r sdf ~/.gazebo/models/bigman
    cp -r sdf/meshes ~/.gazebo/models/bigman/meshes
    cp -r sdf/meshes ~/.gazebo/models/bigman_urdf/meshes
    cp -r sdf/conf ~/.gazebo/models/bigman_urdf/conf

    echo "Creating srdf from bigman.srdf.xacro"
    cd ../bigman_srdf/srdf
    rosrun xacro xacro.py bigman.srdf.xacro > bigman.srdf 
    echo "...created bigman.srdf!"
     
    echo "Finish! Enjoy bigman in GAZEBO!"
