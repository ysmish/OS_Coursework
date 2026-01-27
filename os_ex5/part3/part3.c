#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>
#include "copytree.h"

void print_usage(const char *prog_name) {
    fprintf(stderr, "Usage: %s [-l] [-p] <source_directory> <destination_directory>\n", prog_name);
    fprintf(stderr, "  -l: Copy symbolic links as links\n");
    fprintf(stderr, "  -p: Copy file permissions\n");
}

// Main function
int main(int argc, char *argv[]) {
    int opt;
    int copy_symlinks = 0;
    int copy_permissions = 0;

    // Parse flags with getopt
    while ((opt = getopt(argc, argv, "lp")) != -1) {
        switch (opt) {
            case 'l':
                copy_symlinks = 1;  // Enable copying symlinks as symlinks
                break;
            case 'p':
                copy_permissions = 1;  // Enable copying permissions
                break;
            default:
                print_usage(argv[0]);
                return -1;
        }
    }

    // Ensure we have the correct number of arguments
    if (argc - optind != 2) {
        print_usage(argv[0]);
        return -1;
    }

    // Source and destination directories
    char *source_directory = argv[optind];
    char *destination_directory = argv[optind + 1];

    // Call the helper to create the destination directory structure
    directoryHelper(destination_directory);

    // Copy files and directories from source to destination
    copy_directory(source_directory, destination_directory, copy_symlinks, copy_permissions);

    return 0;
}
