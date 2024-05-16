# Repository Content Dump Script

This script generates a comprehensive dump of a directory's contents, including file contents and a directory tree view. It is designed to be flexible and customizable through command-line options.

## Features
- Dumps file contents and directory tree views.
- Supports exclusion patterns to skip specific files or directories.
- Customizable output file name and directory depth.
- Handles various file types, including attachments.

## Requirements
- `bash` (version 4.0 or higher)
- `tree` command

## Installation
Ensure you have the `tree` command installed. You can install it using homebrew:
```
brew install tree
```

## Usage
```
./dump.sh [-o output_file] [-d depth] [-e exclude_patterns] [directories...]
```
### Options
- `-o output_file`: Specify the output file name. Default is parent_folder_timestamp.dump.txt.
- `-d depth`: Specify the depth of the directory tree to dump. Default is 5.
- `-e exclude_patterns`: Specify additional patterns to exclude, separated by |.

## Examples

### Dump the current directory with default settings:
```
./dump.sh
```
* creates a new file named `parent_folder_timestamp.dump.txt` in the current directory.
* dumps the contents of the current directory
* dumps a tree view of the directory structure, with a tree depth of 5.

### Dump a specific directory with a custom output file:
```
./dump.sh -o my_dump.txt /path/to/directory
```
* creates a new file named `my_dump.txt` in the current directory.
* dumps the contents of the `/path/to/directory`
* dumps a tree view of the directory structure, with a tree depth of 5.

### Dump with a custom depth and exclude additional patterns:
```
./dump.sh -d 3 -e 'test|docs' /path/to/directory
```
* creates a new file named `parent_folder_timestamp.dump.txt` in the current directory.
* dumps the contents of the `/path/to/directory`
* dumps a tree view of the directory structure, with a tree depth of 3
    * exclude any files or directories that match the `test` or `docs` pattern.


## Easier usage

To simplify the usage of the `dump.sh` script, you can create a permanent alias. This allows you to run the script using the `dump` command from any directory.

### For Mac Users
Run the following command in your terminal:
```
echo "alias dump='$(pwd)/dump.sh'" >> ~/.zshrc && source ~/.zshrc
```

### For Linux Users
Run the following command in your terminal:
```
echo "alias dump='$(pwd)/dump.sh'" >> ~/.bashrc && source ~/.bashrc
```

After running the appropriate command, you can use the `dump` command to execute the script:
```
dump [options] [directories...]
```
