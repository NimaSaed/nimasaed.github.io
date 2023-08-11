# Enabling Touch ID for `sudo` on macOS

Did you know that you can utilize your Mac's Touch ID feature to execute `sudo` commands without the need to enter your password? This convenient trick can save you time and streamline your workflow. Let's delve into the process of setting it up.

To enable Touch ID for `sudo`, follow these steps:

1. Open the Terminal application on your Mac.

2. Type the following command to open the `sudo` PAM configuration file using the `vim` text editor:
```bash
sudo vim /etc/pam.d/sudo
```
3. Add the following line at the top of the file:
```bash
auth sufficient pam_tid.so
```
This line enables Touch ID authentication for `sudo` commands.
4. If you use TMUX, you'll need to attach the PAM (Pluggable Authentication Module) to TMUX to ensure that the Touch ID integration works within TMUX sessions. To do this, follow these additional steps:
    - Install `pam-reattach` using Homebrew by running the following command:
     ```shell
     brew install pam-reattach
     ```
    - Open the `sudo` PAM configuration file again:
     ```shell
     sudo vim /etc/pam.d/sudo
     ```
    - Add the following line below the previous line:
     ```shell
     auth optional /opt/homebrew/lib/pam/pam_reattach.so
     ```
These lines enable Touch ID support within TMUX sessions as well.
5. Save the changes to the file.
6. You might need to reboot your Mac or restart any open Terminal or TMUX sessions for the changes to take effect.

Here's a convenient script that automates these steps for you:

```bash
#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error

# This script is going to add touch id to sudo command, including inside TMUX

echo "NOTICE: you need to install pam-reattach to use it in TMUX"

sudo_path="/etc/pam.d/sudo"
chmod 644 $sudo_path
sed -i -e '2s/^/auth\t   sufficient\t  pam_tid.so\n/' $sudo_path
sed -i -e '3s/^/auth\t   optional\t  \/opt\/homebrew\/lib\/pam\/pam_reattach.so\n/' $sudo_path
chmod 444 $sudo_path
```

Just execute this script in your Terminal, and it will handle the necessary configurations for you.

With Touch ID-enabled `sudo`, you can now perform administrative tasks more conveniently and securely. This feature not only eliminates the need to type your password but also enhances the overall accessibility of your Mac. Give it a try and experience the seamless power of Touch ID in your command-line activities!"

