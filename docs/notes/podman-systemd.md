# Creating a systemd Service for a Podman Pod

To create a `systemd` service file for managing a Podman pod:

* **Generate the systemd unit file**:

    Use `podman generate systemd` with the `--new` flag to avoid generating a service for a currently running container. This ensures a create a new container out of the image:
    ```bash
    podman generate systemd --new --files --name <podName>
    ```
    !!! warning
        If you use the same name for both the pod and a container, only the container’s service will be generated. Make sure the pod and container names are unique if you want a pod-level service.

    !!! note
        by default `restart-policy` is `on-failure` which means the pod will be restarted if a container fails to start. You can change the value to `always` to make the pod always restart.
        ```bash
        podman generate systemd --new --files --name <podName> --restart-policy always
        ```

* **Move the generated service files to the user systemd directory**

    Move the `.service` file(s) to the appropriate location in your user’s systemd configuration directory:

    ```bash
    mv generate_files ~/.config/systemd/user/
    ```

* **Reload the systemd user daemon**:

    Inform systemd about the new unit file:

    ```bash
    systemctl --user daemon-reload
    ```

* **Enable and start the service**:

    Use `--now` to both enable the service at boot and start it immediately:
    ```bash
    systemctl --user enable --now pod-<podName>.service
    ```
