# OpenWRT Kitchen

OpenWRT厨房，定制您的专属OpenWRT固件，生成可直接刷写的镜像文件。

* 仅支持 `x86-64` 架构
* 目前仅支持 `ext4` 文件系统的镜像文件
* 目前仅支持 `mbr` 模式的镜像文件
* 支持输入经过gzip压缩后的镜像文件
* 支持 OpenWRT 21.*
* 支持 OpenWRT 22.*

## TODO
* [ ] 支持 `squashfs` 文件系统的镜像文件
* [ ] 支持 `efi` 模式的镜像文件
* [ ] 支持自定义镜像文件总容量
* [ ] github actions
* [ ] 支持在网页上定制各项配置，并导出配置
* [ ] 支持切换用户配置

## 配置

默认配置位于 `config.default.sh`，如需覆盖配置，请添加一个 `config.user.sh` 文件

例如：

```sh
export LUCI_LANGUAGE=
``` 
默认未配置语言，如果想要改为中文简体，则可以新建 `config.user.sh` 文件并写入

```sh
export LUCI_LANGUAGE="zh-cn"
```

## 烹饪步骤

1. 执行内置脚本
2. 执行个人脚本
3. 覆盖一些文件到根目录

### 脚本

所有的脚本文件位于 `kitchen/scripts.d` 目录下。

通过修改配置文件，来影响每个脚本的执行，

你也可以添加自己的脚本，脚本文件的执行顺序通过文件名前3位数字来排序。

### 个人脚本

对于非通用的，个人向的脚本，建议添加到 `kitchen/user_scripts.d` 目录下。

git会忽略此目录下的任何更改

### 根目录覆盖

位于 `rootfs_override` 目录下的所有文件或目录将会覆盖到镜像的根目录下

## 使用说明

下载OpenWRT镜像文件，放入 `imgs` 目录。然后执行
```sh
./openwrt_kitchen.sh imgs/openwrt-22.03.0-rc6-x86-64-generic-ext4-combined.img.gz
```

## 如何贡献

1. 在 `kitchen/scripts.d` 中添加脚本
2. 在 `config.default.sh` 增加关联的配置项，一个脚本可以有多个关联的配置项，且至少应该包含一个开关
