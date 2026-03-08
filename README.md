# 🛠️ AWS / Lightsail Root 登录管理工具

该工具用于在 **AWS EC2 / Lightsail** 环境中快速启用 root 登录、修复 cloudimg 限制、复制 SSH 公钥、修改 sshd_config、设置 root 密码并重启 SSH 服务。  
支持一键安装及执行 `awsroot` 全局命令。

## ✨ 功能特性
- 自动检测系统类型（Ubuntu / Debian / CentOS / Amazon Linux）
- 自动识别 AWS 环境（Lightsail / EC2 / 普通 Linux）
- 自动检查 root 登录状态
- 自动检查 SSH PasswordAuthentication 状态
- 自动检查 SSH 服务状态（支持 sshd / ssh / ssh.socket）
- 自动修复 Lightsail cloudimg 限制
- 自动启用 root 登录
- 启用 SSH 密码登录
- 复制 ubuntu 公钥 → root
- 设置 root 密码
- 重启 SSH 服务
- 禁用 root 登录
- 卸载工具（删除 awsroot 指令）
- 自动安装 awsroot 全局命令

## 🚀 一键安装
```bash
bash <(curl -Ls https://raw.githubusercontent.com/xboardnext999/AWS_root/main/awsroot.sh)
```
安装后执行：
```bash
awsroot
```

## 🟢 执行示例
=== AWS Root 登录管理工具 v1.3 ===
系统类型：Ubuntu 22.04  
环境：Lightsail  
Root 登录：未启用  
SSH 密码登录：未启用  
SSH 状态：running (ssh.socket)

## 🔥 一键全部执行
包含：
- 启用 root 登录  
- 修复 cloudimg  
- 启用 PasswordAuthentication  
- 自动复制 SSH Key  
- 设置 root 密码  
- 重启 SSH  

## ⚙️ 自动检测内容
### 系统类型
Ubuntu / Debian / CentOS / Amazon Linux  
### 环境识别  
Lightsail / EC2 / 普通 VPS  
### Lightsail 修复  
自动修复：
- PasswordAuthentication  
- PermitRootLogin  
- AuthorizedKeys  
路径：
`/etc/ssh/sshd_config.d/60-cloudimg-settings.conf`
### SSH 服务检测  
自动检测 sshd / ssh / ssh.socket

## 🧩 功能列表
| 编号 | 功能名称            | 描述 |
|------|---------------------|------|
| 1    | 一键全部执行        | 完整启用 root |
| 2    | 启用 root 登录      | 修改 sshd_config & cloudimg |
| 3    | 复制 SSH Key        | ubuntu → root |
| 4    | 设置 root 密码      | 修改 root 密码 |
| 5    | 禁用 root 登录      | 恢复默认安全 |
| 6    | 查看当前状态        | 查看所有检测结果 |
| 7    | 重启 SSH 服务       | 自动适配服务类型 |
| 8    | 卸载工具            | 删除全局命令 awsroot |
| 9    | 退出                | 退出脚本 |

## 🧹 卸载工具
### 菜单卸载：
8. 卸载工具（恢复默认）

### 手动卸载：
```bash
rm -f /usr/local/bin/awsroot
```

## 🔐 安全提示
- 启用 root 存在安全风险  
- 建议使用强密码  
- 推荐使用 SSH Key 登录  
- 生产环境建议限制 SSH 来源 IP  

## Stars 增长记录

[![Star History Chart](https://api.star-history.com/image?repos=xboardnext999/AWS_root&type=date&legend=top-left)](https://www.star-history.com/?repos=xboardnext999%2FAWS_root&type=date&legend=top-left)
