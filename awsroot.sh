#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

[[ $EUID -ne 0 ]] && echo -e "${red}错误:${plain} 必须使用 root 用户运行！" && exit 1

# ==============================
# 自动安装 awsroot 命令
# ==============================
install_self() {
    if [[ $0 != "/usr/local/bin/awsroot" ]]; then
        echo -e "${yellow}► 正在自动安装 awsroot ...${plain}"

        curl -Ls https://raw.githubusercontent.com/xboardnext999/AWS_root/main/awsroot.sh -o /usr/local/bin/awsroot
        chmod +x /usr/local/bin/awsroot

        echo -e "${green}✔ 安装完成！现在可直接输入：  awsroot${plain}"

        /usr/local/bin/awsroot
        exit
    fi
}

install_self


# ==============================
# 检测系统环境
# ==============================
detect_env() {
    if [[ -f /etc/os-release ]]; then
        OS_NAME=$(grep "^NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
        OS_VER=$(grep "VERSION_ID" /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        OS_NAME="Unknown"
        OS_VER="Unknown"
    fi

    # 判断是否 Lightsail
    if curl -s http://169.254.169.254/latest/meta-data/instance-id | grep -q "i-"; then
        ENVIRONMENT="EC2 / 标准 Linux"
    else
        ENVIRONMENT="Lightsail"
    fi
}

# ==============================
# 检测 root 登录状态
# ==============================
check_root_status() {
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config || \
       grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config.d/* 2>/dev/null; then
        ROOT_STATUS="已启用"
    else
        ROOT_STATUS="未启用"
    fi
}

# ==============================
# 检测 SSH 密码登录状态
# ==============================
check_password_status() {
    if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config || \
       grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config.d/* 2>/dev/null; then
        PASSWORD_STATUS="已启用"
    else
        PASSWORD_STATUS="未启用"
    fi
}

# ==============================
# 检测 SSH 运行状态（兼容 Lightsail）
# ==============================
check_ssh_status() {
    if systemctl is-active sshd >/dev/null 2>&1; then
        SSH_STATUS="running (sshd)"
    elif systemctl is-active ssh >/dev/null 2>&1; then
        SSH_STATUS="running (ssh)"
    elif systemctl is-active ssh.socket >/dev/null 2>&1; then
        SSH_STATUS="running (ssh.socket)"
    else
        SSH_STATUS="inactive"
    fi
}

# ==============================
# 启用 root 登录
# ==============================
enable_root_login() {
    echo -e "${yellow}→ 启用 root 登录 ...${plain}"

    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

    # 修复 cloudimg（Lightsail 特有）
    if [[ -f /etc/ssh/sshd_config.d/60-cloudimg-settings.conf ]]; then
        sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
        
        if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config.d/60-cloudimg-settings.conf; then
            echo "PermitRootLogin yes" >> /etc/ssh/sshd_config.d/60-cloudimg-settings.conf
        fi

        echo -e "${green}✔ 已修复 cloudimg 配置${plain}"
    fi

    echo -e "${green}✔ Root 登录已启用${plain}"
}

# ==============================
# 复制 ubuntu SSH key
# ==============================
copy_ssh_key() {
    echo -e "${yellow}→ 复制 SSH 公钥 ...${plain}"

    mkdir -p /root/.ssh
    if [[ -f /home/ubuntu/.ssh/authorized_keys ]]; then
        cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/
        chmod 600 /root/.ssh/authorized_keys
        chmod 700 /root/.ssh
        echo -e "${green}✔ 已复制 ubuntu 公钥到 root${plain}"
    else
        echo -e "${red}× 未找到 /home/ubuntu/.ssh/authorized_keys${plain}"
    fi
}

# ==============================
# 设置 root 密码
# ==============================
set_root_pass() {
    echo -e "${yellow}→ 设置 root 密码：${plain}"
    passwd root
}

# ==============================
# 禁用 root 登录
# ==============================
disable_root_login() {
    sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    echo -e "${green}✔ Root 登录已禁用${plain}"
}

# ==============================
# 重启 SSH 服务
# ==============================
restart_ssh() {
    echo -e "${yellow}→ 重启 SSH ...${plain}"

    systemctl daemon-reload 2>/dev/null
    systemctl restart sshd 2>/dev/null
    systemctl restart ssh 2>/dev/null
    systemctl restart ssh.socket 2>/dev/null

    echo -e "${green}✔ SSH 已重启${plain}"
}

# ==============================
# 查看状态
# ==============================
show_status() {
    detect_env
    check_root_status
    check_password_status
    check_ssh_status

    echo -e "${green}=== AWS Root 登录管理工具 v1.3 ===${plain}"
    echo "系统类型：$OS_NAME $OS_VER"
    echo "环境：$ENVIRONMENT"
    echo "Root 登录：$ROOT_STATUS"
    echo "SSH 密码登录：$PASSWORD_STATUS"
    echo "SSH 状态：$SSH_STATUS"
    echo
}

# ==============================
# 卸载 awsroot
# ==============================
uninstall_self() {
    echo -e "${yellow}→ 正在卸载 ...${plain}"

    rm -f /usr/local/bin/awsroot
    sed -i 's/PermitRootLogin yes/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

    echo -e "${green}✔ 工具已卸载，Root 登录已恢复默认${plain}"
    exit 0
}

# ==============================
# 菜单
# ==============================
menu() {
    show_status

    echo "-----------------------------"
    echo " 1. 一键全部执行（推荐）"
    echo " 2. 启用 root 登录"
    echo " 3. 复制 ubuntu SSH key"
    echo " 4. 设置 root 密码"
    echo " 5. 禁用 root 登录"
    echo " 6. 查看当前状态"
    echo " 7. 重启 SSH 服务"
    echo " 8. 卸载工具（恢复默认）"
    echo " 9. 退出"
    echo "-----------------------------"

    read -rp "请输入选项 [1-9]: " num

    case $num in
        1) enable_root_login; copy_ssh_key; set_root_pass; restart_ssh ;;
        2) enable_root_login ;;
        3) copy_ssh_key ;;
        4) set_root_pass ;;
        5) disable_root_login ;;
        6) show_status ;;
        7) restart_ssh ;;
        8) uninstall_self ;;
        9) exit 0 ;;
        *) echo -e "${red}无效选项${plain}" ;;
    esac

    echo
    read -rp "按回车返回菜单..."
}


while true; do
    menu
done
