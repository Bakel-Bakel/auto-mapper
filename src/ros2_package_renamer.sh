#!/bin/bash

# Usage: ./rename_ros2_package.sh old_package_name new_package_name
# Example: ./rename_ros2_package.sh AM_Testcpp am_testcpp

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 old_package_name new_package_name"
    exit 1
fi

OLD_NAME=$1
NEW_NAME=$2
WORKSPACE_DIR=$(pwd)  # Change this if needed

echo "Renaming package from $OLD_NAME to $NEW_NAME..."

# Step 1: Rename the package folder
if [ -d "$WORKSPACE_DIR/$OLD_NAME" ]; then
    mv "$WORKSPACE_DIR/$OLD_NAME" "$WORKSPACE_DIR/$NEW_NAME"
    echo "Renamed folder: $OLD_NAME → $NEW_NAME"
else
    echo "Error: Package folder $OLD_NAME does not exist!"
    exit 1
fi

# Step 2: Identify package type (C++ or Python)
if [ -f "$WORKSPACE_DIR/$NEW_NAME/CMakeLists.txt" ]; then
    PACKAGE_TYPE="cpp"
    echo "Detected C++ (CMake) package"
elif [ -f "$WORKSPACE_DIR/$NEW_NAME/setup.py" ]; then
    PACKAGE_TYPE="python"
    echo "Detected Python package"
else
    echo "Error: Cannot determine package type (no CMakeLists.txt or setup.py found)"
    exit 1
fi

# Step 3: Update package.xml (for both C++ & Python)
sed -i "s/<name>$OLD_NAME<\/name>/<name>$NEW_NAME<\/name>/g" "$WORKSPACE_DIR/$NEW_NAME/package.xml"

# Step 4: Update package-specific files
if [ "$PACKAGE_TYPE" == "cpp" ]; then
    # Update CMakeLists.txt
    sed -i "s/project($OLD_NAME)/project($NEW_NAME)/g" "$WORKSPACE_DIR/$NEW_NAME/CMakeLists.txt"
elif [ "$PACKAGE_TYPE" == "python" ]; then
    # Update setup.py
    sed -i "s/name='$OLD_NAME'/name='$NEW_NAME'/g" "$WORKSPACE_DIR/$NEW_NAME/setup.py"
fi

# Step 5: Update all references in the workspace
echo "Updating references in other packages..."
grep -rl "$OLD_NAME" "$WORKSPACE_DIR/src" | xargs sed -i "s/$OLD_NAME/$NEW_NAME/g"

# Step 6: Rebuild workspace
echo "Rebuilding workspace..."
cd "$WORKSPACE_DIR"
colcon build --symlink-install

echo "Renaming complete! Don't forget to source your workspace:"
echo "source install/setup.bash"

