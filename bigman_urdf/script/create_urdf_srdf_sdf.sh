#!/bin/bash

# this way the script can be called from any directory
SCRIPT_ROOT=$(dirname $(readlink --canonicalize --no-newline $BASH_SOURCE))
cd $SCRIPT_ROOT
cd ../urdf

# check for Gazebo4 gz
IS_GZSDF_GAZEBO4=true;
type gz >/dev/null 2>&1 || { IS_GZSDF_GAZEBO4=false; }

if [ -d config ]; then

    echo "Regenerating database.config for bigman_gazebo"

cat > ../../bigman_gazebo/database/database.config << EOF
<?xml version='1.0'?>
<database>
<name>bigman Gazebo Database</name>
<license>Creative Commons Attribution 3.0 Unported</license>
<models>
EOF

    for i in config/*.urdf.xacro; do
        cd $SCRIPT_ROOT
        cd ../urdf
        if [ -r $i ]; then

            echo "Processing file $i"
            model_name="`python ../script/get_model_params.py ${i} model_name`"
            model_version="`python ../script/get_model_params.py ${i} model_version`"
            model_filename=$(basename $i ".urdf.xacro")
            echo "${model_filename} configures model ${model_name}, version ${model_version}"

            cp $i bigman_config.urdf.xacro
            mkdir -p ../../bigman_gazebo/database/$model_filename
            echo "<uri>file://${model_filename}</uri>" >> ../../bigman_gazebo/database/database.config

rm -f ../../bigman_gazebo/database/$model_filename/model.config                    
cat >> ../../bigman_gazebo/database/$model_filename/model.config << EOF
<?xml version="1.0"?>
<model>
  <name>$model_name</name>
  <version>$model_version</version>
  <sdf version='1.4'>bigman.sdf</sdf>

  <author>
   <name>Enrico Mingo</name>
   <email>enrico.mingo@iit.it</email>
  </author>

  <description>
    Simulation of the bigman Humanoid Robot from IIT.
  </description>
</model>
EOF
                    
            cp ../../bigman_gazebo/database/$model_filename/model.config ../../bigman_gazebo/database/$model_filename/manifest.xml
            cp ../../bigman_gazebo/database/$model_filename/model.config ../../bigman_gazebo/database/$model_filename/${model_filename}.config


            echo "Creating bare urdf of bigman.urdf.xacro ..."
            rosrun xacro xacro.py bigman.urdf.xacro > ${model_filename}.urdf
            echo "...${model_filename}.urdf correctly created!"

            echo "Creating urdf of bigman_robot.urdf.xacro"
            rosrun xacro xacro.py bigman_robot.urdf.xacro > bigman_robot.urdf
            echo "Creating sdf of bigman_robot.urdf.xacro"
            if [ $IS_GZSDF_GAZEBO4 == true ]; then
            	gz sdf --print bigman_robot.urdf > bigman.sdf
	    else
                gzsdf print bigman_robot.urdf > bigman.sdf
            fi
            
            rm bigman_robot.urdf
            echo "...sdf correctly created!"

            echo "Installing robot model in bigman_gazebo/${model_filename}"
            mv bigman.sdf ../../bigman_gazebo/database/${model_filename}/

            echo "Creating srdf from bigman.srdf.xacro"
            cd ../../bigman_srdf/srdf
            rosrun xacro xacro.py bigman.srdf.xacro > ${model_filename}.srdf 
            echo "...created ${model_filename}.srdf!"
            

            cd $SCRIPT_ROOT

            HAS_MOVEIT_CDC=false;
            type moveit_compute_default_collisions >/dev/null 2>&1 || { HAS_MOVEIT_CDC=false; }

            if [ $HAS_MOVEIT_CDC == true ]; then
                echo
                echo "computing default allowed collision detection matrix for ${model_filename}..."
                moveit_compute_default_collisions --urdf_path ../urdf/${model_filename}.urdf --srdf_path ../../bigman_srdf/srdf/${model_filename}.srdf
            else
                echo "skipping computation of default allowed collision detection matrix"
            fi


            echo 
            echo 
            echo "Complete! Enjoy ${model_name} ver ${model_version} in GAZEBO!"
            echo "If the model requires it, remember to check ../../bigman_gazebo/${model_filename}/conf/"
            echo
            echo
        fi
    done

    cd $SCRIPT_ROOT

    cd ../urdf
    
    echo "</models>" >> ../../bigman_gazebo/database/database.config
    echo "</database>" >> ../../bigman_gazebo/database/database.config
    
    unset i
    
    rm bigman_config.urdf.xacro
    mkdir -p ../../bigman_gazebo/database/bigman_urdf/
    cp -r ../meshes/ ../../bigman_gazebo/database/bigman_urdf/
    cp -r ../../bigman_gazebo/sdf/conf ../../bigman_gazebo/database/bigman_urdf
else
    echo "Error: could not find config folder in the urdf path"
fi

cd $SCRIPT_ROOT
cd ../urdf
cp config/bigman.urdf.xacro bigman_config.urdf.xacro
