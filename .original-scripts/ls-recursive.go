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
var fileCounter = 0
var options = []optionStructure{}

const (
	enableWalkThrough = iota
	enableConfirm
	off
)

var mode = enableConfirm

type optionStructure struct {
	name string
	value string
}

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

	beforeFlag := ""
	for _, value := range os.Args[1:] {
		switch value {
		case "-d", "--directory": // target directory
			beforeFlag = "d"
			continue
		}

		if beforeFlag == "" {
			fmt.Println("Unexpected argument.")
			return
		}

		options = append(
			options,
			optionStructure {
				name: beforeFlag,
				value: value,
			},
		)

		// reset before flag
		beforeFlag = ""
	}

	result := walk(findOption("d").value)

	for _, value := range result {
		fmt.Println(value)
	}
}

func findOption(name string) *optionStructure {
	for _, option := range options {
		if option.name == name {
			return &option
		}
	}
	return nil
}

func walk(target string) []string {
	files, _ := ioutil.ReadDir(target)
	fileCounter += len(files)
	if fileCounter > limit {
		var ask string
		if mode == enableConfirm {
			fmt.Printf(
				"Listed files are too long. Do you want to read all files? [Yn]: ",
			)

			i, _ := fmt.Scan(&ask)
			_ = i
		}

		var answer bool = strings.TrimSpace(strings.ToLower(ask)) == "n"
		if mode == off || answer {
			if answer {
				fmt.Printf("Stopped to list. Show %d files.\n", fileCounter)
				mode = off
			}
			return []string{}
		}

		// Change mode.
		mode = enableWalkThrough
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
			)...
		)
	}

	return items
}