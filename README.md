# zig-playdate-template
Barebones template for a Playdate game in [Zig](https://ziglang.org/).

## Disclaimer
- I'm using this project as a way to teach myself Zig. I literally have not read through the [docs](https://ziglang.org/documentation/master/) or through [ziglearn](https://ziglearn.org/) yet so the code here is not necessarily a good example of Zig usage.

## Building
Note: for now I've been using WSL for development so I've also been building a Windows .dll so that I can load it on the Windows simulator on the host. 

### Other
#### Requirements
##### Zig
https://ziglang.org/download/

This project was made using version `0.10.0-dev.3007+6ba2fb3db`. Anything higher is probably okay.

##### Arm GNU Toolchain
https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/downloads

This project was made with version `11.2-2022.02`. This is needed to link the correct libs to the Playdate.

##### Playdate SDK
https://play.date/dev/

This project was made using version `1.12.2`. Anything higher is probably okay.

##### Environment Variables
- Set `PLAYDATE_SDK_PATH` to where you've installed the Playdate SDK.
- Set `ARM_TOOLCHAIN_PATH` to where you've installed the toolchain.

#### Building
Once all the requirements are setup:
```
git clone --recurse-submodules https://github.com/MeTheFlea/zig-playdate-template.git
cd zig-playdate-template
zig build
```

## Running
Once it's built, there should be a folder `zig-out/zig-playdate-template.pdx`. 

The `zig-playdate-template.pdx` should also work on the Playdate hardware.

## Acknowledgements

- [DanB91/README.txt - Playdate Zig starting point](https://gist.github.com/DanB91/4236e82025bb21f2a0d7d72482e391d8) - this gist helped out a lot to figure out what I needed to fiddle with.
- [Zig Discord](https://discord.com/invite/zig) - some people shared some Playdate progress.
