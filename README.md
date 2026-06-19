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
To view the dev server from a Windows browser, bind to all interfaces:
```
hugo server -D --bind 0.0.0.0 --baseURL http://localhost
# then open http://localhost:1313
```
> Keep the project on the Linux filesystem (e.g. `~/blog`), not under `/mnt/c/...`,
> otherwise builds are slow and live-reload (inotify) breaks.