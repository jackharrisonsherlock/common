[RVM PROMPT DEMO](https://asciinema.org/a/pVPJ8bmbZucxecNswfKgAhYsm)

<p align="center">
  <img src="images/common.png" height="64">
<p align="center">A simple, clean and minimal prompt.</p>

<p align="center"><img src="images/screenshot.png" width="864"></p>

- Current working directory
- Hostname (Shown on remote SSH shell only)
- AWS Vault Role
- Background jobs
- Current SHA (optional)
- Exit code of last command
- Git branch/status
- Customisable colour scheme

## Installation

### [Oh My Zsh](http://ohmyz.sh)

```sh
wget -O $ZSH_CUSTOM/themes/common.zsh-theme https://raw.githubusercontent.com/jackharrisonsherlock/common/master/common.zsh-theme
```

Update your `.zshrc` file with:
```sh
ZSH_THEME="common"
```

### [Antigen](https://github.com/zsh-users/antigen)

Update your `.zshrc` file with:

```sh
antigen theme jackharrisonsherlock/common
```

### [Antibody](https://github.com/getantibody/antibody)

Update your `.zshrc` file with:

```sh
antibody bundle jackharrisonsherlock/common
```

## Terminal

In the screenshot you see Common running in [Hyper](https://hyper.is/) with the [GitHub Dark Theme](https://github.com/ohheyjosh/hyper-github-dark) and [SF Mono](https://developer.apple.com/fonts/) font.
