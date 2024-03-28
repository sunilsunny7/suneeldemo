import sys
import xml.etree.ElementTree as ET

file1 = sys.argv[1]
file2 = sys.argv[2]
merge_xml(file1, file2)

def merge_xml(file1, file2):
    # Parse XML files
    tree1 = ET.parse(file1)
    tree2 = ET.parse(file2)
    
    # Get root elements
    root1 = tree1.getroot()
    root2 = tree2.getroot(
    
    # Append elements from file2 to file1
    root1.extend(root2)
    
    # Write the merged tree to file
    tree1.write(sys.stdout, encoding='unicode')

