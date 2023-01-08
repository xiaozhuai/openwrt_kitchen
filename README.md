# OpenWrt Kitchen

OpenWrt厨房，定制您的专属OpenWrt固件，生成可直接刷写的镜像文件。

可在 [Actions](https://github.com/xiaozhuai/openwrt_kitchen/actions) 页面下载使用默认配置构建的镜像文件.

[![OpenWrt-21](https://github.com/xiaozhuai/openwrt_kitchen/actions/workflows/OpenWrt-21.yml/badge.svg)](https://github.com/xiaozhuai/openwrt_kitchen/actions/workflows/OpenWrt-21.yml)

[![OpenWrt-22](https://github.com/xiaozhuai/openwrt_kitchen/actions/workflows/OpenWrt-22.yml/badge.svg)](https://github.com/xiaozhuai/openwrt_kitchen/actions/workflows/OpenWrt-22.yml)

* 仅支持 `x86-64` 架构
* 目前仅支持 `ext4` 文件系统的镜像文件
* 目前仅支持 `mbr` 模式的镜像文件
* 支持输入经过gzip压缩后的镜像文件
* 支持 OpenWrt 21.*
* 支持 OpenWrt 22.*
* 支持 Docker 构建
* 支持 Github Actions 构建

## TODO
* [ ] 支持 `squashfs` 文件系统的镜像文件
* [ ] 支持 `efi` 模式的镜像文件
* [ ] 支持自定义镜像文件总容量
* [ ] 支持在网页上定制各项配置，并导出配置
* [ ] 支持切换用户配置

## 烹饪步骤

1. 执行内置脚本
2. 执行个人脚本
3. 覆盖一些文件到根目录

### 配置

默认配置文件位于 `configs` 目录下。

所有的配置选项位于 `config.default.sh`，如需覆盖配置，请新建一个 `config.myconf.sh` 文件

**建议在用户自定义配置目录新建配置文件，见后文用户自定义配置**

例如，默认未配置语言
```sh
export LUCI_LANGUAGE=
```

如果想要改为中文简体，则可以新建 `config.myconf.sh` 文件并写入
```sh
export LUCI_LANGUAGE="zh-cn"
```

### 脚本

所有的脚本文件位于 `kitchen/scripts.d` 目录下。

通过修改配置文件，来影响每个脚本的执行，

你也可以添加自己的脚本，脚本文件的执行顺序通过文件名前3位数字来排序。

### 用户自定义配置

用户自定义配置目录可以覆盖配置文件目录以及脚本目录，还提供了根文件系统覆盖的功能
创建一个个人配置目录，例如`myopenwrt`，并在此目录下创建`configs`, `rootfs`, `scripts.d`目录。

#### configs
用户配置文件目录

#### scripts.d
用户自定义脚本

#### rootfs
此文件夹下的所有内容将会覆盖到根文件系统

## 使用说明

在linux环境下执行下面的命令
```sh
sudo ./openwrt_kitchen.sh \
  -u myopenwrt \
  -c myconf \
  -i openwrt-21.02.3-x86-64-generic-ext4-combined.img.gz \
  -o openwrt-21.02.3-x86-64-generic-ext4-combined-cooked.img
```

也可以使用docker
```sh
./docker_openwrt_kitchen.sh \
  -u myopenwrt \
  -c myconf \
  -i openwrt-21.02.3-x86-64-generic-ext4-combined.img.gz \
  -o openwrt-21.02.3-x86-64-generic-ext4-combined-cooked.img
```

## 如何贡献

1. 在 `kitchen/scripts.d` 中添加脚本
2. 在 `config.default.sh` 增加关联的配置项，一个脚本可以有多个关联的配置项，且至少应该包含一个开关
