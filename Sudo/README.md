# Seamless Sudo

Seamless Sudo runs a user command as an administrator or SYSTEM account **without opening a separate console window**, ensuring that you will never lose its output.

There is no need to open a new terminal instance as an administrator anymore.

Here are a few examples:

1. Querying the file system:

    ```text
    C:\>fsutil 8dot3name query C:
    Error:  Access is denied.

    C:\>_
    ```

    ```text
    C:\>su fsutil 8dot3name query C:
    Executing (as Administrator): fsutil 8dot3name query C:

    The volume state is: 0 (8dot3 name creation is ENABLED)
    The registry state is: 1 (8dot3 name creation is DISABLED on all volumes)

    Based on the above settings, 8dot3 name creation is DISABLED on "C:"

    C:\>_
    ```

2. Resetting Internet Information Services (IIS):

    ```text
    C:\>iisreset

    Access denied, you must be an administrator of the remote computer to use this
    command. Either have your account added to the administrator local group of
    the remote computer or to the domain administrator global group.

    C:\>_
    ```

    ```text
    C:\>su -q iisreset

    Attempting stop...
    Internet services successfully stopped
    Attempting start...
    Internet services successfully restarted

    C:\>_
    ```

3. Running a GUI application with the `--no-wait` option:

    ```text
    C:\>su --no-wait notepad
    Executing (as Administrator): notepad

    C:\>_
    ```

4. Running a PowerShell command:

    ```text
    C:\>su -q --ps (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    True

    C:\>_
    ```

5. Running a command using Command Prompt:

    ```text
    C:\>su -q --cmd IF NOT DEFINED SESSIONNAME echo Administrator?
    Administrator?

    C:\>_
    ```

6. Running a command as the SYSTEM account:

    ```text
    C:\>su -q -s whoami
    nt authority\system

    C:\>_
    ```

User Account Control (UAC) may prompt the user for consent to run the command elevated or to enter the credentials of an administrator account used to run the command.

## Installation

- Download the latest [Seamless Sudo release](https://github.com/yegor-mialyk/tools/releases/latest) for your platform.
- Unpack the package into a folder accessible by the `PATH` environment variable.
- Enjoy.

## FAQ

### Q: I'm running a GUI application via `su`, but my terminal is blocked

Please use the `--no-wait` option (or just `-n`) to not wait for your application to finish.

### Q: Why the main module called `su.exe` and not `sudo.exe`?

`su` is shorter, but you are free to rename it or use an alias.

### Q: I'm trying to execute `su dir` but it fails

`dir` is an internal command of your shell and not a standalone utility.
So you have to run it through the shell (e.g. `su cmd /c dir`) or use `su --cmd dir` for Command Prompt or `su --ps dir` for PowerShell.
Seamless Sudo does not use any shell by default because users may have different preferences.

## Feedback

To file an issue or request a new feature, please visit [GitHub Issues](https://github.com/yegor-mialyk/tools/issues).

## License

Copyright (C) 1995-2023 Yegor Mialyk. All Rights Reserved.

Licensed under the [MIT](LICENSE) License.
