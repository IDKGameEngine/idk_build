# idk_build

Run dependency installation and builds inside Steam Runtime (`./env.sh` from
the workspace root). Initialize submodules after cloning or pulling this repo:

```bash
git -C idk_build submodule update --init --recursive
./dep-build.sh
./build.sh
```

`dep-build.sh` builds all dependencies by default. Supply dependency names to
rebuild only those packages, for example:

```bash
./dep-build.sh vulkan-sdk
```

Available names are `assimp`, `glm`, `jolt`, `steamworks-sdk`, and `vulkan-sdk`.
The Vulkan SDK package also installs the Slang shader compiler (`slangc`) and its
libraries into `idk_build/local`. CMake discovers it through the preset's
`CMAKE_PREFIX_PATH`; adding it to `PATH` is unnecessary.

Older SDK install rules removed executable permission from copied tools. If
configuration reports that `IDK_SLANGC` cannot be found even though
`idk_build/local/bin/slangc` exists, this repairs an existing installation:

```bash
chmod u+x idk_build/local/bin/slangc
./build.sh
```

After updating this repo and its submodules, `./dep-build.sh vulkan-sdk`
reinstalls SDK tools while preserving their source permissions. Errors while
preparing the SDK stop dependency configuration instead of installing partial
results. A Slang installation outside the preset prefix can be selected with
`./build.sh --cmakeopts -DIDK_SLANGC=/absolute/path/to/slangc`.
