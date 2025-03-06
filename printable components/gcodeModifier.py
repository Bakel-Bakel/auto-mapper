import sys
import os

def remove_text_between_markers(file_path, start_marker, end_marker):
    with open(file_path, "r", encoding="utf-8") as file:
        lines = file.readlines()
    
    inside_section = False
    filtered_lines = []

    for line in lines:
        if start_marker in line:
            inside_section = True
            continue  # Skip adding the start marker line

        if end_marker in line:
            inside_section = False
            continue  # Skip adding the end marker line

        if not inside_section:
            filtered_lines.append(line)

    # Create a new file with "_modified" appended before the file extension
    base_name, ext = os.path.splitext(file_path)
    new_file_path = f"{base_name}_modified{ext}"

    with open(new_file_path, "w", encoding="utf-8") as file:
        file.writelines(filtered_lines)

    print(f"Processed file saved as: {new_file_path}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script.py <file_path> <start_marker> <end_marker>")
        sys.exit(1)

    file_path = sys.argv[1]
    start_marker = sys.argv[2]
    end_marker = sys.argv[3]

    remove_text_between_markers(file_path, start_marker, end_marker)

