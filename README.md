answer-vibration
================

拨打电话时需要把手机贴着耳朵听对方是否接电话了, 这样辐射会很大

android手机基本都有的接听震动功能, 当对方接电话后, 手机会震动提醒你

不用拨电话时一直听着等着对方接电话了

##安装

添加我的源:

    http://www.zhaoxiaodan.com/cydia/

##编译

* 参考[iOS越狱开发系统配置](/ios/ios%E8%B6%8A%E7%8B%B1%E5%BC%80%E5%8F%91%E7%B3%BB%E7%BB%9F%E9%85%8D%E7%BD%AE-iosopendev.html) 这篇文章配置环境
* 一定记得更新iOS版本 `sudo /opt/iOSOpenDev/bin/iod-setup sdk -sdk iphoneos`
* 用xcode 打开工程
* 修改`BuildSettings`->`iOSOpenDevDevice`为你手机的ip地址
* xcode菜单项`Product`->`Build For`->`Profiling`会自动编译并安装到手机

