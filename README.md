# rf

rf (**r**epository **f**inder) is a simple tool that helps you change directory. This is particular useful for developers
who work on various souftware each day. It can be stressful to deal with all those cds commands, so this little tool scans a directory and build an internal index of all the directories that are a git or svn repository, and then it helps changind directory without having to deal with paths.


### Example

Let's suppose that all of your repositories live under the directory `projects`.
`backend`, `gui-app` and `text-app` are git repositories, while `personal` holds a couple of git repositories.

```
projects
├── backend
├── gui-app
├── personal
│   ├── my_app
│   └── test
└── text-app
```
lunching rf will help you select a repository inside `project`

[![asciicast](https://asciinema.org/a/neIONnAkJ0TKDhfpqyCk0yj3d.svg)](https://asciinema.org/a/neIONnAkJ0TKDhfpqyCk0yj3d)

### Shell integration
The actual binary prints to stdout the aboslute path of the selected directory so the output can be used with cd.
By putting this function in your `.bashrc` or `.zshrc` rf will be correctly setup to change directory in your shell.

```bash
function rf() {
    NEW_DIR=$(/path/to/rf.bin $@)
    if [ -n "$NEW_DIR" ]; then
        cd $NEW_DIR
    fi
}
```
(remember to source the rc file)
Note: the `rf.bin` mentioned in the script is the output of `make build`.

# Development

This tool is higly experimental and still in development, yet I use it every day without (almost) any problems.
You might need to run `reset` to fix your terminal.

This software is inspired by [fzf](https://github.com/junegunn/fzf).


## Contributing (any help appreciated!)
1. Fork it (<https://github.com/giuseongit/rf/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

