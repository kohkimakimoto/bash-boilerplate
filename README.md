# bash-boilerplate

Bash script boilerplate.

## Features

* Support sub-command.
* Support command line options.
* Coloring output.
* A progress bar and loading animation.
* Printing a horizontal line
* Confirm and ask functions to get user input from a console.
* Outputting text with indent.
* Outputting text with prefix string.

Many functionalities implemented in the script were inspired by the code at the Internet.
Please see the comments in the script code.

There are some examples inside it. Please run `script.sh`. You can get like the following message.

```
$ ./script.sh
Usage: script.sh [OPTIONS] COMMAND

Options:
  -h, --help         show help.
  -v, --version      print the version.
  -d, --dir <DIR>    change working directory.

Commands:
  help        show help.
  hr          (example) print a horizontal line.
  color       (example) coloring output.
  confirm     (example) confirm.
  ask         (example) ask.
  progress    (example) progress.
  loading     (example) loading.
  indent      (example) indent.
  prefix      (example) prefix.

```

You can run it the following command.

```
$ curl -sL https://raw.githubusercontent.com/kohkimakimoto/bash-boilerplate/master/script.sh | bash -s -- --help
```
