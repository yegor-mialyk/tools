# Seamless Sudo

Seamless Sudo runs a user command as an administrator **without opening a separate console window**, so you will never lose its output.

There is no need to open a new terminal instance as an administrator anymore.

Here are a few examples:

```text
C:\>iisreset

Access denied, you must be an administrator of the remote computer to use this
command. Either have your account added to the administrator local group of
the remote computer or to the domain administrator global group.

C:\>su -q iisreset

Attempting stop...
Internet services successfully stopped
Attempting start...
Internet services successfully restarted
```

```text
C:\>fsutil file layout test.vhdx
Error:  Access is denied.

C:\>su fsutil file layout test.vhdx
Executing: fsutil file layout test.vhdx

********* File 0x0041000000012d93 *********
File reference number   : 0x0041000000012d93
[skipped]
```

User Account Control (UAC) may prompt the user for consent to run the command elevated or to enter the credentials of an administrator account used to run the command.

## Installation

- Download the latest [Sudo release](https://github.com/yegor-mialyk/tools/releases/latest) for your platform.
- Unpack the package into a folder accessible by the `PATH` environment variable.
- Enjoy.

## FAQ

### Q: I'm running a GUI application via `su`, but my terminal is blocked

Please use the `--no-wait` option (or just `-n`) to not wait for your application to finish.

### Q: Why the main module called `su.exe` and not `sudo.exe`?

`su` is shorter, but you are free to rename it or use an alias.

### Q: I'm trying to execute `su dir` but it fails

`dir` is an internal command of your shell and not a standalone utility. So you have to run it through the shell, e.g. `su cmd /c dir`. Seamless Sudo does not use any shell by default because users may have different preferences.

## Feedback

To file an issue or request a new feature, please visit [GitHub Issues](https://github.com/yegor-mialyk/tools/issues).

## License

Copyright (C) 1995-2023 Yegor Mialyk. All Rights Reserved.

Licensed under the [MIT](LICENSE) License.
