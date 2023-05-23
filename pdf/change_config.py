import os
import argparse


parser = argparse.ArgumentParser(description='Change links in configuration file')
parser.add_argument('base_file', type=str, help='path to base file (project_dir/pdf)')
parser.add_argument('new_file', type=str, help='path to new file')

args = parser.parse_args()

user_name = os.environ["USER"]
home_dir = "home"
tmp_dir = "tmp"


def change_config_file():
    old_xml_file = open(args.base_file, "r", encoding="utf-8")
    xml_file = ""

    for line in old_xml_file:
        split_str = line.split('=')

        if split_str[0].endswith("embed-url"):
            start_loc = split_str[1][:9]
            end_loc = split_str[1][9:]
            split_str[1] = "{}{}/{}/{}/{}".format(start_loc, home_dir, user_name, tmp_dir, end_loc)

            xml_file += '='.join(split_str)
        else:
            xml_file += line

    old_xml_file.close()

    return xml_file


def create_new_config_file(file):
    new_xml_file = open(args.new_file, "w", encoding="utf-8")

    new_xml_file.writelines(file)

    new_xml_file.close()


create_new_config_file(change_config_file())

