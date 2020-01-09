package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"strconv"
	"strings"
)

const limit = 100
var readGitIgnore = true
var excludes = []string{
	".git",
	".idea",
}
var includes = []string{}

const (
	enableWalkThrough = iota
	enableConfirm
	off
)

func main() {
	if readGitIgnore {
		data, err := ioutil.ReadFile(".gitignore")
		if err == nil {
			splitExcludeFiles := strings.Split(
				strings.Trim(
					string(data),
					"\n\r",
				),
				"\n",
			)

			for _, file := range splitExcludeFiles {
				if file[:1] == "!" {
					includes = append(
						includes,
						file[1:],
					)
					continue
				}
				excludes = append(
					excludes,
					file,
				)
			}

			excludes = append(
				excludes,
				splitExcludeFiles...
			)
		}
	}

	result := walk(
		".",
		enableWalkThrough,
	)
	for _, value := range result {
		fmt.Println(value)
	}
}

func walk(target string, mode int) []string {
	files, _ := ioutil.ReadDir(target)
	if len(files) > limit {
		var ask string
		if mode == enableConfirm {
			fmt.Printf(
				"Listed files are too long under the `%s/`. Displays %d files? [Yn]: ",
				strings.TrimRight(target, "/ "),
				len(files),
			)

			i, _ := fmt.Scan(&ask)
			_ = i
		}

		if mode == off ||
			strings.TrimSpace(strings.ToLower(ask)) == "n" {
			return []string{}
		}
	}

	items := []string{}
	directories := []os.FileInfo{}
	for _, file := range files {
		found := false
		for _, excludeFileName := range excludes {
			if excludeFileName == file.Name() {
				found = true
				break
			}
		}
		if found {
			continue
		}
		fileType := "F"
		if file.IsDir() {
			fileType = "D"
			directories = append(
				directories,
				file,
			)
		}
		items = append(
			items,
			fileType + "\t" +
			file.Mode().Perm().String() + "\t"  +
			strconv.Itoa(int(file.Size())) + "\t" +
			strings.Replace(target + "/", "./", "", 1) + file.Name(),
		)
	}

	for _, directory := range directories {
		items = append(
			items,
			walk(
				target + "/" + directory.Name(),
				mode,
			)...
		)
	}

	return items
}