# PWA FullCover

SillyTavern 扩展:主屏幕 App(PWA)模式下,聊天页与角色卡选择页 UI 全屏铺满、输入栏贴底,背景不再从边缝露出;扩展面板里有开关,安装后默认开启,PC 浏览器与手机 Safari 不受任何影响。

## 安装

SillyTavern → 扩展面板 → Install extension,填入 Git 地址:

```
https://github.com/atostar409/st-pwa-fullcover
```

## 新电脑 + 手机直连一键部署(可选)

给朋友的电脑装酒馆、手机 Safari 添加主屏 App 用,不想手动改配置的话,用仓库里的 `setup-mobile.bat`:

1. 先把酒馆装好并双击 `Start.bat` 跑一次(完成依赖安装、生成 config.yaml),看到服务起来后关掉窗口;
2. 把 `setup-mobile.bat` 放进酒馆根目录(和 `Start.bat` 同级)双击:自动改好局域网监听 + 免密启动(原 config 备份为 `config.yaml.bak_before_mobile`)、**自动安装本扩展(扩展文件已内嵌在脚本里,全程不需要联网)**、打印本机 IP 并重新启动服务器(防火墙弹窗点"允许");
3. 手机连同一 Wi-Fi,Safari 打开 `http://本机IP:8000`,分享 → 添加到主屏幕,以后从主屏图标进入(直接在 Safari 里打开没有全屏效果,属正常)。

注意:此配置 = 局域网内免密可访问,仅适合自己家里的 Wi-Fi,不要在公共网络下使用。
