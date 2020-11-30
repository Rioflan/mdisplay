## What is this script for ?

You can use this script to interactively see the preview of the file you are editing.

Supported input files:
- MarkDown
- LaTeX

## Prerequisites

- python3
- pandoc
- inotify-tools

## How to install it ?

You just have to run the install script:
```
# ./install.sh
```

## How to use it ?

```
$ mdisplay <file>
```

## Environment variables

| Name | Description | Default |
|:----:|:-----------:|:-------:|
| MD\_PATH | Directory where the server will run | /tmp/mdisplay/ |
| MD\_PORT | Port where the server listen | 8000 |
