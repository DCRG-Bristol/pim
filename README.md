# Package Installer for Matlab (pim)

A simple package manager for Matlab (inspired by [pip](https://github.com/pypa/pip)). Downloads packages from Matlab Central's File Exchange, GitHub repositories, or any other url pointing to a .zip file.

This has been slightly edited to suite the style used in the dcrg repositories.

## Quickstart

Download/clone this repo and add it to your Matlab path. To persevre this after install please add the following two line to you [`startup.m` script](https://uk.mathworks.com/help/matlab/ref/startup.html). Now try the following:

- `pim install [package-name]`: install package by name
- `pim uninstall [package-name]`: remove package, if installed
- `pim freeze`: lists all packages currently installed
- `pim init`: adds all installed packages to path (run when Matlab starts up)
- `pim clear`: clears all installed packages

## More details

### Install a single package

__Install (searches FileExchange and Github):__

```
>> pim install export_fig
```

When installing, pim checks for a file in the package called `install.m`, which it will run after confirming (or add `--force` to auto-confirm). It also checks for a file called `pathlist.txt` which tells it which paths (if any) to add.

__Install a Github release (by tag, branch, or commit)__

By tag:

```
>> pim install matlab2tikz -t 1.0.0
```

By branch:

```
>> pim install matlab2tikz -t develop
```

By commit:

```
>> pim install matlab2tikz -t ca56d9f
```

__Uninstall__

```
>> pim uninstall matlab2tikz
```

When uninstalling, pim checks for a file in the package called `uninstall.m`, which it will run after confirming (or add `--force` to auto-confirm).

__Search without installing:__

```
>> pim search export_fig
```

__Install from a url:__

```
>> pim install covidx -u https://www.mathworks.com/matlabcentral/fileexchange/76213-covidx
```
OR:

```
>> pim install export_fig -u https://github.com/altmany/export_fig.git
```

(Note that when specifying Github repo urls you must add the '.git' to the url.)

__Install local package:__

```
>> pim install my_package -u path/to/package --local
```

The above will copy `path/to/package` into the default install directory. To skip the copy, add `-e` to the above command.

__Overwrite existing packages:__

```
>> pim install matlab2tikz --force
```

__Install/uninstall packages in a specific directory:__

```
>> pim install matlab2tikz -d /Users/mobeets/mypath
```

Note that the default installation directory is `pim-packages/`.

## Installing multiple packages from file

```
>> pim install -i /Users/mobeets/example/requirements.txt
```

Specifying a requirements file lets you install or search for multiple packages at once. See 'requirements-example.txt' for an example. Make sure to provide an absolute path to the file!

To automatically confirm installation without being prompted, set `--force`.

## What it does

By default, pim installs all Matlab packages to the directory `pim-packages/`. (You can edit `pim_config.m` to specify a custom default installation directory.)

If you restart Matlab, you'll want to run `pim init` to re-add all the folders in the installation directory to your Matlab path. Better yet, just run `pim init` from your Matlab [startup script](http://www.mathworks.com/help/matlab/ref/startup.html).

## Troubleshooting

Because there's no standard directory structure for a Matlab package, automatically adding paths can get a bit messy. When pip downloads a package, it adds a single folder within that package to your Matlab path. If there are no `*.m` files in the package's base directory, it looks in folders called 'bin', 'src', 'lib', or 'code' instead. You can specify the name of an internal directory by passing in an `-n` or `internaldir` argument. To install a package without modifying any s, set `--nos`. Or to add _all_ subfolders in a package to the , set `--alls`.

pim keeps track of the packages it's downloaded in a file called `pim.mat`, within each installation directory.

## Requirements

pim should work cross-platform on versions Matlab 2014b and later.
