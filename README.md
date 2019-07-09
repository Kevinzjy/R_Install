# R_Install
Install R-3.5.1 on Linux server without root privilege

## Prerequisition

gFortan 77 Compiler

## Usage

Run install.sh under repository directory

```bash
git clone https://github.com/Kevinzjy/R_Install.git
cd R_Install
./install.sh
```

After installation complete, you can delete `./build` directory to save spaces

## About

The `install.sh` install zlib / bzip2 / liblzma / pcre and libcurl automatically before installation of R-3.5.1.

When compiling samtools / htslib / bcftools, assume that `R_HOME` is the directory of R-3.5.1, you can used the library installed under `R_HOME`.

```bash
export CFLAGS="-I${R_HOME}/include"
export LDFLAGS="-L${R_HOME}/lib"
```

## Contact

For any questions, please contact zhangjinyang@biols.ac.cn
