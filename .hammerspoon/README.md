This is a wrapper for Hammerflow users that are brand new to Hammerspoon. It lets them get set up with a single `git clone`. If you already use Hammerspoon, you can install Hammerflow as a typical Spoon. See [hammerflow.dev](https://hammerflow.dev) for details.

# Note
This repository includes Hammerspoon.spoon as a submodule. To clone it, make sure you include the `recursive` flag:
```bash
git clone --recursive https://github.com/saml-dev/hammerflow-wrapper.git ~/.hammerspoon
```

To pull down updates, use:
```
git pull && git submodule update --init --recursive
```
