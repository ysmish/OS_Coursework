#include "copytree.h"
#include <stdio.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <dirent.h>

const char *getFileName(const char *src)
{
    // Find the last occurrence of '/'
    const char *fileName = strrchr(src, '/');
    if (fileName)
    {
        // Move the pointer forward to skip the '/'
        fileName++;
    }
    else
    {
        // If no '/' was found, the entire path is the file name
        fileName = src;
    }
    return fileName; // Now correctly returning const char *
}

void physicalCopy(const char *src, char newPath[])
{
    // getting the stat of the original file
    struct stat fileStat;
    if (stat(src, &fileStat) == -1)
    {
        perror("stat failed");
        exit(1);
    }
    int oldFile = open(src, O_RDONLY);
    int newFile = open(newPath, O_CREAT | O_TRUNC | O_RDWR, 0644);
    char buffer[fileStat.st_size];
    size_t bytesRead = read(oldFile, buffer, sizeof(buffer));

    if (bytesRead == -1)
    {
        perror("read failed");
        close(oldFile);
        close(newFile);
        exit(1);
    }
    size_t bytesWritten = write(newFile, buffer, sizeof(buffer));
    if (bytesWritten == -1)
    {
        perror("write failed");
        close(oldFile);
        close(newFile);
        exit(1);
    }
    close(oldFile);
    close(newFile);
}

void softCopy(const char *src, char newPath[])
{
    char buffer[4096]; // Buffer to store the target path
    ssize_t len;

    // Use readlink to get the target path of the symbolic link
    len = readlink(src, buffer, sizeof(buffer) - 1);
    if (len == -1)
    {
        perror("readlink failed");
        exit(1);
    }

    // Null-terminate the buffer as readlink does not add a null byte
    buffer[len] = '\0';

    // getting the data from src file - which file it points to
    if (symlink(buffer, newPath) == -1)
    {
        perror("symlink failed");
        exit(1);
    }
}

void copyPremissions(const char *src, char newPath[])
{
    struct stat fileStat;
    if (stat(src, &fileStat) == -1)
    {
        perror("stat failed");
        exit(1);
    }
    struct stat newFileStat;
    if (lstat(newPath, &newFileStat) == -1)
    {
        perror("lstat failed");
        exit(1);
    }
    if (!S_ISLNK(newFileStat.st_mode))
    {
        if (chmod(newPath, fileStat.st_mode & 0777) == -1)
        {
            perror("chmod failed");
            exit(1);
        }
    }
}

void copy_file(const char *src, const char *dest, int copy_symlinks, int copy_permissions)
{
    const char *fileName = getFileName(src);
    char newPath[4096];
    snprintf(newPath, sizeof(newPath), "%s/%s", dest, fileName);

    // copy_symlinks is 1
    if (copy_symlinks)
    {
        // getting the stat of the original file
        struct stat fileStat;
        if (lstat(src, &fileStat) == -1)
        {
            perror("lstat failed");
            exit(1);
        }
        // trying to copy a soft link - should copy its content, not the content of the file it points to
        if (S_ISLNK(fileStat.st_mode))
        {
            softCopy(src, newPath);
        }
        // if copy_symlink is 1 but the file isn't a soft link - should copy the file as it is
        else
        {
            physicalCopy(src, newPath);
        }
    }
    else
    {
        physicalCopy(src, newPath);
    }

    // opening the new file and changing its permissions if needed
    if (copy_permissions)
    {
        copyPremissions(src, newPath);
    }
}

void directoryHelper(const char *path)
{
    char temp[4096];
    snprintf(temp, sizeof(temp), "%s", path);

    // If the path is the root directory, return
    if (strcmp(temp, "/") == 0)
    {
        return;
    }

    // Remove trailing slash if present
    size_t len = strlen(temp);
    if (temp[len - 1] == '/')
    {
        temp[len - 1] = '\0';
    }

    len = strlen(temp);

    for (size_t i = 1; i <= len; i++)
    {
        if (temp[i] == '/' || temp[i] == '\0') // Found a directory boundary
        {
            char backup = temp[i];
            temp[i] = '\0'; // Temporarily terminate the string

            if (mkdir(temp, S_IRWXU) != 0 && errno != EEXIST)
            {
                perror("mkdir failed");
                exit(1);
            }

            temp[i] = backup; // Restore the original character
        }
    }
}

void copy_directory(const char *src, const char *dest, int copy_symlinks, int copy_permissions)
{

    struct dirent *entry;
    DIR *dir = opendir(src);
    if (dir == NULL)
    {
        perror("opendir failed");
        exit(1);
    }

    while ((entry = readdir(dir)) != NULL)
    {
        // Skip "." and ".." and "DS_Store" cause my mac adds invisible files named as such
        if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0 || strcmp(entry->d_name, ".DS_Store") == 0)
        {
            continue;
        }

        struct stat currEntry;
        char currEntryPath[4096];
        snprintf(currEntryPath, sizeof(currEntryPath), "%s/%s", src, entry->d_name);

        // Get file status
        if (stat(currEntryPath, &currEntry) == -1)
        {
            perror("stat failed");
            exit(1);
        }

        // Handle regular files or symbolic links
        if (S_ISREG(currEntry.st_mode) || S_ISLNK(currEntry.st_mode))
        {
            copy_file(currEntryPath, dest, copy_symlinks, copy_permissions);
        }
        // Handle directories
        else if (S_ISDIR(currEntry.st_mode))
        {
            char newPath[4096];
            snprintf(newPath, sizeof(newPath), "%s/%s", dest, entry->d_name);
            if (mkdir(newPath, currEntry.st_mode) == -1)
            {
                perror("mkdir failed");
                exit(1);
            }
            // Recursively copy the directory
            copy_directory(currEntryPath, newPath, copy_symlinks, copy_permissions);
        }
    }

    closedir(dir);
}