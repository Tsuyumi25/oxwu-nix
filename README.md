# oxwu-nix

Nix flake for [地牛Wake Up!](https://eew.earthquake.tw) — Taiwan earthquake early warning desktop app.

Supports `x86_64-linux`, `aarch64-linux`, `armv7l-linux`. Updated automatically every Monday via GitHub Actions.

## Usage

```nix
# flake.nix
inputs.oxwu-nix = {
  url = "github:Tsuyumi25/oxwu-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};

# configuration.nix or home.nix
environment.systemPackages = [ inputs.oxwu-nix.packages.${pkgs.system}.oxwu ];
```

Then update when needed:

```bash
nix flake update oxwu-nix
```

## Disclaimer

This flake downloads the official binary directly from `eew.earthquake.tw` at build time. No redistribution occurs. The software is subject to the [地牛Wake Up! Terms of Service](https://eew.earthquake.tw). This project is not affiliated with or endorsed by the developer.
