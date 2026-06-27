# Blog

## [Hugo](https://gohugo.io/)
- Use Hugo for blog framework
- Theme: [Blowfish](https://github.com/nunocoracao/blowfish) (requires Hugo **extended**, v0.158+)
```
# install hugo (extended version required by the Blowfish theme)
sudo snap install hugo

# init / update the Blowfish theme submodule (required after cloning)
git submodule update --init --recursive

# new markdown file
hugo new content dir/filename.md

# local server
hugo server
```

### WSL2
The snap package fails to start under WSL2 (snap confinement isn't supported).
Install the official extended `.deb` instead:
```
# pick a version >= 0.158 (matching the CI HUGO_VERSION is recommended)
HUGO_VERSION=0.163.1
curl -LO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.deb
sudo dpkg -i hugo_extended_${HUGO_VERSION}_linux-amd64.deb
```
To view the dev server from a Windows browser, run:
```
./dev.sh
# then open http://localhost:8080
```
This binds to all interfaces (`--bind 0.0.0.0`) and overrides the production
`baseURL` (which carries a `/blog/` path) so the site serves at the root.

> **Why port 8080, not Hugo's default 1313?** Windows `winnat` reserves a port
> range (often `1214-1313`) for dynamic/Hyper-V allocation, which breaks WSL2
> localhost forwarding for any port inside it — so `http://localhost:1313` is
> unreachable from Windows even though the server runs fine. 8080 sits outside
> that range. The range can change after a reboot; if 8080 ever stops working,
> list the current reservations from a Windows shell and pick a port outside them:
> ```
> netsh interface ipv4 show excludedportrange protocol=tcp
> ```
> Override the port with `PORT=3000 ./dev.sh`. A permanent alternative is
> `networkingMode=mirrored` in `%USERPROFILE%\.wslconfig` (Win11 22H2+, then
> `wsl --shutdown`), which makes `localhost` map directly with no forwarding.
> Keep the project on the Linux filesystem (e.g. `~/blog`), not under `/mnt/c/...`,
> otherwise builds are slow and live-reload (inotify) breaks.